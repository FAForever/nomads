-- The surface support vehicle that's in orbit


local NCivilianStructureUnit = import('/lua/nomadsunits.lua').NCivilianStructureUnit
local NCommandFrigateUnit = import('/lua/nomadsunits.lua').NCommandFrigateUnit


XNC0002 = Class(NCivilianStructureUnit, NCommandFrigateUnit) {
    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        self.EngineEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()
        NCivilianStructureUnit.OnCreate(self)
    end,
}
TypeClass = XNC0002
