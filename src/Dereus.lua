local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Dereus = {}
Dereus.__index = Dereus
Dereus.Version = "2.5.0"
Dereus.Theme = {
    Background = Color3.fromRGB(18, 20, 29),
    Surface = Color3.fromRGB(27, 30, 42),
    SurfaceHover = Color3.fromRGB(37, 41, 56),
    Primary = Color3.fromRGB(183, 255, 84),
    PrimaryForeground = Color3.fromRGB(24, 31, 18),
    Text = Color3.fromRGB(245, 247, 250),
    Muted = Color3.fromRGB(157, 163, 177),
    Border = Color3.fromRGB(58, 63, 82),
    Danger = Color3.fromRGB(255, 102, 120),
    Radius = UDim.new(0, 14),
}

local function copyTheme(source)
    local result = {}
    for key, value in pairs(Dereus.Theme) do result[key] = value end
    for key, value in pairs(source or {}) do result[key] = value end
    return result
end

local function create(className, properties)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do object[key] = value end
    return object
end

local function resolveParent(options, player)
    if options.Parent then return options.Parent end
    if options.ParentResolver then
        local ok, parent = pcall(options.ParentResolver, player)
        if ok and parent then return parent end
    end
    return player:WaitForChild("PlayerGui", options.ParentTimeout or 10)
end

function Dereus.new(options)
    options = options or {}
    local player = options.Player or Players.LocalPlayer
    assert(player, "Dereus.new must run on the client or receive options.Player")
    local self = setmetatable({
        _connections = {},
        _instances = {},
        _destroyed = false,
        Theme = copyTheme(options.Theme),
        Player = player,
        Options = options,
        Motion = Dereus.Motion,
        Style = Dereus.Style,
        Layout = Dereus.Layout,
        Host = Dereus.Host,
        Cinematic = Dereus.Cinematic,
        Compatibility = Dereus.Compatibility,
        Presets = Dereus.Presets,
    }, Dereus)
    self.Gui = create("ScreenGui", {
        Name = options.Name or "DereusUI",
        ResetOnSpawn = options.ResetOnSpawn == true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = options.IgnoreGuiInset == true,
        DisplayOrder = options.DisplayOrder or 10,
    })
    self.Gui.Parent = resolveParent(options, player)
    return self
end

function Dereus:IsDestroyed() return self._destroyed end

function Dereus:Register(instance)
    if self._destroyed then instance:Destroy(); return instance end
    table.insert(self._instances, instance)
    return instance
end

function Dereus:Connect(signal, callback)
    assert(not self._destroyed, "Cannot connect on a destroyed Dereus instance")
    local connection = signal:Connect(callback)
    table.insert(self._connections, connection)
    return connection
end

function Dereus:Tween(instance, properties, duration, style, direction)
    if not instance or not instance.Parent then return nil end
    local tween = TweenService:Create(instance, TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    ), properties)
    tween:Play()
    return tween
end

function Dereus:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    for _, connection in ipairs(self._connections) do
        if connection.Connected then connection:Disconnect() end
    end
    for _, instance in ipairs(self._instances) do
        if instance and instance.Parent then instance:Destroy() end
    end
    if self.Gui then self.Gui:Destroy() end
    table.clear(self._connections)
    table.clear(self._instances)
end

return Dereus
