local class = require 'hump.class'
local util = require 'util'
local Event = require 'Event'

local lg = love.graphics
local lp = love.physics

local Asteroid = class{}

local DENSITY = 1

function Asteroid:init(world, radius, name)
    assert(world)
    assert(radius)
    self._name = name or util.uuid("Asteroid")
    self._world = world
    self._radius = radius
    self._position = {0, 0}
    self:_set_up_physics()
    self._direction = 0
    self._speed = 0
    self.onDestroy = Event()
end

function Asteroid:_set_up_physics()
    local world = self._world
    local x, y = 0, 0
    local body = lp.newBody(world, x, y, "dynamic")
    local shape = lp.newCircleShape(x, y, self._radius)
    local fixture = lp.newFixture(body, shape, DENSITY)
    fixture:setSensor(true)
    fixture:setUserData(self)
    self._physics = {body=body, shape=shape, fixture=fixture}
end

function Asteroid:getName(dt)
    return self._name
end

function Asteroid:activate()
    self._physics.fixture:setSensor(false)
end

function Asteroid:deactivate()
    self._physics.fixture:setSensor(true)
end

function Asteroid:update(dt)
end

function Asteroid:onCollidesWith(other, coll)
    if other._type == "Star" then
        self.onDestroy:emit(self)
    end
end

function Asteroid:get_position()
    return self._physics.body:getPosition()
end

function Asteroid:set_position(x, y)
    return self._physics.body:setPosition(x, y)
end

function Asteroid:set_speed(speed)
    self._speed = speed
    self._physics.body:setLinearVelocity(
        math.cos(self._direction) * self._speed,
        math.sin(self._direction) * self._speed
    )
end

function Asteroid:set_direction(theta)
    self._direction = theta
end

function Asteroid:draw()
    local x, y = self:get_position()
    lg.setColor(255, 0, 0, 255)
    lg.circle("fill", x, y, self._radius)
end

return Asteroid
