local Presets = {}

Presets.Midnight = {
    Background = Color3.fromRGB(14, 16, 24), Surface = Color3.fromRGB(24, 27, 39), SurfaceHover = Color3.fromRGB(38, 42, 58), Primary = Color3.fromRGB(183, 255, 84), PrimaryForeground = Color3.fromRGB(24, 31, 18), Text = Color3.fromRGB(245, 247, 250), Muted = Color3.fromRGB(157, 163, 177), Border = Color3.fromRGB(58, 63, 82), Danger = Color3.fromRGB(255, 102, 120), Radius = UDim.new(0, 14),
}

Presets.Graphite = {
    Background = Color3.fromRGB(20, 21, 24), Surface = Color3.fromRGB(32, 34, 38), SurfaceHover = Color3.fromRGB(48, 51, 57), Primary = Color3.fromRGB(112, 190, 255), PrimaryForeground = Color3.fromRGB(12, 24, 36), Text = Color3.fromRGB(246, 248, 252), Muted = Color3.fromRGB(165, 170, 180), Border = Color3.fromRGB(72, 76, 86), Danger = Color3.fromRGB(255, 110, 110), Radius = UDim.new(0, 12),
}

Presets.Light = {
    Background = Color3.fromRGB(239, 242, 247), Surface = Color3.fromRGB(255, 255, 255), SurfaceHover = Color3.fromRGB(226, 231, 240), Primary = Color3.fromRGB(45, 112, 220), PrimaryForeground = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(25, 29, 38), Muted = Color3.fromRGB(91, 99, 115), Border = Color3.fromRGB(205, 211, 222), Danger = Color3.fromRGB(205, 55, 70), Radius = UDim.new(0, 12),
}

function Presets.Merge(base, overrides)
    local theme = {}
    for key, value in pairs(base or {}) do theme[key] = value end
    for key, value in pairs(overrides or {}) do theme[key] = value end
    return theme
end

return Presets
