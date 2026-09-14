-- Dereus Library 2.8.0 single-file bundle. Generated from src/.
-- The bundle targets Lua/Luau runtimes. Roblox UI modules require Roblox services.
local modules = {}
local function define(name, factory) modules[name] = factory() end
define('Registry', function()
local Registry = {}
Registry.__index = Registry

function Registry.new()
    return setmetatable({ Items = {}, Connections = {}, Tasks = {}, Destroyed = false }, Registry)
end

function Registry:Add(instance)
    if self.Destroyed then if instance and instance.Destroy then instance:Destroy() end; return instance end
    table.insert(self.Items, instance)
    return instance
end

function Registry:Connect(signal, callback)
    if self.Destroyed then return nil end
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function Registry:Track(taskHandle)
    if taskHandle then table.insert(self.Tasks, taskHandle) end
    return taskHandle
end

function Registry:Clear()
    for _, connection in ipairs(self.Connections) do if connection.Connected then connection:Disconnect() end end
    for _, item in ipairs(self.Items) do if item and item.Parent then item:Destroy() end end
    for _, handle in ipairs(self.Tasks) do if type(handle) == "thread" and coroutine.status(handle) ~= "dead" then task.cancel(handle) end end
    table.clear(self.Connections); table.clear(self.Items); table.clear(self.Tasks)
end

function Registry:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self:Clear()
end

return Registry

end)
define('LuaCompat', function()
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

end)
define('Dereus', function()
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Registry = modules.Registry

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

end)
define('Components', function()
local UserInputService = game:GetService("UserInputService")
local Components = {}

local function corner(parent, radius) local c = Instance.new("UICorner"); c.CornerRadius = radius or UDim.new(0, 14); c.Parent = parent; return c end
local function stroke(parent, color, transparency) local s = Instance.new("UIStroke"); s.Color = color; s.Transparency = transparency or 0.45; s.Thickness = 1; s.Parent = parent; return s end
local function register(ui, object) return ui and ui.Register and ui:Register(object) or object end

function Components.Stack(parent, props)
    props = props or {}; local frame = register(props.UI, Instance.new("Frame")); frame.Name = props.Name or "Stack"; frame.BackgroundTransparency = 1; frame.Size = props.Size or UDim2.fromScale(1, 1); frame.Parent = parent
    local layout = Instance.new("UIListLayout"); layout.Padding = props.Gap or UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.FillDirection = props.Direction or Enum.FillDirection.Vertical; layout.HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Left; layout.VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Top; layout.Parent = frame
    return frame
end

function Components.Panel(parent, theme, props)
    props = props or {}; local panel = Instance.new("Frame"); panel.Name = props.Name or "Panel"; panel.BackgroundColor3 = props.Color or theme.Surface; panel.BackgroundTransparency = props.BackgroundTransparency or 0; panel.Size = props.Size or UDim2.fromScale(1, 1); panel.LayoutOrder = props.LayoutOrder or 0; panel.Parent = parent; corner(panel, props.Radius or theme.Radius); stroke(panel, theme.Border, props.BorderTransparency)
    if props.Padding ~= false then local p = Instance.new("UIPadding"); local n = props.PaddingSize or 16; p.PaddingTop = UDim.new(0, n); p.PaddingBottom = UDim.new(0, n); p.PaddingLeft = UDim.new(0, n); p.PaddingRight = UDim.new(0, n); p.Parent = panel end
    return panel
end

function Components.Label(parent, theme, text, props)
    props = props or {}; local label = Instance.new("TextLabel"); label.Name = props.Name or "Label"; label.Text = text or ""; label.TextColor3 = props.Color or theme.Text; label.TextSize = props.TextSize or 14; label.Font = props.Font or Enum.Font.GothamMedium; label.BackgroundTransparency = 1; label.Size = props.Size or UDim2.new(1, 0, 0, 24); label.TextXAlignment = props.Alignment or Enum.TextXAlignment.Left; label.TextYAlignment = props.VerticalAlignment or Enum.TextYAlignment.Center; label.TextWrapped = props.Wrapped == true; label.Parent = parent; return label
end

function Components.Button(parent, ui, text, callback, props)
    props = props or {}; local button = Instance.new("TextButton"); button.Name = props.Name or "Button"; button.Text = text or "Button"; button.AutoButtonColor = false; button.BackgroundColor3 = props.Color or ui.Theme.Primary; button.TextColor3 = props.TextColor or ui.Theme.PrimaryForeground; button.TextSize = props.TextSize or 14; button.Font = props.Font or Enum.Font.GothamBold; button.Size = props.Size or UDim2.new(1, 0, 0, 42); button.Activated:Connect(function() if callback then callback(button) end end); button.Parent = parent; corner(button, props.Radius or ui.Theme.Radius)
    local normal = button.BackgroundColor3; local hover = props.HoverColor or ui.Theme.SurfaceHover; local press = ui.Motion and ui.Motion.Press(button) or nil
    ui:Connect(button.MouseEnter, function() ui:Tween(button, { BackgroundColor3 = hover }, 0.16) end); ui:Connect(button.MouseLeave, function() ui:Tween(button, { BackgroundColor3 = normal }, 0.2) end); ui:Connect(button.InputBegan, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then if press then press.Down() end end end); ui:Connect(button.InputEnded, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then if press then press.Up() end end end)
    return button
end

function Components.Input(parent, ui, placeholder, callback, props)
    props = props or {}; local input = Instance.new("TextBox"); input.Name = props.Name or "Input"; input.PlaceholderText = placeholder or "Type here"; input.Text = props.Text or ""; input.ClearTextOnFocus = false; input.TextColor3 = ui.Theme.Text; input.PlaceholderColor3 = ui.Theme.Muted; input.TextSize = props.TextSize or 14; input.Font = Enum.Font.Gotham; input.BackgroundColor3 = ui.Theme.Background; input.Size = props.Size or UDim2.new(1, 0, 0, 42); input.Parent = parent; corner(input, props.Radius or ui.Theme.Radius); stroke(input, ui.Theme.Border); ui:Connect(input.FocusLost, function(enterPressed) if callback then callback(input.Text, enterPressed, input) end end); return input
end

function Components.Section(parent, theme, title) return Components.Label(parent, theme, string.upper(title or "SECTION"), { TextSize = 11, Color = theme.Muted, Font = Enum.Font.GothamBold }) end

function Components.Toggle(parent, ui, label, default, callback, props)
    props = props or {}; local row = Instance.new("TextButton"); row.Name = props.Name or "Toggle"; row.AutoButtonColor = false; row.Text = label or "Toggle"; row.TextColor3 = ui.Theme.Text; row.TextSize = 14; row.Font = Enum.Font.GothamMedium; row.TextXAlignment = Enum.TextXAlignment.Left; row.BackgroundColor3 = ui.Theme.Surface; row.Size = props.Size or UDim2.new(1, 0, 0, 42); row.Parent = parent; corner(row, ui.Theme.Radius)
    local enabled = default == true; local indicator = Instance.new("Frame"); indicator.AnchorPoint = Vector2.new(1, 0.5); indicator.Position = UDim2.new(1, -12, 0.5, 0); indicator.Size = UDim2.fromOffset(34, 18); indicator.BackgroundColor3 = enabled and ui.Theme.Primary or ui.Theme.Background; indicator.Parent = row; corner(indicator, UDim.new(1, 0))
    local function set(value) enabled = value == true; ui:Tween(indicator, { BackgroundColor3 = enabled and ui.Theme.Primary or ui.Theme.Background }, 0.2); if callback then callback(enabled) end end
    ui:Connect(row.Activated, function() set(not enabled) end); row.Set = set; row.Get = function() return enabled end; return row
end

function Components.Slider(parent, ui, label, min, max, default, callback, props)
    props = props or {}; assert(max > min, "Slider max must be greater than min"); local holder = Instance.new("Frame"); holder.Name = props.Name or "Slider"; holder.BackgroundTransparency = 1; holder.Size = props.Size or UDim2.new(1, 0, 0, 54); holder.Parent = parent; Components.Label(holder, ui.Theme, label, { Size = UDim2.new(1, -50, 0, 22) }); local value = Components.Label(holder, ui.Theme, "", { Size = UDim2.fromOffset(48, 22), Alignment = Enum.TextXAlignment.Right, Color = ui.Theme.Primary, Font = Enum.Font.GothamBold }); value.Position = UDim2.new(1, -48, 0, 0)
    local bar = Instance.new("TextButton"); bar.Name = "Track"; bar.Text = ""; bar.AutoButtonColor = false; bar.Position = UDim2.fromOffset(0, 30); bar.Size = UDim2.new(1, 0, 0, 8); bar.BackgroundColor3 = ui.Theme.Surface; bar.Parent = holder; corner(bar, UDim.new(1, 0)); local fill = Instance.new("Frame"); fill.BackgroundColor3 = ui.Theme.Primary; fill.Size = UDim2.fromScale(0, 1); fill.Parent = bar; corner(fill, UDim.new(1, 0))
    local current = math.clamp(default or min, min, max); local dragging = false
    local function setValue(nextValue, fire) current = math.clamp(nextValue, min, max); local alpha = (current - min) / (max - min); fill.Size = UDim2.fromScale(alpha, 1); value.Text = tostring(math.floor(current + 0.5)); if fire and callback then callback(current) end end
    local function fromInput(input) setValue(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1), true) end
    ui:Connect(bar.InputBegan, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; fromInput(input) end end); ui:Connect(UserInputService.InputChanged, function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then fromInput(input) end end); ui:Connect(UserInputService.InputEnded, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end); setValue(current, false); holder.Set = function(v) setValue(v, true) end; holder.Get = function() return current end; return holder
end

function Components.Divider(parent, theme, props)
    props = props or {}
    local divider = Instance.new("Frame")
    divider.Name = props.Name or "Divider"
    divider.BackgroundColor3 = props.Color or theme.Border
    divider.BackgroundTransparency = props.Transparency or 0.25
    divider.BorderSizePixel = 0
    divider.Size = props.Size or UDim2.new(1, 0, 0, 1)
    divider.LayoutOrder = props.LayoutOrder or 0
    divider.Parent = parent
    return divider
end

function Components.Badge(parent, ui, text, props)
    props = props or {}
    local badge = Instance.new("TextLabel")
    badge.Name = props.Name or "Badge"
    badge.Text = text or "NEW"
    badge.TextSize = props.TextSize or 10
    badge.Font = Enum.Font.GothamBold
    badge.TextColor3 = props.TextColor or ui.Theme.PrimaryForeground
    badge.BackgroundColor3 = props.Color or ui.Theme.Primary
    badge.Size = props.Size or UDim2.fromOffset(54, 22)
    badge.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = badge
    return badge
end

function Components.Search(parent, ui, placeholder, callback, props)
    props = props or {}
    local input = Components.Input(parent, ui, placeholder or "Search", function(text, enterPressed, field)
        if callback then callback(text, enterPressed, field) end
    end, props)
    input.Name = props.Name or "Search"
    return input
end

return Components

end)
define('Motion', function()
local TweenService = game:GetService("TweenService")
local Motion = {}
Motion.Eases = { Smooth = Enum.EasingStyle.Quint, Spring = Enum.EasingStyle.Back, Soft = Enum.EasingStyle.Sine, Linear = Enum.EasingStyle.Linear }

local function info(options)
    options = options or {}
    return TweenInfo.new(options.Duration or 0.45, options.Style or Motion.Eases.Smooth, options.Direction or Enum.EasingDirection.Out, options.RepeatCount or 0, options.Reverses or false, options.DelayTime or 0)
end

function Motion.Play(instance, properties, options)
    if not instance or not instance.Parent then return nil end
    local tween = TweenService:Create(instance, info(options), properties)
    tween:Play()
    return tween
end

function Motion.Enter(instance, options)
    options = options or {}
    local original = instance.Position
    local offset = options.Offset or 22
    instance.Position = original + UDim2.fromOffset(0, offset)
    local properties = { Position = original }
    if options.Fade ~= false and instance:IsA("GuiObject") then
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then instance.TextTransparency = 1; properties.TextTransparency = 0 end
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then instance.ImageTransparency = 1; properties.ImageTransparency = 0 end
        if instance:IsA("Frame") then instance.BackgroundTransparency = 1; properties.BackgroundTransparency = options.BackgroundTransparency or 0 end
    end
    return Motion.Play(instance, properties, options)
end

function Motion.Exit(instance, options)
    options = options or {}
    local target = instance.Position + UDim2.fromOffset(0, options.Offset or 22)
    local properties = { Position = target }
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then properties.TextTransparency = 1 end
    if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then properties.ImageTransparency = 1 end
    if instance:IsA("Frame") then properties.BackgroundTransparency = 1 end
    return Motion.Play(instance, properties, options)
end

function Motion.Press(instance, scale)
    scale = scale or 0.97
    local original = instance.Size
    local down = UDim2.new(original.X.Scale * scale, original.X.Offset * scale, original.Y.Scale * scale, original.Y.Offset * scale)
    return {
        Down = function() return Motion.Play(instance, { Size = down }, { Duration = 0.12, Style = Enum.EasingStyle.Quad }) end,
        Up = function() return Motion.Play(instance, { Size = original }, { Duration = 0.2, Style = Motion.Eases.Spring }) end,
    }
end

function Motion.Stagger(instances, options)
    options = options or {}
    local delay = options.Stagger or 0.06
    for index, instance in ipairs(instances) do
        task.delay((index - 1) * delay, function()
            if instance and instance.Parent then Motion.Enter(instance, options) end
        end)
    end
end

function Motion.Sequence(steps)
    local sequence = {}
    function sequence:Play()
        for _, step in ipairs(steps or {}) do
            if step.Wait then task.wait(step.Wait) elseif step.Instance then Motion.Play(step.Instance, step.Properties or {}, step.Options) end
        end
    end
    return sequence
end

function Motion.Pulse(instance, options)
    options = options or {}
    local original = instance.Size
    local amount = options.Amount or 0.025
    local enlarged = UDim2.new(original.X.Scale * (1 + amount), original.X.Offset, original.Y.Scale * (1 + amount), original.Y.Offset)
    return Motion.Play(instance, { Size = enlarged }, { Duration = options.Duration or 0.22, Style = Motion.Eases.Soft, RepeatCount = options.RepeatCount or 1, Reverses = true })
end

function Motion.Breathe(instance, options)
    options = options or {}
    local original = instance.BackgroundTransparency
    local target = math.clamp(original + (options.Amount or 0.08), 0, 1)
    return Motion.Play(instance, { BackgroundTransparency = target }, { Duration = options.Duration or 1.2, Style = Motion.Eases.Soft, RepeatCount = options.RepeatCount or 1, Reverses = true })
end

function Motion.Shake(instance, options)
    options = options or {}
    local original = instance.Position
    local amount = options.Amount or 6
    local sequence = Motion.Sequence({
        { Instance = instance, Properties = { Position = original + UDim2.fromOffset(-amount, 0) }, Options = { Duration = 0.05, Style = Enum.EasingStyle.Quad } },
        { Instance = instance, Properties = { Position = original + UDim2.fromOffset(amount, 0) }, Options = { Duration = 0.05, Style = Enum.EasingStyle.Quad } },
        { Instance = instance, Properties = { Position = original }, Options = { Duration = 0.08, Style = Enum.EasingStyle.Quad } },
    })
    task.spawn(function() sequence:Play() end)
    return sequence
end

function Motion.Hover(instance, ui, options)
    options = options or {}
    local normal = instance.BackgroundColor3
    local hover = options.Color or ui.Theme.SurfaceHover
    return {
        Connect = function()
            local enter = ui:Connect(instance.MouseEnter, function() ui:Tween(instance, { BackgroundColor3 = hover }, options.Duration or 0.16) end)
            local leave = ui:Connect(instance.MouseLeave, function() ui:Tween(instance, { BackgroundColor3 = normal }, options.Duration or 0.2) end)
            return enter, leave
        end,
    }
end

function Motion.Fade(instance, transparency, options)
    options = options or {}
    local properties = {}
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then properties.TextTransparency = transparency end
    if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then properties.ImageTransparency = transparency end
    if instance:IsA("GuiObject") and not next(properties) then properties.BackgroundTransparency = transparency end
    return Motion.Play(instance, properties, options)
end

function Motion.Wipe(instance, options)
    options = options or {}
    local original = instance.Size
    instance.Size = UDim2.new(0, 0, original.Y.Scale, original.Y.Offset)
    return Motion.Play(instance, { Size = original }, { Duration = options.Duration or 0.5, Style = options.Style or Motion.Eases.Smooth })
end

function Motion.Bounce(instance, options)
    options = options or {}
    local original = instance.Position
    local lift = original + UDim2.fromOffset(0, -(options.Amount or 12))
    local sequence = Motion.Sequence({
        { Instance = instance, Properties = { Position = lift }, Options = { Duration = 0.18, Style = Motion.Eases.Spring } },
        { Instance = instance, Properties = { Position = original }, Options = { Duration = 0.28, Style = Motion.Eases.Spring } },
    })
    task.spawn(function() sequence:Play() end)
    return sequence
end

return Motion

end)
define('Notify', function()
local Notify = {}

function Notify.new(ui, title, message, options)
    options = options or {}; ui._notifications = ui._notifications or {}
    local frame = Instance.new("Frame"); frame.Name = "Notification"; frame.AnchorPoint = Vector2.new(1, 1); frame.Position = UDim2.new(1, 380, 1, -24); frame.Size = UDim2.fromOffset(options.Width or 320, options.Height or 76); frame.BackgroundColor3 = options.Color or ui.Theme.Surface; frame.Parent = ui.Gui; ui:Register(frame)
    local corner = Instance.new("UICorner"); corner.CornerRadius = ui.Theme.Radius; corner.Parent = frame; local line = Instance.new("UIStroke"); line.Color = options.AccentColor or ui.Theme.Primary; line.Transparency = 0.25; line.Parent = frame
    local titleLabel = Instance.new("TextLabel"); titleLabel.Text = title or "Dereus"; titleLabel.TextColor3 = ui.Theme.Text; titleLabel.TextSize = 15; titleLabel.Font = Enum.Font.GothamBold; titleLabel.BackgroundTransparency = 1; titleLabel.Position = UDim2.fromOffset(16, 11); titleLabel.Size = UDim2.new(1, -32, 0, 22); titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = frame
    local body = Instance.new("TextLabel"); body.Text = message or ""; body.TextColor3 = ui.Theme.Muted; body.TextSize = 12; body.Font = Enum.Font.Gotham; body.BackgroundTransparency = 1; body.Position = UDim2.fromOffset(16, 36); body.Size = UDim2.new(1, -32, 0, 28); body.TextWrapped = true; body.TextXAlignment = Enum.TextXAlignment.Left; body.Parent = frame
    table.insert(ui._notifications, frame)
    local function rearrange() for index, item in ipairs(ui._notifications) do if item and item.Parent then ui:Tween(item, { Position = UDim2.new(1, -24, 1, -24 - (index - 1) * ((options.Height or 76) + 10)) }, 0.25) end end end
    rearrange()
    local closed = false; local function close() if closed then return end; closed = true; ui:Tween(frame, { Position = UDim2.new(1, 380, 1, frame.Position.Y.Offset) }, 0.25); task.delay(0.3, function() for i, item in ipairs(ui._notifications) do if item == frame then table.remove(ui._notifications, i); break end end; if frame.Parent then frame:Destroy() end; rearrange() end) end
    task.delay(options.Duration or 4, close); frame.Close = close; return frame
end

return Notify

end)
define('Window', function()
local Window = {}
Window.__index = Window
local function corner(parent, radius) local c = Instance.new("UICorner"); c.CornerRadius = radius; c.Parent = parent end
local function stroke(parent, color) local s = Instance.new("UIStroke"); s.Color = color; s.Transparency = 0.45; s.Parent = parent end

function Window.new(ui, options)
    options = options or {}; local self = setmetatable({ UI = ui, Tabs = {}, ActiveTab = nil, _destroyed = false }, Window)
    local root = Instance.new("Frame"); root.Name = options.Name or "Window"; root.Size = options.Size or UDim2.fromOffset(560, 390); root.Position = options.Position or UDim2.new(0.5, -280, 0.5, -195); root.AnchorPoint = options.AnchorPoint or Vector2.zero; root.BackgroundColor3 = ui.Theme.Background; root.ClipsDescendants = true; root.Parent = ui.Gui; corner(root, ui.Theme.Radius); stroke(root, ui.Theme.Border); ui:Register(root); self.Root = root
    local title = Instance.new("TextLabel"); title.BackgroundTransparency = 1; title.Size = UDim2.new(1, -32, 0, 30); title.Position = UDim2.fromOffset(16, 10); title.Text = options.Title or "Dereus UI"; title.TextColor3 = ui.Theme.Text; title.TextSize = 20; title.Font = Enum.Font.GothamBold; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = root; self.Title = title
    if options.Subtitle then local subtitle = Instance.new("TextLabel"); subtitle.BackgroundTransparency = 1; subtitle.Size = UDim2.new(1, -32, 0, 18); subtitle.Position = UDim2.fromOffset(16, 36); subtitle.Text = options.Subtitle; subtitle.TextColor3 = ui.Theme.Muted; subtitle.TextSize = 12; subtitle.Font = Enum.Font.Gotham; subtitle.TextXAlignment = Enum.TextXAlignment.Left; subtitle.Parent = root; self.Subtitle = subtitle end
    local top = options.Subtitle and 64 or 50; self.TabBar = Instance.new("Frame"); self.TabBar.BackgroundTransparency = 1; self.TabBar.Position = UDim2.fromOffset(16, top); self.TabBar.Size = UDim2.new(1, -32, 0, 36); self.TabBar.Parent = root; local tabLayout = Instance.new("UIListLayout"); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0, 8); tabLayout.Parent = self.TabBar
    self.Pages = Instance.new("Frame"); self.Pages.BackgroundTransparency = 1; self.Pages.Position = UDim2.fromOffset(16, top + 46); self.Pages.Size = UDim2.new(1, -32, 1, -(top + 62)); self.Pages.Parent = root; return self
end

function Window:AddTab(name, icon)
    assert(not self._destroyed, "Cannot add a tab to a destroyed window"); local page = Instance.new("ScrollingFrame"); page.Name = name; page.BackgroundTransparency = 1; page.Size = UDim2.fromScale(1, 1); page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.CanvasSize = UDim2.new(); page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = self.UI.Theme.Primary; page.Visible = false; page.Parent = self.Pages
    local padding = Instance.new("UIPadding"); padding.PaddingRight = UDim.new(0, 8); padding.Parent = page; local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = page
    local button = Instance.new("TextButton"); button.AutoButtonColor = false; button.Text = (icon and icon .. "  " or "") .. name; button.TextSize = 13; button.Font = Enum.Font.GothamMedium; button.TextColor3 = self.UI.Theme.Muted; button.BackgroundColor3 = self.UI.Theme.Surface; button.Size = UDim2.fromOffset(110, 34); button.Parent = self.TabBar; corner(button, self.UI.Theme.Radius)
    local tab = { Name = name, Page = page, Button = button, Window = self }; table.insert(self.Tabs, tab); self.UI:Connect(button.Activated, function() self:SelectTab(tab) end); if not self.ActiveTab then self:SelectTab(tab) end; return tab
end

function Window:SelectTab(tab)
    if not tab then return end; self.ActiveTab = tab
    for _, item in ipairs(self.Tabs) do local active = item == tab; item.Page.Visible = active; self.UI:Tween(item.Button, { BackgroundColor3 = active and self.UI.Theme.Primary or self.UI.Theme.Surface, TextColor3 = active and self.UI.Theme.PrimaryForeground or self.UI.Theme.Muted }, 0.18) end
end

function Window:SetTitle(title) if self.Title then self.Title.Text = title end end
function Window:Destroy() self._destroyed = true; if self.Root and self.Root.Parent then self.Root:Destroy() end end
return Window

end)
define('Style', function()
local Style = {}

function Style.Corner(instance, radius)
    local corner = instance:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 14)
    corner.Parent = instance
    return corner
end

function Style.Stroke(instance, color, transparency, thickness)
    local stroke = instance:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.Color = color or Color3.new(1, 1, 1)
    stroke.Transparency = transparency == nil and 0.45 or transparency
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

function Style.Gradient(instance, colorA, colorB, rotation)
    local gradient = instance:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colorA or Color3.new(1, 1, 1), colorB or Color3.new(0.7, 0.7, 0.7))
    gradient.Rotation = rotation or 90
    gradient.Parent = instance
    return gradient
end

function Style.Shadow(instance, color, transparency, size)
    local shadow = instance:FindFirstChild("DereusShadow") or Instance.new("ImageLabel")
    shadow.Name = "DereusShadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, size or 24, 1, size or 24)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = color or Color3.new(0, 0, 0)
    shadow.ImageTransparency = transparency == nil and 0.65 or transparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = math.max(instance.ZIndex - 1, 0)
    shadow.Parent = instance
    return shadow
end

function Style.Surface(instance, theme, options)
    options = options or {}
    instance.BackgroundColor3 = options.Color or theme.Surface
    instance.BackgroundTransparency = options.Transparency or 0
    Style.Corner(instance, options.Radius or theme.Radius)
    Style.Stroke(instance, options.BorderColor or theme.Border, options.BorderTransparency or 0.45, options.BorderThickness or 1)
    if options.Gradient then Style.Gradient(instance, options.Gradient[1], options.Gradient[2], options.GradientRotation) end
    if options.Shadow then Style.Shadow(instance, options.ShadowColor, options.ShadowTransparency, options.ShadowSize) end
    return instance
end

function Style.Focus(instance, theme, active)
    local stroke = instance:FindFirstChild("DereusFocus") or Instance.new("UIStroke")
    stroke.Name = "DereusFocus"
    stroke.Color = theme.Primary
    stroke.Thickness = active and 2 or 1
    stroke.Transparency = active and 0.1 or 1
    stroke.Parent = instance
    return stroke
end

function Style.Glow(instance, color, transparency)
    local gradient = instance:FindFirstChild("DereusGlow") or Instance.new("UIGradient")
    gradient.Name = "DereusGlow"
    gradient.Color = ColorSequence.new(color or Color3.new(1, 1, 1))
    gradient.Transparency = NumberSequence.new(transparency == nil and 0.85 or transparency)
    gradient.Rotation = 45
    gradient.Parent = instance
    return gradient
end

return Style

end)
define('Layout', function()
local Layout = {}

function Layout.Scale(parent, options)
    options = options or {}
    local scale = parent:FindFirstChild("DereusScale") or Instance.new("UIScale")
    scale.Name = "DereusScale"
    scale.Scale = options.Scale or 1
    scale.Parent = parent
    return scale
end

function Layout.Responsive(parent, options)
    options = options or {}
    local constraint = parent:FindFirstChild("DereusSizeConstraint") or Instance.new("UISizeConstraint")
    constraint.Name = "DereusSizeConstraint"
    constraint.MinSize = options.MinSize or Vector2.new(280, 180)
    constraint.MaxSize = options.MaxSize or Vector2.new(900, 720)
    constraint.Parent = parent
    return constraint
end

function Layout.Padding(parent, amount)
    local padding = parent:FindFirstChild("DereusPadding") or Instance.new("UIPadding")
    padding.Name = "DereusPadding"
    amount = amount or 16
    padding.PaddingTop = UDim.new(0, amount)
    padding.PaddingBottom = UDim.new(0, amount)
    padding.PaddingLeft = UDim.new(0, amount)
    padding.PaddingRight = UDim.new(0, amount)
    padding.Parent = parent
    return padding
end

function Layout.Center(instance)
    instance.AnchorPoint = Vector2.new(0.5, 0.5)
    instance.Position = UDim2.fromScale(0.5, 0.5)
    return instance
end

return Layout

end)
define('Host', function()
local Host = {}

Host.Version = "1.0.0"

function Host.Resolve(options)
    options = options or {}
    if options.Parent then return options.Parent end
    if options.ParentResolver then
        local ok, result = pcall(options.ParentResolver, options.Player)
        if ok and result then return result end
    end
    local player = options.Player
    if player and player.FindFirstChild then return player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", options.Timeout or 10) end
    return nil
end

function Host.Capabilities(parent)
    return {
        HasParent = parent ~= nil,
        SupportsGui = parent ~= nil and parent.IsA ~= nil,
        SupportsInput = true,
        SupportsTween = true,
    }
end

function Host.Mount(screenGui, options)
    options = options or {}
    local parent = Host.Resolve(options)
    if not parent then return false, "No GUI parent was provided or resolved" end
    if options.AutoCleanup ~= false and options.Name then
        local existing = parent:FindFirstChild(options.Name)
        if existing and existing ~= screenGui then existing:Destroy() end
    end
    if options.Name then screenGui.Name = options.Name end
    screenGui.Parent = parent
    return true, parent
end

function Host.Cleanup(parent, name)
    if not parent or not name then return false end
    local existing = parent:FindFirstChild(name)
    if existing then existing:Destroy(); return true end
    return false
end

return Host

end)
define('Cinematic', function()
local Cinematic = {}
Cinematic.__index = Cinematic

function Cinematic.new(ui, options)
    local self = setmetatable({ UI = ui, Steps = {}, Skipped = false, Playing = false }, Cinematic)
    self.Options = options or {}
    return self
end

function Cinematic:Add(instance, properties, options)
    table.insert(self.Steps, { Instance = instance, Properties = properties or {}, Options = options or {} })
    return self
end

function Cinematic:Wait(seconds)
    table.insert(self.Steps, { Wait = seconds or 0 })
    return self
end

function Cinematic:Skip()
    self.Skipped = true
    return self
end

function Cinematic:Play(onComplete)
    self.Playing = true
    self.Skipped = false
    for _, step in ipairs(self.Steps) do
        if self.Skipped then break end
        if step.Wait then
            task.wait(step.Wait)
        elseif step.Instance and step.Instance.Parent then
            local tween = self.UI.Motion.Play(step.Instance, step.Properties, step.Options)
            if tween then tween.Completed:Wait() end
        end
    end
    self.Playing = false
    if onComplete then onComplete(self.Skipped) end
    return self
end

function Cinematic:PlayAsync(onComplete)
    task.spawn(function() self:Play(onComplete) end)
    return self
end

function Cinematic:Clear()
    table.clear(self.Steps)
    return self
end

return Cinematic

end)
define('Compatibility', function()
local Compatibility = {}

Compatibility.Version = "1.0.0"

function Compatibility.Probe(options)
    options = options or {}
    local parent = options.Parent
    local player = options.Player
    return {
        HasPlayer = player ~= nil,
        HasParent = parent ~= nil,
        HasGuiObjects = parent ~= nil and parent.IsA ~= nil,
        HasTweenService = pcall(function() return game:GetService("TweenService") end),
        HasUserInput = pcall(function() return game:GetService("UserInputService") end),
        HostName = options.HostName or "custom",
    }
end

function Compatibility.SafeCall(callback, ...)
    if type(callback) ~= "function" then return false, "callback is not callable" end
    return pcall(callback, ...)
end

function Compatibility.Adapter(options)
    options = options or {}
    local adapter = {
        Name = options.Name or "DereusAdapter",
        Parent = options.Parent,
        ResolveParent = options.ResolveParent,
        Capabilities = options.Capabilities or {},
    }
    function adapter:Resolve(player)
        if self.Parent then return self.Parent end
        if self.ResolveParent then
            local ok, parent = pcall(self.ResolveParent, player)
            if ok then return parent end
        end
        return nil
    end
    function adapter:Can(capability)
        return self.Capabilities[capability] == true
    end
    return adapter
end

function Compatibility.Mount(gui, adapter, player)
    if not gui or not adapter then return false, "gui and adapter are required" end
    local parent = adapter.Resolve and adapter:Resolve(player) or adapter.Parent
    if not parent then return false, "adapter did not resolve a parent" end
    gui.Parent = parent
    return true, parent
end

return Compatibility

end)
define('Presets', function()
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

end)
define('Diagnostics', function()
local Diagnostics = {}

Diagnostics.Version = "1.0.0"
Diagnostics.Issues = {
    MissingParent = "No se encontró un contenedor GUI. Usa Parent o ParentResolver.",
    MissingPlayer = "No se encontró Player. Ejecuta en cliente o proporciona options.Player.",
    DestroyedUI = "La instancia Dereus ya fue destruida.",
    InvalidRange = "El rango recibido no es válido.",
}

function Diagnostics.Check(ui)
    local report = { Ok = true, Issues = {}, Warnings = {}, Version = Diagnostics.Version }
    local function issue(code, detail)
        report.Ok = false
        table.insert(report.Issues, { Code = code, Message = detail or Diagnostics.Issues[code] or code })
    end
    if not ui then issue("MissingUI") return report end
    if ui:IsDestroyed and ui:IsDestroyed() then issue("DestroyedUI") end
    if not ui.Gui or not ui.Gui.Parent then issue("MissingParent") end
    if not ui.Player then issue("MissingPlayer") end
    return report
end

function Diagnostics.AssertHealthy(ui)
    local report = Diagnostics.Check(ui)
    if not report.Ok then
        local messages = {}
        for _, issue in ipairs(report.Issues) do table.insert(messages, issue.Code .. ": " .. issue.Message) end
        error("Dereus diagnostics failed - " .. table.concat(messages, " | "), 2)
    end
    return true, report
end

function Diagnostics.Clamp(value, minimum, maximum, fallback)
    if type(value) ~= "number" or type(minimum) ~= "number" or type(maximum) ~= "number" or maximum < minimum then
        return fallback or minimum
    end
    return math.clamp(value, minimum, maximum)
end

function Diagnostics.Try(label, callback, onError)
    local ok, result = pcall(callback)
    if not ok and onError then onError(label, result) end
    return ok, result
end

function Diagnostics.FormatError(prefix, errorMessage)
    return string.format("[%s] %s", prefix or "Dereus", tostring(errorMessage))
end

return Diagnostics

end)
define('Store', function()
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

end)
local Dereus = modules.Dereus
Dereus.Components = modules.Components
Dereus.Window = modules.Window
Dereus.Motion = modules.Motion
Dereus.Notify = modules.Notify
Dereus.Style = modules.Style
Dereus.Layout = modules.Layout
Dereus.Host = modules.Host
Dereus.Cinematic = modules.Cinematic
Dereus.Compatibility = modules.Compatibility
Dereus.Presets = modules.Presets
Dereus.Diagnostics = modules.Diagnostics
Dereus.Registry = modules.Registry
Dereus.Store = modules.Store
Dereus.LuaCompat = modules.LuaCompat
Dereus.LibraryName = "Dereus Library"
Dereus.VERSION = Dereus.Version
return Dereus
