-- not a real uuid
local counter = 1

local util = {}

function util.uuid()
    return "object-" .. counter .. "-generated"
end

return util
