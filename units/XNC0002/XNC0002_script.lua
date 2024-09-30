local NCivilianStructureUnit = import('/lua/nomadsunits.lua').NCivilianStructureUnit
local NCommandFrigateUnit = import('/lua/nomadsunits.lua').NCommandFrigateUnit

--- Civilian
--- The surface support vehicle that's in orbit
---@class XNC0002 : NCivilianStructureUnit, NCommandFrigateUnit
XNC0002 = Class(NCivilianStructureUnit, NCommandFrigateUnit) {

    ---@param self XNC0002
    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        self.EngineEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()
        NCivilianStructureUnit.OnCreate(self)
    end,
}
TypeClass = XNC0002
