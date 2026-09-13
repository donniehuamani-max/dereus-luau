local Components = {}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 14)
    c.Parent = parent
end

local function stroke(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color; s.Transparency = transparency or 0.45; s.Thickness = 1
    s.Parent = parent
end

function Components.Stack(parent, props)
    local frame = Instance.new("Frame")
    frame.Name = props.Name or "Stack"; frame.BackgroundTransparency = 1; frame.Size = props.Size or UDim2.fromScale(1, 1)
    frame.Parent = parent
    local layout = Instance.new("UIListLayout")
    layout.Padding = props.Gap or UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.FillDirection = props.Direction or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Left
    layout.Parent = frame
    return frame
end

function Components.Panel(parent, theme, props)
    local panel = Instance.new("Frame")
    panel.Name = props.Name or "Panel"; panel.BackgroundColor3 = props.Color or theme.Surface; panel.Size = props.Size or UDim2.fromScale(1, 1)
    panel.Parent = parent; corner(panel, props.Radius or theme.Radius); stroke(panel, theme.Border, props.BorderTransparency)
    if props.Padding ~= false then local padding = Instance.new("UIPadding"); padding.PaddingTop = UDim.new(0, 16); padding.PaddingBottom = UDim.new(0, 16); padding.PaddingLeft = UDim.new(0, 16); padding.PaddingRight = UDim.new(0, 16); padding.Parent = panel end
    return panel
end

function Components.Label(parent, theme, text, props)
    local label = Instance.new("TextLabel")
    label.Name = props and props.Name or "Label"; label.Text = text; label.TextColor3 = props and props.Color or theme.Text; label.TextSize = props and props.TextSize or 14
    label.Font = props and props.Font or Enum.Font.GothamMedium; label.BackgroundTransparency = 1; label.Size = props and props.Size or UDim2.new(1, 0, 0, 24); label.TextXAlignment = props and props.Alignment or Enum.TextXAlignment.Left; label.Parent = parent
    return label
end

function Components.Button(parent, ui, text, callback, props)
    props = props or {}
    local button = Instance.new("TextButton")
    button.Name = props.Name or "Button"; button.Text = text; button.AutoButtonColor = false; button.BackgroundColor3 = props.Color or ui.Theme.Primary; button.TextColor3 = props.TextColor or Color3.fromRGB(24, 31, 18); button.TextSize = props.TextSize or 14; button.Font = Enum.Font.GothamBold; button.Size = props.Size or UDim2.new(1, 0, 0, 42); button.Parent = parent
    corner(button, props.Radius or ui.Theme.Radius)
    local normal = button.BackgroundColor3
    ui:Connect(button.MouseEnter, function() ui:Tween(button, {BackgroundColor3 = props.HoverColor or ui.Theme.SurfaceHover}, 0.2) end)
    ui:Connect(button.MouseLeave, function() ui:Tween(button, {BackgroundColor3 = normal}, 0.25) end)
    ui:Connect(button.MouseButton1Click, callback or function() end)
    return button
end

function Components.Input(parent, ui, placeholder, callback, props)
    props = props or {}
    local input = Instance.new("TextBox")
    input.Name = props.Name or "Input"; input.PlaceholderText = placeholder; input.Text = ""; input.ClearTextOnFocus = false; input.TextColor3 = ui.Theme.Text; input.PlaceholderColor3 = ui.Theme.Muted; input.TextSize = props.TextSize or 14; input.Font = Enum.Font.Gotham; input.BackgroundColor3 = ui.Theme.Background; input.Size = props.Size or UDim2.new(1, 0, 0, 42); input.Parent = parent
    corner(input, props.Radius or ui.Theme.Radius); stroke(input, ui.Theme.Border)
    ui:Connect(input.FocusLost, function(enterPressed) if callback then callback(input.Text, enterPressed) end end)
    return input
end

function Components.Section(parent, theme, title)
    local section = Instance.new("TextLabel")
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 24)
    section.Text = string.upper(title)
    section.TextColor3 = theme.Muted
    section.TextSize = 11
    section.Font = Enum.Font.GothamBold
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = parent
    return section
end

function Components.Toggle(parent, ui, label, default, callback)
    local row = Instance.new("TextButton")
    row.AutoButtonColor = false
    row.Text = label
    row.TextColor3 = ui.Theme.Text
    row.TextSize = 14
    row.Font = Enum.Font.GothamMedium
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.BackgroundColor3 = ui.Theme.Surface
    row.Size = UDim2.new(1, 0, 0, 42)
    row.Parent = parent
    corner(row, ui.Theme.Radius)
    local enabled = default == true
    local indicator = Instance.new("Frame")
    indicator.AnchorPoint = Vector2.new(1, 0.5)
    indicator.Position = UDim2.new(1, -12, 0.5, 0)
    indicator.Size = UDim2.fromOffset(34, 18)
    indicator.BackgroundColor3 = enabled and ui.Theme.Primary or ui.Theme.Background
    indicator.Parent = row
    corner(indicator, UDim.new(1, 0))
    ui:Connect(row.MouseButton1Click, function()
        enabled = not enabled
        ui:Tween(indicator, { BackgroundColor3 = enabled and ui.Theme.Primary or ui.Theme.Background }, 0.2)
        if callback then callback(enabled) end
    end)
    return row
end

function Components.Slider(parent, ui, label, min, max, default, callback)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, 0, 0, 54)
    holder.Parent = parent
    Components.Label(holder, ui.Theme, label, { Size = UDim2.new(1, -50, 0, 22) })
    local value = Instance.new("TextLabel")
    value.BackgroundTransparency = 1
    value.Position = UDim2.new(1, -48, 0, 0)
    value.Size = UDim2.fromOffset(48, 22)
    value.TextColor3 = ui.Theme.Primary
    value.TextSize = 13
    value.Font = Enum.Font.GothamBold
    value.Parent = holder
    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(0, 30)
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.BackgroundColor3 = ui.Theme.Surface
    bar.Parent = holder
    corner(bar, UDim.new(1, 0))
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = ui.Theme.Primary
    fill.Size = UDim2.fromScale(0, 1)
    fill.Parent = bar
    corner(fill, UDim.new(1, 0))
    local current = math.clamp(default or min, min, max)
    local function setValue(nextValue)
        current = math.clamp(nextValue, min, max)
        local alpha = (current - min) / (max - min)
        fill.Size = UDim2.fromScale(alpha, 1)
        value.Text = tostring(math.floor(current))
        if callback then callback(current) end
    end
    ui:Connect(bar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setValue(min + (max - min) * math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1))
        end
    end)
    setValue(current)
    return holder
end

return Components
