local Compatibility = {}

Compatibility.Version = "1.0.0"

function Compatibility.Probe(options)
    options = options or {}
    local parent = options.Parent
    local player = options.Player
    return {
        HasPlayer = player ~= nil,
        HasParent = parent ~= nil,
        HasGuiObjects = parent ~= nil and parent.IsA ~= nil,
        HasTweenService = pcall(function() return game:GetService("TweenService") end),
        HasUserInput = pcall(function() return game:GetService("UserInputService") end),
        HostName = options.HostName or "custom",
    }
end

function Compatibility.SafeCall(callback, ...)
    if type(callback) ~= "function" then return false, "callback is not callable" end
    return pcall(callback, ...)
end

function Compatibility.Adapter(options)
    options = options or {}
    local adapter = {
        Name = options.Name or "DereusAdapter",
        Parent = options.Parent,
        ResolveParent = options.ResolveParent,
        Capabilities = options.Capabilities or {},
    }
    function adapter:Resolve(player)
        if self.Parent then return self.Parent end
        if self.ResolveParent then
            local ok, parent = pcall(self.ResolveParent, player)
            if ok then return parent end
        end
        return nil
    end
    function adapter:Can(capability)
        return self.Capabilities[capability] == true
    end
    return adapter
end

function Compatibility.Mount(gui, adapter, player)
    if not gui or not adapter then return false, "gui and adapter are required" end
    local parent = adapter.Resolve and adapter:Resolve(player) or adapter.Parent
    if not parent then return false, "adapter did not resolve a parent" end
    gui.Parent = parent
    return true, parent
end

return Compatibility
