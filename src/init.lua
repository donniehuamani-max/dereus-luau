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
local Diagnostics = require(script.Diagnostics)
local Registry = require(script.Registry)
local Store = require(script.Store)
local Portable = require(script.Portable)
local Utils = require(script.Utils)

Dereus.Components = Components
Dereus.Portable = Portable
Dereus.Utils = Utils
Dereus.Version = "2.7.0"
Dereus.Window = Window
Dereus.Motion = Motion
Dereus.Notify = Notify
Dereus.Style = Style
Dereus.Layout = Layout
Dereus.Host = Host
Dereus.Cinematic = Cinematic
Dereus.Compatibility = Compatibility
Dereus.Presets = Presets
Dereus.Diagnostics = Diagnostics
Dereus.Registry = Registry
Dereus.Store = Store
Dereus.VERSION = Dereus.Version

return Dereus
