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
