local NCivilianStructureUnit = import('/lua/nomadsunits.lua').NCivilianStructureUnit
local NCommandFrigateUnit = import('/lua/nomadsunits.lua').NCommandFrigateUnit

--- Civilian
--- The surface support vehicle that's in orbit
---@class XNC0001 : NCivilianStructureUnit, NCommandFrigateUnit
XNC0001 = Class(NCivilianStructureUnit, NCommandFrigateUnit) {

    ---@param self XNC0001
    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        self.EngineEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()
        NCivilianStructureUnit.OnCreate(self)
        self:Landing(true) --landing animation
    end,
}
TypeClass = XNC0001