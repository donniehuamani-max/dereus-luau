local Dereus = require(script.Dereus)
local Components = require(script.Components)
local Motion = require(script.Motion)
local Notify = require(script.Notify)
local Window = require(script.Window)

Dereus.Components = Components
Dereus.Window = Window
Dereus.Motion = Motion
Dereus.Notify = Notify
Dereus.VERSION = Dereus.Version

return Dereus
