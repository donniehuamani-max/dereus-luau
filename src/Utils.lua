local Utils = {}

function Utils.merge(base, override)
    local result = {}
    for key, value in pairs(base or {}) do result[key] = value end
    for key, value in pairs(override or {}) do result[key] = value end
    return result
end

function Utils.clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

function Utils.map(value, fromMinimum, fromMaximum, toMinimum, toMaximum)
    local alpha = (value - fromMinimum) / (fromMaximum - fromMinimum)
    return toMinimum + (toMaximum - toMinimum) * alpha
end

function Utils.once(callback)
    local called = false
    return function(...)
        if called then return end
        called = true
        return callback(...)
    end
end

return Utils
