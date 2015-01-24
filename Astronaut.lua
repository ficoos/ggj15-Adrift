local class = require 'hump.class'
local vector = require 'hump.vector-light'
local OrderedTable = require 'OrderedTable'
local util = require 'util'
local Event = require 'Event'
local Timer = require 'hump.timer'

local lg = love.graphics
local lp = love.physics
local la = love.audio

local ASTRO_DENSITY = 0.2

local RESCUE_SPEECH = {
    la.newSource("data/sounds/foundguy/comewithme.ogg"),
    la.newSource("data/sounds/foundguy/dontletgo.ogg"),
    la.newSource("data/sounds/foundguy/grabthis.ogg"),
    la.newSource("data/sounds/foundguy/hangon.ogg"),
    la.newSource("data/sounds/foundguy/lookingforyou.ogg"),
    la.newSource("data/sounds/foundguy/therewego.ogg"),
}


local Astronaut = class{}
local img = lg.newImage("data/gfx/astronaut.png")

function Astronaut:init(name, level, color)
    assert(level)
    self._timer = Timer.new()
    self._type="astronaut"
    self._name = name or util.uuid("Astronaut")
    self._color = color or {255, 255, 255, 255}
    self._level = level
    self._world = level:getWorld()
    self._height = 50
    self._width = (img:getWidth() / img:getHeight()) * self._height
    self._position = {0, 0 }
    self._connectedTo = nil
    self._connectedFrom = nil
    self.isDead = false
    self:_set_up_physics()
    self.onDestroy = Event()
    self:_setUpThruser()
end

function Astronaut:_setUpThruser()
    local psystem = lg.newParticleSystem(lg.newImage("data/gfx/air_particle.png"), 1000)
    psystem:setParticleLifetime(0.1, 0.2); -- Particles live at least 2s and at most 5s.
    psystem:setEmissionRate(1);
    psystem:setSizeVariation(1);
    psystem:setEmitterLifetime(0);
    psystem:setSizes(5);
    psystem:setLinearAcceleration(-20, -20, 20, 20); -- Random movement in all directions.
    psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0); -- Fade to black.

    self._air_part = psystem
    self:thrust()
end

function Astronaut:getName()
    return self._name
end

function Astronaut:_set_up_physics()
    local world = self._world
    local x, y = 0, 0
    local body = lp.newBody(world, x, y, "dynamic")
    local shape = lp.newRectangleShape(x, y, self._width, self._height)
    local fixture = lp.newFixture(body, shape, ASTRO_DENSITY)
    fixture:setUserData(self)

    world:setCallbacks(onHitAstronaut)
    self._physics = {body=body, shape=shape, fixture=fixture}
end

function Astronaut:apply_force(ix, iy)
    self._physics.body:applyForce(ix,  iy)
end

function Astronaut:update(dt)
    self._timer.update(dt)
    self._air_part:update(dt)
    if self._connecting then
        local hand = self._connecting_hand
        local leg = self._connecting_leg
        local x, y = self:getHandPosition(hand)
        local tx, ty = self._connecting_target:getLastInChain():getLegPosition(leg)
        local dx = tx - x
        local dy = ty - y
        local dist = math.sqrt(dx * dx + dy * dy)
        local theta = util.angle_towards(tx, ty, x, y)
        local x, y = self:get_position()
        local d = self._connecting_duration
        self._connecting_duration = d + dt
        local speed = 5 * d
        local nx, ny = x + math.cos(theta) * speed , y + math.sin(theta) * speed
        self:set_position(nx, ny)
        if (dist < 6) then
            self._connecting = nil
            local target = self._connecting_target:getLastInChain()
            self._connecting_target = nil
            self._physics.body:setActive(true)
            connectAstronauts(target, self:getLastInChain(), hand)
        end
    end
    self._air_part:setPosition(self:get_position())
end

function Astronaut:thrust()
    self._air_part:stop()
    self._air_part:start()
    self._air_part:emit(1)
end

function Astronaut:get_position()
    if self._lastPosition then
        local x, y = unpack(self._lastPosition)
        return x, y
    end
    return self._physics.body:getPosition()
end

function Astronaut:set_position(x, y)
    return self._physics.body:setPosition(x, y)
end

function Astronaut:set_angle(angle)
    return self._physics.body:setAngle(angle)
end

function Astronaut:draw()
    local x, y = self:get_position()
    lg.draw(self._air_part)
    lg.push()
    lg.translate(x,y)
    lg.rotate(self._physics.body:getAngle())
    --lg.setColor(self._color)
    --lg.rectangle("line", -self._width/2, -self._height/2, self._width,self._height)
    lg.setColor(255, 255, 255)
    local factor = 1.2
    local scale = math.max(img:getWidth(), img:getHeight()) / (self._height * factor)
    if self._name == "player" then
        lg.setColor(255, 230, 160)
    end
    lg.draw(img, -(self._width * factor) /2, -(self._height * factor)/2, 0, 1/scale)
    lg.setColor(255, 0, 0)
    lg.pop()
    --local lhx, lhy = self:getHandPosition("left")
    --local rhx, rhy = self:getHandPosition("right")
    --local llx, lly = self:getLegPosition("left")
    --local rlx, rly = self:getLegPosition("right")
    --if self._name == "player" then
    --    lg.circle("fill", lhx, lhy, 3)
    --    lg.circle("fill", rhx, rhy, 3)
    --    lg.circle("fill", llx, lly, 3)
    --    lg.circle("fill", rlx, rly, 3)
    --end
end

function onHitAstronaut(a,b,coll)
    local objA=a:getUserData()
    local objB=b:getUserData()
    if objA and objA.onCollidesWith then
        objA:onCollidesWith(objB,coll)
    end

    if objB and objB.onCollidesWith then
        objB:onCollidesWith(objA,coll)
    end

end

function Astronaut:destroy(target,coll)
    self.isDead = true
    self._connectedTo = nil
    self.onDestroy:emit(self)
    self._lastPosition = self:get_position()
    if self._connectedFrom then
        self._connectedFrom._connectedTo = nil
    end
    self._physics.body:destroy()
end

function Astronaut:isInChain(target)
    local ast = self
    while ast._connectedTo ~= nil do
        if ast._connectedTo == target then
            return true
        else
            ast = ast._connectedTo
        end
    end
    return false
end

function Astronaut:getLastInChain()
    local ast = self
    while ast._connectedTo ~= nil do
        ast = ast._connectedTo
    end
    return ast
end

function Astronaut:disconnect()
    self._connectedFrom._connectedTo = nil
    self._connectedFrom = nil
    self._joint:destroy()
end

function Astronaut:startConnect(target)
    self._connecting = true
    self._physics.body:setActive(false)
    self._connecting_target = target
    self._connecting_duration = 0.1
    if math.random() > 0.5 then
        self._connecting_leg = "left"
        self._connecting_hand = "right"
    else
        self._connecting_leg = "right"
        self._connecting_hand = "left"
    end
end

function Astronaut:onCollidesWith(target,coll)
    if (target._type=="astronaut"
        and self:getName()=="player"
        and not self:isInChain(target)
    ) then
        if target._connecting then
            return
        end
        playOneOf(RESCUE_SPEECH)
        self._level:doOnNextUpdate(
            function()
                target:startConnect(self)
            end
        )
    elseif (
        target._type=="SpaceStation"
        and self:getLastInChain() ~= self
        and self:getName()=="player"
    ) then
        self._level:doOnNextUpdate(function()
            if target.isDead then
                return
            end
            local ast = self:getLastInChain()
            if ast == self then
                return
            end
            ast:disconnect()
            ast._lastPosition = {ast:get_position()}
            ast._physics.fixture:setSensor(true)
            ast.isDead = true
            ast._rescued = true
            local station_pos = {self._level._station:get_position()}
            self._timer.tween(1, ast, {_lastPosition=station_pos, _width=0, _height=0}, "linear", function()
                self._level.rescued_friends = self._level.rescued_friends + 1
                self._level:notify("You rescued " .. self._level.rescued_friends .. " friends!")
                ast:destroy()
            end)
        end)
    elseif target._type=="Star" then
        self._level:doOnNextUpdate(function()
            self:destroy()
        end)
    end;
end

function Astronaut:getHandPosition(which)
    local px, py = self:get_position()
    if which == "right" then
        return util.rotateAroundPoint(
            self._physics.body:getAngle(),
            px, py,
            self._width/2 + px,
            -self._height/2 + py
        )
    else
        return util.rotateAroundPoint(
            self._physics.body:getAngle(),
            px, py,
            -self._width/2 + px,
            -self._height/2 + py
        )
    end
end

function Astronaut:getLegPosition(which)
    local px, py = self:get_position()
    if which == "right" then
        return util.rotateAroundPoint(
            self._physics.body:getAngle(),
            px, py,
            self._width/2 + px,
            self._height/2 + py
        )
    else
        return util.rotateAroundPoint(
            self._physics.body:getAngle(),
            px, py,
            -self._width/2 + px,
            self._height/2 + py
        )
    end
end

--connect B to A
function connectAstronauts(objA,objB, dir)
    objA._connectedTo = objB
    objB._connectedFrom = objA
    local newJoint = nil
    if dir == "left" then
        newJoint = newRevoluteJoint(objA,objB,
            objA._width/2,
            objA._height/2,
            -objB._width/2,
            -objB._height/2)
    else
        newJoint = newRevoluteJoint(objA,objB,
            -objA._width/2,
            objA._height/2,
            objB._width/2,
            -objB._height/2)
    end
    objB._joint = newJoint

end

function newRevoluteJoint(objA,objB, x1, y1, x2,y2)
    local jointPadding = 0
    local bodyA=objA._physics.body
    local bodyB=objB._physics.body
    local aX, aY = bodyA:getPosition()
    local angle = bodyA:getAngle()

    local destinationX,destinationY=aX+x1-x2+jointPadding,aY+y1-y2+jointPadding
    local rotatedX,rotatedY=util.rotateAroundPoint(angle,aX,aY,destinationX,destinationY)
    local jointX,jointY=aX+x1+jointPadding, aY+y1+jointPadding
    local rotatedJointX,rotatedJointY=util.rotateAroundPoint(angle,aX,aY,jointX,jointY)

    bodyB:setPosition(rotatedX,rotatedY)
    bodyB:setAngle(angle)
    local newJoint = lp.newRevoluteJoint(objA._physics.body,
        objB._physics.body, rotatedJointX,rotatedJointY, true )


    return newJoint
end

return Astronaut
