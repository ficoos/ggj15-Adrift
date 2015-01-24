local class = require 'hump.class'
local vector = require 'hump.vector-light'
local OrderedTable = require 'OrderedTable'
local util = require 'util'
local Event = require 'Event'
local Timer = require 'hump.timer'

local lg = love.graphics
local lp = love.physics

local ASTRO_DENSITY = 0.2

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
    self._lastInChain = self
    self.isDead = false
    self:_set_up_physics()
    self.onDestroy = Event()
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
    lg.translate(x,y)
    lg.rotate(self._physics.body:getAngle())
    --lg.setColor(self._color)
    --lg.rectangle("line", -self._width/2, -self._height/2, self._width,self._height)
    lg.setColor(255, 255, 255)
    local factor = 1.2
    local scale = math.max(img:getWidth(), img:getHeight()) / (self._height * factor)
    lg.draw(img, -(self._width * factor) /2, -(self._height * factor)/2, 0, 1/scale)
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

function Astronaut:onCollidesWith(target,coll)
    if (target._type=="astronaut"
        and self:getName()=="player"
        and not self:isInChain(target)
    ) then
        self._level:doOnNextUpdate(
            function()
                connectAstronauts(self:getLastInChain(), target)
                self._lastInChain=target
            end
        )
    elseif (
        target._type=="SpaceStation"
        and self._lastInChain ~= self
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
            local station_pos = {self._level._station:get_position()}
            self._timer.tween(1, ast, {_lastPosition=station_pos}, "linear", function()
                self._level.rescued_friends = self._level.rescued_friends + 1
                ast:destroy()
            end)
        end)
    elseif target._type=="Star" then
        self._level:doOnNextUpdate(function()
            self:destroy()
        end)
    end;
end

--connect B to A
function connectAstronauts(objA,objB)
    objA._connectedTo = objB
    objB._connectedFrom = objA
    local newJoint = nil
    if math.random() < 0.5 then
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
