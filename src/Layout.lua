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
