local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Registry = require(script.Registry)

local Dereus = {}
Dereus.__index = Dereus
Dereus.Version = "2.8.0"
Dereus.LibraryName = "Dereus Library"
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
        _registry = Registry.new(),
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
        Diagnostics = Dereus.Diagnostics,
        Registry = Dereus.Registry,
        Store = Dereus.Store,
        LuaCompat = Dereus.LuaCompat,
        LibraryName = Dereus.LibraryName,
    }, Dereus)
    self.Gui = create("ScreenGui", {
        Name = options.Name or "DereusUI",
        ResetOnSpawn = options.ResetOnSpawn == true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = options.IgnoreGuiInset == true,
        DisplayOrder = options.DisplayOrder or 10,
    })
    if options.AutoCleanup ~= false then
        local parent = resolveParent(options, player)
        if parent and options.Name then
            local previous = parent:FindFirstChild(options.Name)
            if previous then previous:Destroy() end
        end
    end
    self.Gui.Parent = resolveParent(options, player)
    return self
end

function Dereus:IsDestroyed() return self._destroyed end

function Dereus:Register(instance)
    if self._destroyed then if instance and instance.Destroy then instance:Destroy() end; return instance end
    self._registry:Add(instance)
    table.insert(self._instances, instance)
    return instance
end

function Dereus:Connect(signal, callback)
    assert(not self._destroyed, "Cannot connect on a destroyed Dereus instance")
    local connection = self._registry:Connect(signal, callback)
    table.insert(self._connections, connection)
    return connection
end

function Dereus:Track(handle)
    return self._registry:Track(handle)
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

function Dereus:Try(label, callback, onError)
    local ok, result = pcall(callback)
    if not ok and onError then onError(label, result) end
    return ok, result
end

function Dereus:Clamp(value, minimum, maximum, fallback)
    if type(value) ~= "number" or type(minimum) ~= "number" or type(maximum) ~= "number" or maximum < minimum then return fallback or minimum end
    return math.clamp(value, minimum, maximum)
end

function Dereus:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    self._registry:Destroy()
    if self.Gui then self.Gui:Destroy() end
    table.clear(self._connections)
    table.clear(self._instances)
end

return Dereus
