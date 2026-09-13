# Compatibilidad de Dereus Luau 2.2.0

Dereus está diseñado para código Luau autorizado que crea interfaces mediante las clases y servicios públicos de Roblox. El objetivo de esta versión es que el mismo código pueda montarse en una experiencia de Roblox, una herramienta local de Studio o un host que proporcione un contenedor GUI válido, sin acoplar la librería a APIs privadas.

## Matriz de montaje

| Entorno | Recomendación | Estado |
|---|---|---|
| `LocalScript` en experiencia | Omitir `Parent` y usar el `PlayerGui` del jugador local | Soportado |
| Herramienta o plugin de Studio | Pasar un `Parent` de GUI controlado por el plugin | Soportado mediante `Parent` |
| Host Luau autorizado con contenedor propio | Pasar `Parent` o `ParentResolver` | Soportado mediante adaptador |
| Código de servidor sin jugador local | Pasar `options.Player` y un `Parent` válido, o no crear UI | Requiere integración explícita |
| API privada, bypass o entorno no autorizado | No es objetivo de Dereus | Fuera de alcance |

## Adaptador de montaje

```lua
local ui = Dereus.new({
    Parent = myGuiContainer,
    Player = player,
})
```

`ParentResolver` permite retrasar o centralizar la selección del contenedor:

```lua
local ui = Dereus.new({
    Player = player,
    ParentResolver = function(currentPlayer)
        return currentPlayer:WaitForChild("PlayerGui")
    end,
})
```

El callback se ejecuta protegido con `pcall`. Si no devuelve un contenedor, Dereus usa `PlayerGui` como fallback. El callback no debe obtener permisos, modificar seguridad ni invocar APIs privadas.

## Estabilidad

Conserva una única instancia por pantalla y llama `ui:Destroy()` antes de montar un reemplazo. No mantengas conexiones externas a instancias destruidas. La librería registra la mayoría de conexiones mediante `ui:Connect`; los componentes nuevos deben seguir el mismo patrón.

La UI no es una frontera de seguridad. Las decisiones sensibles, los permisos y la validación de datos deben implementarse en el servidor y verificarse nuevamente en cada RemoteEvent.

## Presentación

Usa `Style.Surface` para mantener radios, strokes, gradientes y sombras consistentes. En pantallas pequeñas, prefiere ventanas desplazables, textos envueltos y controles grandes para touch. Las animaciones deben comunicar estado, no ocultar información ni impedir el cierre de la pantalla.
