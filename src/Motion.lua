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
