return function()
    local Dereus = require(script.Parent.Parent.src.Dereus)
    assert(Dereus.Version == "2.0.0", "version should be 2.0.0")
    assert(Dereus.Theme.Primary ~= nil, "default theme should include Primary")
end
