local lg = love.graphics

local SpaceRescue = {}

function SpaceRescue:draw()
    lg.print("Space Poop", 200, 200)
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
