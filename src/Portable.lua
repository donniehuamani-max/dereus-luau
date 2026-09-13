local Portable = {}
Portable.__index = Portable

local function copy(source)
    local result = {}
    for key, value in pairs(source or {}) do result[key] = value end
    return result
end

function Portable.new(options)
    local self = setmetatable({
        Name = (options and options.Name) or "Dereus",
        Theme = copy(options and options.Theme or {}),
        _cleanups = {},
        _destroyed = false,
    }, Portable)
    return self
end

function Portable:OnCleanup(cleanup)
    assert(type(cleanup) == "function", "cleanup must be a function")
    if self._destroyed then cleanup() else table.insert(self._cleanups, cleanup) end
    return cleanup
end

function Portable:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    for index = #self._cleanups, 1, -1 do pcall(self._cleanups[index]) end
    self._cleanups = {}
end

function Portable:IsDestroyed()
    return self._destroyed
end

return Portable
