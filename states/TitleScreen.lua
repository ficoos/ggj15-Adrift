local GameState = require 'hump.gamestate'
local SpaceRescue = require 'states.SpaceRescue'

local lg = love.graphics
local lw = love.window

local TitleScreen = {}
local bg

local layer1 = lg.newImage("data/gfx/layer1.jpg")
layer1:setWrap("repeat", "repeat")
local layer2 = lg.newImage("data/gfx/layer2.png")
layer2:setWrap("repeat", "repeat")
local layer3 = lg.newImage("data/gfx/layer3.jpg")

local TITLE_FONT = lg.newFont("michroma.ttf", 64)
local CREDIT_FONT = lg.newFont("michroma.ttf", 26)
local START_FONT = lg.newFont("michroma.ttf", 20)

function TitleScreen:enter()
    lg.setBackgroundColor(1, 0, 32)
end

function TitleScreen:mousepressed(x, y, button)
    if button == "l" then
        GameState.switch(SpaceRescue)
    end
end
function TitleScreen:keypressed(key)
    if key == "f11" then
        lw.setFullscreen(not lw.getFullscreen(), "desktop")
    end
end

function TitleScreen:draw()
    local off_x, off_y = 30, 30
    local scale1 = 1 ^ 0.2
    local scale2 = 1 ^ 0.03
    local quad1 = lg.newQuad(
        off_x / scale1 / 6 - (lw.getWidth() / scale1) / 2,
        off_y / scale1 / 6 - (lw.getHeight() / scale1) / 2,
        lg.getWidth() / scale1, lg.getHeight() / scale1,
        layer1:getWidth(),
        layer1:getHeight()
    )
    local quad2 = lg.newQuad(
        off_x / scale2 / 32 - (lw.getWidth() / scale2) / 2,
        off_y / scale2 / 32 - (lw.getHeight() / scale2) / 2,
        lg.getWidth() / scale2 , lg.getHeight() / scale2,
        layer2:getWidth(),
        layer2:getHeight()
    )
    lg.setColor(255, 255, 255, 80)
    lg.draw(layer3,
        -off_x / scale1 / 100,
        -off_y / scale1 / 100
    )
    lg.setColor(255, 255, 255, 255)
    lg.draw(layer2, quad2, 0, 0, 0, scale2)
    lg.setBlendMode("additive")
    lg.setColor(255, 255, 255, 0.15 * 255)
    lg.draw(layer1, quad1, 0, 0, 0, scale1)
    lg.setBlendMode("alpha")

    lg.setFont(TITLE_FONT)
    lg.setColor(255, 255, 255, 255)
    lg.printf("ADRIFT", 0, lw.getHeight() * 0.2, lw.getWidth(), "center")
    lg.setFont(CREDIT_FONT)
    lg.printf("Opher Vishnia - Saggi Mizrahi - Lilac Harel", 0, lw.getHeight() * 0.35, lw.getWidth(), "center")
    lg.setFont(START_FONT)
    lg.printf("Click to Start", 0, lw.getHeight() * 0.55, lw.getWidth(), "center")
end
return TitleScreen
