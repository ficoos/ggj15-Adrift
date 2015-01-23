local class = require 'hump.class'

local _keyName= {};

local OrderedTable= class{
    __index = function(t, name)
        if type(name)=="number" then
            return t[name]
        end
        for i, obj in ipairs(t) do
            if obj:getName() == name then
                return obj
            end
        end
    end,
}

function OrderedTable:init(name)
    self[_keyName]=name
end

function OrderedTable:getName()
    return self[_keyName]
end


return OrderedTable

