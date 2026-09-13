local Dereus = require(script.Dereus)
local Components = require(script.Components)
local Motion = require(script.Motion)
local Notify = require(script.Notify)
local Window = require(script.Window)
local Style = require(script.Style)
local Layout = require(script.Layout)
local Host = require(script.Host)
local Cinematic = require(script.Cinematic)
local Compatibility = require(script.Compatibility)
local Presets = require(script.Presets)

Dereus.Components = Components
Dereus.Window = Window
Dereus.Motion = Motion
Dereus.Notify = Notify
Dereus.Style = Style
Dereus.Layout = Layout
Dereus.Host = Host
Dereus.Cinematic = Cinematic
Dereus.Compatibility = Compatibility
Dereus.Presets = Presets
Dereus.VERSION = Dereus.Version

return Dereus
