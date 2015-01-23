local class = require 'hump.class'
local vector = require 'hump.vector-light'
local OrderedTable = require 'OrderedTable'
local util = require 'util'

local lg = love.graphics
local lp = love.physics

local ASTRO_DENSITY = 0.2

local Astronaut = class{}

function Astronaut:init(name, level, color)
    assert(level)
    self._type="astronaut"
    self._name = name or util.uuid("Astronaut")
    self._color = color or {255, 255, 255, 255}
    self._level = level
    self._world = level:getWorld()
    self._size = 50
    self._position = {0, 0 }
    self._connectedTo=OrderedTable("connectedTo")
    self._lastInChain = self
    self:_set_up_physics()
end

function Astronaut:getName()
    return self._name
end

function Astronaut:_set_up_physics()
    local world = self._world
    local x, y = 0, 0
    local body = lp.newBody(world, x, y, "dynamic")
    local shape = lp.newRectangleShape(x, y, self._size, self._size)
    local fixture = lp.newFixture(body, shape, ASTRO_DENSITY)
    fixture:setUserData(self)
--    fixture:setSensor(true)

    world:setCallbacks(onHitAstronaut)
    self._physics = {body=body, shape=shape, fixture=fixture}
end

function Astronaut:apply_force(ix, iy)
    self._physics.body:applyForce(ix,  iy)
end

function Astronaut:update(dt)
end

function Astronaut:get_position()
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
    lg.setColor(self._color)
    lg.translate(x,y)
    lg.rotate(self._physics.body:getAngle())
    lg.rectangle("fill", -self._size/2, -self._size/2, self._size,self._size)
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

function Astronaut:onCollidesWith(target,coll)
    if (target._type=="astronaut" and
        self._connectedTo[target:getName()]==nil
        and self:getName()=="player"
    ) then
        self._connectedTo[target:getName()]=true
        self._level:doOnNextUpdate(
            function()
                connectAstronauts(self._lastInChain,target)
                self._lastInChain=target
            end
        )
    end;
end

--connect B to A
function connectAstronauts(objA,objB)
    local newJoint = newRevoluteJoint(objA,objB,
        objA._size/2,
        objA._size/2,
        -objB._size/2,
        -objB._size/2)

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
