local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dereus = require(ReplicatedStorage.Packages.Dereus)

local ui = Dereus.new({ Name = "CinematicExample", DisplayOrder = 30 })
local window = ui.Window.new(ui, {
    Title = "Dereus Showcase",
    Subtitle = "Motion y transiciones",
    Size = UDim2.fromOffset(600, 400),
})

local intro = window:AddTab("Intro", "◆")
local details = window:AddTab("Details", "i")
local introTitle = ui.Components.Label(intro.Page, ui.Theme, "Una interfaz con ritmo", { TextSize = 24, Size = UDim2.new(1, 0, 0, 42) })
local introBody = ui.Components.Label(intro.Page, ui.Theme, "Las entradas deben guiar la atención sin bloquear el control del jugador.", { Color = ui.Theme.Muted, Wrapped = true, Size = UDim2.new(1, 0, 0, 42) })
ui.Components.Button(intro.Page, ui, "Mostrar detalles", function() window:SelectTab(details) end)
ui.Components.Label(details.Page, ui.Theme, "Composición", { TextSize = 20 })
ui.Components.Label(details.Page, ui.Theme, "Usa Motion.Stagger para listas y Sequence para una introducción breve.", { Color = ui.Theme.Muted, Wrapped = true, Size = UDim2.new(1, 0, 0, 42) })

ui.Motion.Enter(window.Root, { Offset = 26, Duration = 0.5 })
task.delay(0.12, function() ui.Motion.Stagger({ introTitle, introBody }, { Offset = 12, Duration = 0.35, Stagger = 0.08 }) end)
