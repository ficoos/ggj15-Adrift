-- not a real uuid
local counter = 0

local util = {}

function util.uuid(class_name)
    class_name = class_name or "object"
    counter = counter + 1
    return class_name .. "-" .. counter .. "-generated"
end

return util
