local Astronaut = require 'Astronaut'
local Asteroid = require 'Asteroid'
local OrderedTable = require 'OrderedTable'
local util = require 'util'

local lg = love.graphics
local lp = love.physics
local lm = love.mouse
local lw = love.window

local SpaceRescue = {}

local FORCE = 25000
local MAX_ASTEROID_RADIUS = 100
local MIN_ASTEROID_SPEED = 50
local MAX_ASTEROID_SPEED = 500

function SpaceRescue:enter(prev, ...)
    lp.setMeter(2)
    self._world = lp.newWorld(0, 0, true)
    self._drawables = OrderedTable()
    self._onNextUpdate = {}

    self._drawables[1]=OrderedTable("asteroids")
    self._drawables[2]=OrderedTable("agents")

    local as1 = Astronaut("player",self,{255,255,0,255})
    local as2 = Astronaut(nil,self)

    table.insert(self._drawables.agents, as1)
    table.insert(self._drawables.agents, as2)

    as1:set_position(lw.getWidth()/2+100, lw.getHeight()/2)
    as2:set_position(lw.getWidth()/2-100, lw.getHeight()/2)
end

function SpaceRescue:_push_player()
    local x, y = lm.getPosition()
    local ax, ay = self._drawables.agents[1]:get_position()
    local theta = util.angle_towards(ax, ay, x, y)

    local ix = -math.cos(theta) * FORCE
    local iy = -math.sin(theta) * FORCE
    self._drawables.agents[1]:apply_force(ix, iy)
end

function SpaceRescue:getWorld()
    return self._world
end

function SpaceRescue:update(dt)
    if (self._onNextUpdate) then
        for _, func in ipairs(self._onNextUpdate) do
            func()
        end
    end
    self._onNextUpdate={}
    self._world:update(dt)

    if lm.isDown("l") then
        self:_push_player()
    end
    for _, layer in ipairs(self._drawables) do
        for _, obj in ipairs(layer) do
            obj:update(dt)
        end
    end
end

function SpaceRescue:doOnNextUpdate(func)
    table.insert(self._onNextUpdate,func)
end

function SpaceRescue:draw()
    for _, layer in ipairs(self._drawables) do
        for _, obj in ipairs(layer) do
            lg.push()
                obj:draw()
            lg.pop()
        end
    end
end

function SpaceRescue:_spawn_asteroid()
    local ast = Asteroid(self._world, math.random(5, MAX_ASTEROID_RADIUS))
    if not ast then
        return
    end
    local w, h = lw.getWidth(), lw.getHeight()
    local radius = math.sqrt(w * w + h * h) + MAX_ASTEROID_RADIUS
    local theta = math.random() * 2 * math.pi
    ast:set_position(radius * math.cos(theta), radius * math.sin(theta))
    local x, y = ast:get_position()
    ast:set_direction(util.angle_towards(
        math.random() * w,
        math.random() * h,
        x,
        y
    ))
    ast:set_speed(math.random(MIN_ASTEROID_SPEED, MAX_ASTEROID_SPEED))
    ast:activate()

    table.insert(self._drawables.asteroids, ast)
end

function SpaceRescue:keypressed(key)
    if key == "a" then
        self:_spawn_asteroid()
    end
end

function SpaceRescue:keyreleased(key)
end

function SpaceRescue:mousepressed(x, y, button)
    print(x, y, button)
end

function SpaceRescue:mousereleased(x, y, button)
    print(x, y, button)
end

return SpaceRescue
