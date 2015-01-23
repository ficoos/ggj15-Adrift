local class = require 'hump.class'
local util = require 'util'

local _keyName= {};

local OrderedTable = {
    __index = function(t, name)
        for i, obj in ipairs(t) do
            if obj:getName() == name then
                return obj
            end
        end
    end,

}

function OrderedTable_new(name)
    local self = {
        getName = function (self)
            return self[_keyName]
        end,
        remove = function (self, other)
            for i, obj in ipairs(self) do
                if obj == other then
                    return table.remove(self, i)
                end
            end
        end,
    }
    self[_keyName] = name or util.uuid("OrderedTable")
    self = setmetatable(self, OrderedTable)
    return self
end


return OrderedTable_new

