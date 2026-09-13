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
