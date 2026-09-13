local Store = {}
Store.__index = Store

function Store.new(initial)
    return setmetatable({ State = initial or {}, Subscribers = {}, Destroyed = false }, Store)
end

function Store:Get(key, fallback)
    local value = self.State[key]
    if value == nil then return fallback end
    return value
end

function Store:Set(key, value)
    if self.Destroyed then return value end
    local previous = self.State[key]
    self.State[key] = value
    if previous ~= value then
        for _, callback in ipairs(self.Subscribers) do callback(key, value, previous, self.State) end
    end
    return value
end

function Store:Patch(values)
    for key, value in pairs(values or {}) do self:Set(key, value) end
    return self
end

function Store:Subscribe(callback)
    if self.Destroyed then return function() end end
    table.insert(self.Subscribers, callback)
    local active = true
    return function()
        if not active then return end
        active = false
        for index, item in ipairs(self.Subscribers) do if item == callback then table.remove(self.Subscribers, index); break end end
    end
end

function Store:Destroy()
    self.Destroyed = true
    table.clear(self.Subscribers)
    table.clear(self.State)
end

return Store
