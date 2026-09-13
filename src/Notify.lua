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
