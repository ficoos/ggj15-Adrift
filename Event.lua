local Class = require("hump.class")

local Event = Class{}

function Event:init()
    self._callbacks = {}
end

function Event:__call(f)
    self._callbacks[f] = true
end

function Event:unergister(f)
    self._callbacks[f] = nil
end

function Event:emit(...)
    for cb, _ in pairs(self._callbacks) do
        cb(...)
    end
end

return Event
