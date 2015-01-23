local class = require 'hump.class'
local util = require 'util'

local lg = love.graphics
local lp = love.physics

local Star = class{}

local G = 6.6726 * 1000000

function Star:init(name, level, x, y, radius, mass)
    assert(level)
    assert(radius)
    assert(mass)
    self._name = name or util.uuid("Star")
    self._color = {255, 255, 0, 255}
    self._world = level:getWorld()
    self._radius = radius
    self._mass = mass
    self._position = {x, y}
    self:_set_up_physics()
end

function Star:getName()
    return self._name
end

function Star:_set_up_physics()
    local world = self._world
    local x, y = unpack(self._position)
    local body = lp.newBody(world, x, y, "static")
    local shape = lp.newCircleShape(0, 0, self._radius)
    local fixture = lp.newFixture(body, shape, 1)
    body:setMass(self._mass)
    fixture:setUserData(self)
    self._physics = {body=body, shape=shape, fixture=fixture}
end

function Star:update(dt)
end

function Star:draw()
    local x, y = self:get_position()
    local r = self._radius
    lg.setColor(self._color)
    lg.circle("fill", x, y, self._radius)
end

function Star:attract(b)
    local a = self._physics.body
    local x1, y1 = a:getPosition()
    local x2, y2 = b:getPosition()
    local dx = x2 - x1
    local dy = y2 - y1
    local dist_sqr = dy * dy + dx * dx
    local f = (G * b:getMass()) / dist_sqr
    local dir = util.angle_towards(x1, y1, x2, y2)
    b:applyForce(math.cos(dir) * f, math.sin(dir) * f)
end

return Star
