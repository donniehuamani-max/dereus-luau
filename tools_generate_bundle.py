from pathlib import Path

root = Path('/home/ubuntu/dereus-luau')
src = root / 'src'
modules = [
    'Registry', 'LuaCompat', 'Portable', 'Utils', 'Dereus', 'Components', 'Motion', 'Notify', 'Window',
    'Style', 'Layout', 'Host', 'Cinematic', 'Compatibility', 'Presets', 'Diagnostics', 'Store'
]

def read(name):
    text = (src / f'{name}.lua').read_text()
    text = text.replace('require(script.Registry)', 'modules.Registry')
    return text

parts = [
    '-- Dereus Library 2.8.0 single-file bundle. Generated from src/.',
    '-- Roblox-dependent modules are loaded opportunistically; portable modules remain usable in Lua/Luau.',
    'local modules = {}',
    'local function define(name, factory)',
    '    local ok, value = pcall(factory)',
    '    if ok then modules[name] = value end',
    'end',
]
for name in modules:
    parts.append(f'define({name!r}, function()')
    parts.append(read(name))
    parts.append('end)')

parts += [
    'local Dereus = modules.Dereus or modules.Portable or {}',
    'Dereus.Components = modules.Components',
    'Dereus.Window = modules.Window',
    'Dereus.Motion = modules.Motion',
    'Dereus.Notify = modules.Notify',
    'Dereus.Style = modules.Style',
    'Dereus.Layout = modules.Layout',
    'Dereus.Host = modules.Host',
    'Dereus.Cinematic = modules.Cinematic',
    'Dereus.Compatibility = modules.Compatibility',
    'Dereus.Presets = modules.Presets',
    'Dereus.Diagnostics = modules.Diagnostics',
    'Dereus.Registry = modules.Registry',
    'Dereus.Store = modules.Store',
    'Dereus.LuaCompat = modules.LuaCompat',
    'Dereus.Utils = modules.Utils',
    'Dereus.Portable = modules.Portable',
    'Dereus.LibraryName = "Dereus Library"',
    'Dereus.VERSION = Dereus.Version or "2.8.0"',
    'return Dereus',
]
(root / 'bundle.lua').write_text('\n'.join(parts) + '\n')
print(f'generated {root / "bundle.lua"}')
