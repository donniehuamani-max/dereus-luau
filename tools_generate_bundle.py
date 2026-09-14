from pathlib import Path

root = Path('/home/ubuntu/dereus-luau')
src = root / 'src'
modules = [
    'Registry', 'LuaCompat', 'Dereus', 'Components', 'Motion', 'Notify', 'Window',
    'Style', 'Layout', 'Host', 'Cinematic', 'Compatibility', 'Presets', 'Diagnostics', 'Store'
]

def read(name):
    text = (src / f'{name}.lua').read_text()
    text = text.replace('require(script.Registry)', 'modules.Registry')
    text = text.replace('require(script.Dereus)', 'modules.Dereus')
    return text

parts = [
    '-- Dereus Library 2.8.0 single-file bundle. Generated from src/.',
    '-- The bundle targets Lua/Luau runtimes. Roblox UI modules require Roblox services.',
    'local modules = {}',
    'local function define(name, factory) modules[name] = factory() end',
]
for name in modules:
    parts.append(f'define({name!r}, function()')
    parts.append(read(name))
    parts.append('end)')

parts += [
    'local Dereus = modules.Dereus',
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
    'Dereus.LibraryName = "Dereus Library"',
    'Dereus.VERSION = Dereus.Version',
    'return Dereus',
]
(root / 'bundle.lua').write_text('\n'.join(parts) + '\n')
print(f'generated {root / "bundle.lua"}')
