local Notify = {}

function Notify.new(ui, title, message, options)
    options = options or {}
    local frame = Instance.new("Frame")
    frame.Name = "Notification"; frame.AnchorPoint = Vector2.new(1, 1); frame.Position = UDim2.new(1, -24, 1, -24); frame.Size = UDim2.fromOffset(options.Width or 320, 76); frame.BackgroundColor3 = ui.Theme.Surface; frame.Parent = ui.Gui
    local corner = Instance.new("UICorner"); corner.CornerRadius = ui.Theme.Radius; corner.Parent = frame
    local stroke = Instance.new("UIStroke"); stroke.Color = ui.Theme.Border; stroke.Parent = frame
    local titleLabel = Instance.new("TextLabel"); titleLabel.Text = title; titleLabel.TextColor3 = ui.Theme.Text; titleLabel.TextSize = 15; titleLabel.Font = Enum.Font.GothamBold; titleLabel.BackgroundTransparency = 1; titleLabel.Position = UDim2.fromOffset(16, 11); titleLabel.Size = UDim2.new(1, -32, 0, 22); titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = frame
    local body = Instance.new("TextLabel"); body.Text = message; body.TextColor3 = ui.Theme.Muted; body.TextSize = 12; body.Font = Enum.Font.Gotham; body.BackgroundTransparency = 1; body.Position = UDim2.fromOffset(16, 36); body.Size = UDim2.new(1, -32, 0, 20); body.TextXAlignment = Enum.TextXAlignment.Left; body.Parent = frame
    ui:Tween(frame, {Position = UDim2.new(1, -24, 1, -24)}, 0.5, Enum.EasingStyle.Back)
    task.delay(options.Duration or 4, function() if frame.Parent then ui:Tween(frame, {Position = UDim2.new(1, 360, 1, -24)}, 0.35); task.wait(0.4); frame:Destroy() end end)
    return frame
end

return Notify
