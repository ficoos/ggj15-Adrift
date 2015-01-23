local class = require 'hump.class'

local lg = love.graphics
local lp = love.physics

local ASTRO_DENSITY = 1

local Astronaut = class{}

function Astronaut:init(world, color)
    assert(world)
    self._color = color or {255, 255, 255, 255}
    self._world = world
    self._radius = 10
    self._position = {0, 0}
    self:_set_up_physics()
end

function Astronaut:_set_up_physics()
    local world = self._world
    local x, y = 0, 0
    local body = lp.newBody(world, x, y, "dynamic")
    local shape = lp.newCircleShape(x, y, self._radius)
    local fixture = lp.newFixture(body, shape, ASTRO_DENSITY)
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

function Astronaut:draw()
    local x, y = self:get_position()
    lg.setColor(self._color)
    lg.circle("fill", x, y, self._radius)
end

return Astronaut
