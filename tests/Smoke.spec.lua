return function()
    local Dereus = require(script.Parent.Parent.src)
    assert(Dereus.Version == "2.1.0", "version should be 2.1.0")
    assert(Dereus.Theme.Primary ~= nil, "default theme should include Primary")
    assert(Dereus.Components.Button ~= nil, "button component should be exported")
    assert(Dereus.Motion.Sequence ~= nil, "motion sequence should be exported")
end
