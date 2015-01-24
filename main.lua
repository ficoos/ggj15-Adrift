-- Set the PATH
package.path = "lib/?.lua;lib/?/init.lua;" .. package.path -- libs

local lg = love.graphics

require 'strict'

class_commons = nil
common = nil
local GameState = require 'hump.gamestate'
local TitleScreen = require 'states.TitleScreen'

function love.load()
    GameState.switch(TitleScreen)
end

function love.update(dt)
    GameState.update(dt)
end

function love.draw()
    GameState:draw()
end

function love.keypressed(...)
    GameState.keypressed(...)
end

function love.keyreleased(...)
    GameState.keyreleased(...)
end

function love.mousepressed(...)
    GameState.mousepressed(...)
end

function love.mousereleased(...)
    GameState.mousereleased(...)
end
