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
    local parent = Host.Resolve(options)
    if not parent then return false, "No GUI parent was provided or resolved" end
    screenGui.Parent = parent
    return true, parent
end

return Host
