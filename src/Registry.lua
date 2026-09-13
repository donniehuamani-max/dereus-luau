local Registry = {}
Registry.__index = Registry

function Registry.new()
    return setmetatable({ Items = {}, Connections = {}, Tasks = {}, Destroyed = false }, Registry)
end

function Registry:Add(instance)
    if self.Destroyed then if instance and instance.Destroy then instance:Destroy() end; return instance end
    table.insert(self.Items, instance)
    return instance
end

function Registry:Connect(signal, callback)
    if self.Destroyed then return nil end
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function Registry:Track(taskHandle)
    if taskHandle then table.insert(self.Tasks, taskHandle) end
    return taskHandle
end

function Registry:Clear()
    for _, connection in ipairs(self.Connections) do if connection.Connected then connection:Disconnect() end end
    for _, item in ipairs(self.Items) do if item and item.Parent then item:Destroy() end end
    for _, handle in ipairs(self.Tasks) do if type(handle) == "thread" and coroutine.status(handle) ~= "dead" then task.cancel(handle) end end
    table.clear(self.Connections); table.clear(self.Items); table.clear(self.Tasks)
end

function Registry:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self:Clear()
end

return Registry
