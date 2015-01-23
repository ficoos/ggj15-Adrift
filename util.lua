-- not a real uuid
local counter = 0

local util = {}

function util.uuid(class_name)
    class_name = class_name or "object"
    counter = counter + 1
    return class_name .. "-" .. counter .. "-generated"
end

function util.angle_towards(fx, fy, tx, ty)
    return math.atan2(tx - fx, fy -ty) + (0.5 * math.pi)
end

function util.rotateAroundPoint(angle,centerX,centerY,point2x,point2y)
        local newX = centerX + (point2x-centerX)*math.cos(angle) - (point2y-centerY)*math.sin(angle);
        local newY = centerY + (point2x-centerX)*math.sin(angle) + (point2y-centerY)*math.cos(angle);
    return newX, newY
end

return util
