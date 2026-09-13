local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Dereus = {}
Dereus.__index = Dereus
Dereus.Version = "2.0.0"
Dereus.Theme = {
    Background = Color3.fromRGB(18, 20, 29),
    Surface = Color3.fromRGB(27, 30, 42),
    SurfaceHover = Color3.fromRGB(37, 41, 56),
    Primary = Color3.fromRGB(183, 255, 84),
    Text = Color3.fromRGB(245, 247, 250),
    Muted = Color3.fromRGB(157, 163, 177),
    Border = Color3.fromRGB(58, 63, 82),
    Radius = UDim.new(0, 14),
}

local function create(className, properties)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do object[key] = value end
    return object
end

function Dereus.new(options)
    options = options or {}
    local self = setmetatable({
        _connections = {},
        _instances = {},
        Theme = options.Theme or table.clone(Dereus.Theme),
        Player = Players.LocalPlayer,
    }, Dereus)
    self.Gui = create("ScreenGui", { Name = options.Name or "DereusUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    self.Gui.Parent = self.Player:WaitForChild("PlayerGui")
    return self
end

function Dereus:Register(instance)
    table.insert(self._instances, instance)
    return instance
end

function Dereus:Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self._connections, connection)
    return connection
end

function Dereus:Tween(instance, properties, duration, style)
    local tween = TweenService:Create(instance, TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

function Dereus:Destroy()
    for _, connection in ipairs(self._connections) do connection:Disconnect() end
    for _, instance in ipairs(self._instances) do if instance and instance.Parent then instance:Destroy() end end
    if self.Gui then self.Gui:Destroy() end
    table.clear(self._connections); table.clear(self._instances)
end

return Dereus
