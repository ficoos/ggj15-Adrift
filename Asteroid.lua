local class = require 'hump.class'
local util = require 'util'
local Event = require 'Event'

local lg = love.graphics
local lp = love.physics

local Asteroid = class{}

local DENSITY = 1

local asteroid2 = lg.newImage("data/gfx/asteroid2.png")

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
    self._rot = 0
    self.onDestroy = Event()
end

function Asteroid:_set_up_physics()
    local world = self._world
    local x, y = 0, 0
    local body = lp.newBody(world, x, y, "dynamic")
    local shape = lp.newCircleShape(x, y, self._radius)
    local fixture = lp.newFixture(body, shape, DENSITY)
    body:setActive(false)
    fixture:setUserData(self)
    self._physics = {body=body, shape=shape, fixture=fixture}
end

function Asteroid:getName(dt)
    return self._name
end

function Asteroid:activate()
    self._physics.body:setActive(true)
end

function Asteroid:deactivate()
    self._physics.body:setActive(false)
end

function Asteroid:update(dt)
end

function Asteroid:destroy()
    self._physics.body:destroy()
    self.onDestroy:emit(self)
end

function Asteroid:onCollidesWith(other, coll)
    if other._type == "Star" then
        self:destroy()
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
    lg.setColor(255, 255, 255, 255)
    local scale = math.max(asteroid2:getWidth(), asteroid2:getHeight()) / self._radius
    self._rot = self._rot + (self._radius * 0.00002)
    lg.translate(x, y)
    lg.rotate(self._rot)
    lg.draw(asteroid2, -self._radius, -self._radius, 0, 2/scale)
end

return Asteroid
