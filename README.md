# Dereus Luau

**Dereus Luau 2.1.0** es una librería open source de interfaces para **Roblox Studio y experiencias autorizadas de Roblox**, escrita en Luau y diseñada alrededor de una estética compacta, animada y cinematográfica. Sirve para menús, paneles de configuración, herramientas internas, interfaces de administración autorizadas, tutoriales, dashboards y experiencias de juego.

> Dereus es una librería de interfaz. No es un ejecutor, no contiene bypasses, no automatiza trampas y no está diseñada para evadir las reglas o protecciones de Roblox.

## Principios del proyecto

Dereus prioriza cinco principios: API composable, limpieza automática, animación consistente, compatibilidad con Roblox Studio y responsabilidad del integrador. La librería no decide qué hace el código que la consume; el creador de la experiencia debe revisar sus permisos, seguridad, RemoteEvents, moderación y cumplimiento de las reglas aplicables.

## Instalación

Copia `src` a `ReplicatedStorage.Packages.Dereus` mediante Rojo, Wally o sincronización manual. En un `LocalScript`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dereus = require(ReplicatedStorage.Packages.Dereus)

local ui = Dereus.new({
    Name = "MyInterface",
    IgnoreGuiInset = false,
    DisplayOrder = 20,
})
```

La librería no tiene dependencias externas: utiliza servicios y clases nativos de Roblox.

## Inicio rápido

```lua
local window = ui.Window.new(ui, {
    Title = "Control Center",
    Subtitle = "Herramientas de la experiencia",
    Size = UDim2.fromOffset(620, 440),
})

local home = window:AddTab("Home", "⌂")
ui.Components.Section(home.Page, ui.Theme, "Acciones")
ui.Components.Button(home.Page, ui, "Ejecutar acción autorizada", function()
    ui.Notify.new(ui, "Completado", "La acción terminó correctamente.")
end)
ui.Components.Toggle(home.Page, ui, "Modo compacto", false, function(enabled)
    print("Compact mode:", enabled)
end)
ui.Motion.Enter(window.Root, { Offset = 30, Duration = 0.55 })
```

## API pública

| API | Descripción |
|---|---|
| `Dereus.new(options?)` | Crea un `ScreenGui` aislado y un registro de limpieza. |
| `ui:Register(instance)` | Registra una instancia para destruirla al cerrar la UI. |
| `ui:Connect(signal, callback)` | Registra una conexión para desconexión automática. |
| `ui:Tween(instance, properties, duration, style, direction)` | Tween centralizado con valores seguros. |
| `ui:Destroy()` | Desconecta señales, destruye instancias y elimina la interfaz. |
| `ui.Window.new(ui, options?)` | Crea una ventana con pestañas. |
| `ui.Components.*` | Componentes `Panel`, `Stack`, `Label`, `Button`, `Input`, `Toggle` y `Slider`. |
| `ui.Motion.*` | Entrada, salida, press, stagger y secuencias. |
| `ui.Notify.new(ui, title, message, options?)` | Notificación apilable y auto-cerrable. |

## Motion y cinemáticas de interfaz

`Motion.Enter` y `Motion.Exit` combinan desplazamiento y transparencia cuando la clase lo permite. `Motion.Stagger` introduce elementos en cascada; `Motion.Sequence` permite organizar una secuencia lineal de tweens y pausas.

```lua
ui.Motion.Stagger({ card1, card2, card3 }, {
    Offset = 18,
    Duration = 0.4,
    Stagger = 0.08,
})

local intro = ui.Motion.Sequence({
    { Instance = logo, Properties = { ImageTransparency = 0 }, Options = { Duration = 0.5 } },
    { Wait = 0.25 },
    { Instance = headline, Properties = { TextTransparency = 0 }, Options = { Duration = 0.35 } },
})
intro:Play()
```

Para una cinemática de menú, mantén las transiciones cortas, no bloquees la interacción más tiempo del necesario y ofrece siempre un método de cierre o skip. La librería anima la interfaz; la lógica de juego y la autorización deben permanecer separadas.

## Compatibilidad y buenas prácticas

Dereus está pensada para `LocalScript` y `ScreenGui` en Roblox Studio. Usa `Activated` en botones para cubrir mouse, touch y gamepad cuando Roblox lo soporte. El slider admite mouse y touch. Para experiencias con respawn, decide explícitamente si `ResetOnSpawn` debe ser `true` o `false`. Para plugins de Studio, proporciona un `Parent` apropiado en `Dereus.new` en vez de asumir `PlayerGui`.

Mantén los cambios de estado en el servidor cuando afecten economía, permisos, progreso o seguridad. Una UI nunca debe ser la autoridad sobre esas decisiones. Valida nuevamente los datos recibidos por RemoteEvents.

## Limpieza

Siempre conserva la instancia y destrúyela cuando reemplaces la pantalla:

```lua
ui:Destroy()
```

Esto desconecta eventos y evita conexiones huérfanas, especialmente al cambiar de menú, respawnear o cerrar una herramienta.

## Estructura recomendada

```text
ReplicatedStorage/
  Packages/
    Dereus/
      Dereus.lua
      Components.lua
      Motion.lua
      Notify.lua
      Window.lua
      init.lua
StarterPlayerScripts/
  Starter.client.lua
```

## Términos de uso y alcance

Dereus se distribuye bajo la licencia MIT incluida en este repositorio. Puedes usarla, modificarla, redistribuirla e incorporarla en proyectos personales, educativos o comerciales respetando esa licencia.

El integrador es responsable de su propio código, contenido, datos, permisos, seguridad, cumplimiento de las reglas de Roblox y legislación aplicable. Dereus no reclama propiedad ni participación sobre los proyectos creados con la librería y no se hace responsable por daños, sanciones, pérdidas, abuso, fraude, explotación, trampas, acceso no autorizado o cualquier otro uso que un tercero dé a un proyecto que la incluya. Esta aclaración no convierte en legítimo un uso prohibido: cada usuario debe usarla únicamente en contextos autorizados y legales.

Dereus tampoco garantiza que una versión concreta sea compatible con futuros cambios de Roblox. Las contribuciones deben conservar la separación entre presentación y lógica sensible, incluir documentación y evitar funciones destinadas a eludir controles, obtener acceso no autorizado o perjudicar a otros usuarios.

## Contribuir

Abre un issue describiendo el problema, versión de Roblox Studio, pasos para reproducirlo y resultado esperado. Los pull requests deben ser pequeños, documentados y acompañados por una prueba o ejemplo reproducible cuando corresponda.

## Licencia

MIT. Consulta [`LICENSE`](./LICENSE).
