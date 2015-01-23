-- not a real uuid
local counter = 1

local util = {}

function util.uuid(class_name)
    class_name = class_name or "object"
    return class_name .. "-" .. counter .. "-generated"
end

return util
