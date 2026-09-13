local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dereus = require(ReplicatedStorage.Packages.Dereus)

local ui = Dereus.new({ Name = "StarterUI" })
local panel = ui.Components.Panel(ui.Gui, ui.Theme, { Size = UDim2.fromOffset(360, 280) })
panel.Position = UDim2.new(0.5, -180, 0.5, -140)

ui.Components.Label(panel, ui.Theme, "Welcome to Dereus", { TextSize = 22, Size = UDim2.new(1, 0, 0, 34) })
ui.Components.Label(panel, ui.Theme, "A production-ready Luau UI foundation.", { Color = ui.Theme.Muted })
local input = ui.Components.Input(panel, ui, "Your name")
ui.Components.Button(panel, ui, "Continue", function()
    ui.Notify.new(ui, "Hello", "Welcome, " .. (input.Text ~= "" and input.Text or "builder") .. "!")
end)
ui.Motion.Enter(panel)
