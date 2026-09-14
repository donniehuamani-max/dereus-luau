local LuaCompat = {}

LuaCompat.Name = "Dereus Library"
LuaCompat.Version = "1.0.0"

function LuaCompat.IsLuau()
    return type(table.clear) == "function" or type(task) == "table"
end

function LuaCompat.IsRoblox()
    return type(Instance) == "table" or type(game) == "userdata" or type(game) == "table"
end

function LuaCompat.Runtime()
    if LuaCompat.IsRoblox() then return "roblox-luau" end
    if LuaCompat.IsLuau() then return "luau" end
    return "lua"
end

function LuaCompat.Clone(source)
    local result = {}
    for key, value in pairs(source or {}) do
        if type(value) == "table" then result[key] = LuaCompat.Clone(value) else result[key] = value end
    end
    return result
end

function LuaCompat.Merge(base, overrides)
    local result = LuaCompat.Clone(base)
    for key, value in pairs(overrides or {}) do
        if type(value) == "table" and type(result[key]) == "table" then result[key] = LuaCompat.Merge(result[key], value) else result[key] = value end
    end
    return result
end

function LuaCompat.Clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

function LuaCompat.SafeCall(callback, ...)
    if type(callback) ~= "function" then return false, "callback is not a function" end
    return pcall(callback, ...)
end

function LuaCompat.Noop() end

return LuaCompat
