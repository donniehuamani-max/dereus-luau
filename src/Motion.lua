local TweenService = game:GetService("TweenService")
local Motion = {}
Motion.Eases = { Smooth = Enum.EasingStyle.Quint, Spring = Enum.EasingStyle.Back, Soft = Enum.EasingStyle.Sine }

function Motion.Play(instance, properties, options)
    options = options or {}
    local tween = TweenService:Create(instance, TweenInfo.new(options.Duration or 0.45, options.Style or Motion.Eases.Smooth, options.Direction or Enum.EasingDirection.Out, options.RepeatCount or 0, options.Reverses or false), properties)
    tween:Play()
    return tween
end

function Motion.Enter(instance, options)
    local original = instance.Position
    instance.Position = original + UDim2.fromOffset(0, options and options.Offset or 22)
    instance.BackgroundTransparency = 1
    Motion.Play(instance, { Position = original, BackgroundTransparency = 0 }, options)
end

function Motion.Press(instance, scale)
    scale = scale or 0.97
    local original = instance.Size
    local down = UDim2.new(original.X.Scale * scale, original.X.Offset, original.Y.Scale * scale, original.Y.Offset)
    return { Down = function() Motion.Play(instance, { Size = down }, { Duration = 0.12, Style = Enum.EasingStyle.Quad }) end, Up = function() Motion.Play(instance, { Size = original }, { Duration = 0.2, Style = Motion.Eases.Spring }) end }
end

return Motion
