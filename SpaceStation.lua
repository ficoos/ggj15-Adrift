local class = require 'hump.class'
local util = require 'util'

local lg = love.graphics
local lp = love.physics
local img = lg.newImage("data/gfx/spaceship.png")

local SpaceStation = class{}

function SpaceStation:init(name, level, x, y)
    assert(level)
    self._type = "SpaceStation"
    self._name = name or util.uuid("SpaceStation")
    self._color = {100, 100, 255, 255}
    self._world = level:getWorld()
    self._radius = 150
    self._position = {x, y}
    self:_set_up_physics()
end

function SpaceStation:getName()
    return self._name
end

function SpaceStation:_set_up_physics()
    local world = self._world
    local x, y = unpack(self._position)
    local body = lp.newBody(world, x, y, "static")
    local shape = lp.newCircleShape(0, 0, self._radius)
    local fixture = lp.newFixture(body, shape, 1)
    fixture:setUserData(self)
    self._physics = {body=body, shape=shape, fixture=fixture}
end

function SpaceStation:update(dt)
end

function SpaceStation:get_position()
    return self._physics.body:getPosition()
end

function SpaceStation:draw()
    local x, y = self:get_position()
    local r = self._radius
    --lg.setColor(self._color)
    --lg.circle("fill", x, y, self._radius)
    lg.setColor(255, 255, 255, 255)
    lg.draw(img,x - 145, y - r)
end


return SpaceStation
