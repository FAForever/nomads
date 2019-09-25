-- The surface support vehicle that's in orbit

local NCivilianStructureUnit = import('/lua/nomadsunits.lua').NCivilianStructureUnit
local NCommandFrigateUnit = import('/lua/nomadsunits.lua').NCommandFrigateUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')


XNC0001 = Class(NCivilianStructureUnit, NCommandFrigateUnit) {

    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        self.EngineEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()
        NCivilianStructureUnit.OnCreate(self)
        self:Landing(true) --landing animation
    end,
}

TypeClass = XNC0001