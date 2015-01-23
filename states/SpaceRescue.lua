local Astronaut = require 'Astronaut'
local OrderedTable = require 'OrderedTable'

local lg = love.graphics
local lp = love.physics
local lm = love.mouse
local lw = love.window

local SpaceRescue = {}

local FORCE = 10000

function SpaceRescue:enter(prev, ...)
    lp.setMeter(2)
    self._world = lp.newWorld(0, 0, true)
    self._drawables = OrderedTable()


    self._drawables[1]=OrderedTable("agents")
    print(self._drawables[1],"aa")

--    local as1 = Astronaut(self._world)
--    local as2 = Astronaut(self._world)
--
--    table.insert(self._drawables.agents, as1)
--    table.insert(self._drawables.agents, as2)
--
--
--    as1:set_position(lw.getWidth()/2+100, lw.getHeight()/2)
--    as2:set_position(lw.getWidth()/2-100, lw.getHeight()/2)
end

function SpaceRescue:_push_player()
    local x, y = lm.getPosition()
    local ax, ay = self._drawables.agents[1]:get_position()
    local theta = math.atan2(x - ax, ay -y) + (0.5 * math.pi)

    local ix = -math.cos(theta) * FORCE
    local iy = -math.sin(theta) * FORCE
    self._drawables.agents[1]:apply_force(ix, iy)
end

function SpaceRescue:update(dt)
    self._world:update(dt)
    if lm.isDown("l") then
        self:_push_player()
    end
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

function SpaceRescue:keypressed(key)
    print(key)
end

function SpaceRescue:keyreleased(key)
    print(key)
end

function SpaceRescue:mousepressed(x, y, button)
    print(x, y, button)
end

function SpaceRescue:mousereleased(x, y, button)
    print(x, y, button)
end

return SpaceRescue
