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

return Style
