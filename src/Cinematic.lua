local Cinematic = {}
Cinematic.__index = Cinematic

function Cinematic.new(ui, options)
    local self = setmetatable({ UI = ui, Steps = {}, Skipped = false, Playing = false }, Cinematic)
    self.Options = options or {}
    return self
end

function Cinematic:Add(instance, properties, options)
    table.insert(self.Steps, { Instance = instance, Properties = properties or {}, Options = options or {} })
    return self
end

function Cinematic:Wait(seconds)
    table.insert(self.Steps, { Wait = seconds or 0 })
    return self
end

function Cinematic:Skip()
    self.Skipped = true
    return self
end

function Cinematic:Play(onComplete)
    self.Playing = true
    self.Skipped = false
    for _, step in ipairs(self.Steps) do
        if self.Skipped then break end
        if step.Wait then
            task.wait(step.Wait)
        elseif step.Instance and step.Instance.Parent then
            local tween = self.UI.Motion.Play(step.Instance, step.Properties, step.Options)
            if tween then tween.Completed:Wait() end
        end
    end
    self.Playing = false
    if onComplete then onComplete(self.Skipped) end
    return self
end

function Cinematic:PlayAsync(onComplete)
    task.spawn(function() self:Play(onComplete) end)
    return self
end

function Cinematic:Clear()
    table.clear(self.Steps)
    return self
end

return Cinematic
