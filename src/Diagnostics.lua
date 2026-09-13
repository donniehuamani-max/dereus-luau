local Diagnostics = {}

Diagnostics.Version = "1.0.0"
Diagnostics.Issues = {
    MissingParent = "No se encontró un contenedor GUI. Usa Parent o ParentResolver.",
    MissingPlayer = "No se encontró Player. Ejecuta en cliente o proporciona options.Player.",
    DestroyedUI = "La instancia Dereus ya fue destruida.",
    InvalidRange = "El rango recibido no es válido.",
}

function Diagnostics.Check(ui)
    local report = { Ok = true, Issues = {}, Warnings = {}, Version = Diagnostics.Version }
    local function issue(code, detail)
        report.Ok = false
        table.insert(report.Issues, { Code = code, Message = detail or Diagnostics.Issues[code] or code })
    end
    if not ui then issue("MissingUI") return report end
    if ui:IsDestroyed and ui:IsDestroyed() then issue("DestroyedUI") end
    if not ui.Gui or not ui.Gui.Parent then issue("MissingParent") end
    if not ui.Player then issue("MissingPlayer") end
    return report
end

function Diagnostics.AssertHealthy(ui)
    local report = Diagnostics.Check(ui)
    if not report.Ok then
        local messages = {}
        for _, issue in ipairs(report.Issues) do table.insert(messages, issue.Code .. ": " .. issue.Message) end
        error("Dereus diagnostics failed - " .. table.concat(messages, " | "), 2)
    end
    return true, report
end

function Diagnostics.Clamp(value, minimum, maximum, fallback)
    if type(value) ~= "number" or type(minimum) ~= "number" or type(maximum) ~= "number" or maximum < minimum then
        return fallback or minimum
    end
    return math.clamp(value, minimum, maximum)
end

function Diagnostics.Try(label, callback, onError)
    local ok, result = pcall(callback)
    if not ok and onError then onError(label, result) end
    return ok, result
end

function Diagnostics.FormatError(prefix, errorMessage)
    return string.format("[%s] %s", prefix or "Dereus", tostring(errorMessage))
end

return Diagnostics
