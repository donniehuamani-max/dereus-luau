# Dereus Luau

**Dereus UI v2.0.0 for Roblox Luau** — a complete, animation-first UI library for scripts, tools, dashboards, admin panels, and in-game experiences.

> Dereus Luau is the Luau counterpart to Dereus UI: the same rounded, cinematic design language implemented natively for Roblox.

## Features

- Theme tokens for background, surfaces, typography, borders, and radius
- Lifecycle-safe `Dereus.new()` instances with `Destroy()` cleanup
- Full `Window` and `Tab` shell API for Roblox Studio interfaces
- Reusable `Panel`, `Stack`, `Label`, `Button`, `Input`, `Section`, `Toggle`, and `Slider` components
- Cinematic motion helpers: enter, press, tween, spring-like easing
- Built for authorized Studio experiences, tools, plugins, dashboards, and admin interfaces
- Auto-dismissing notifications
- Hover, focus, press, and keyboard-friendly interaction states
- No external dependencies; Roblox services only
- Typed-friendly module boundaries and composable APIs

## Installation

Copy `src` into `ReplicatedStorage.Packages.Dereus` using your preferred Roblox workflow (Rojo, Wally, or manual package sync).

```lua
local Dereus = require(ReplicatedStorage.Packages.Dereus)
local ui = Dereus.new({ Name = "MyInterface" })
```

## Quick start

```lua
local panel = ui.Components.Panel(ui.Gui, ui.Theme, {
    Size = UDim2.fromOffset(360, 240),
})
panel.Position = UDim2.new(0.5, -180, 0.5, -120)

ui.Components.Label(panel, ui.Theme, "Command Center", { TextSize = 22 })
ui.Components.Button(panel, ui, "Run", function()
    ui.Notify.new(ui, "Done", "Your command finished successfully.")
end)

ui.Motion.Enter(panel)
```

## Window API

```lua
local window = ui.Window.new(ui, {
    Title = "Dereus Control Center",
    Size = UDim2.fromOffset(620, 440),
})

local home = window:AddTab("Home", "⌂")
ui.Components.Section(home.Page, ui.Theme, "Actions")
ui.Components.Button(home.Page, ui, "Launch", function()
    print("Authorized action")
end)
ui.Components.Toggle(home.Page, ui, "Enabled", true, function(enabled)
    print("Enabled:", enabled)
end)
ui.Components.Slider(home.Page, ui, "Opacity", 0, 100, 80, function(value)
    print("Opacity:", value)
end)
```

`Window:AddTab()` creates an isolated scrolling page and tab button. Use `window:SelectTab(tab)` to switch pages programmatically. Every connection and instance is registered with the parent `ui` instance, so `ui:Destroy()` cleans up the complete interface safely.

## Architecture

- `Dereus.lua` owns the UI root, theme, TweenService wrapper, connection registry, and cleanup.
- `Components.lua` contains small composable primitives. Components receive the UI instance so they share theme and lifecycle behavior.
- `Motion.lua` keeps animation behavior consistent and avoids duplicated TweenInfo setup.
- `Notify.lua` provides transient feedback without coupling notifications to a specific screen.

## API

### `Dereus.new(options?)`
Creates a ScreenGui and returns an isolated UI instance. `options.Name` changes the ScreenGui name and `options.Theme` overrides theme tokens.

### `ui:Destroy()`
Disconnects registered signals, destroys registered instances, and removes the ScreenGui.

### `ui:Connect(signal, callback)`
Registers a connection for automatic cleanup.

### Components

- `ui.Components.Panel(parent, theme, props)`
- `ui.Components.Stack(parent, props)`
- `ui.Components.Label(parent, theme, text, props?)`
- `ui.Components.Button(parent, ui, text, callback, props?)`
- `ui.Components.Input(parent, ui, placeholder, callback, props?)`

### Motion

```lua
ui.Motion.Play(instance, { Position = target }, { Duration = 0.6 })
ui.Motion.Enter(panel, { Offset = 28, Duration = 0.55 })
```

## Recommended project layout

```text
ReplicatedStorage/
  Packages/
    Dereus/
      Dereus.lua
      Components.lua
      Motion.lua
      Notify.lua
      init.lua
StarterPlayerScripts/
  Starter.client.lua
```

## Development

Use Rojo to sync the modules into Roblox Studio. Keep UI roots local to the player and call `ui:Destroy()` when replacing a screen. Run `tests/Smoke.spec.lua` in your preferred Luau test runner.

## License

MIT. See `LICENSE`.
