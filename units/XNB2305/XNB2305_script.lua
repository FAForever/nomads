local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local StrategicMissileWeapon = import('/lua/nomadsweapons.lua').StrategicMissileWeapon
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon1

--- Tech 3 Strategic Launcher (Nuke Launcher)
---@class XNB2305 : NStructureUnit
XNB2305 = Class(NStructureUnit) {
    Weapons = {
        NukeMissiles = Class(StrategicMissileWeapon) {},
        RocketArtillery = Class (TacticalMissileWeapon1) {},
    },

    ---@param self XNB2305
    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
        self.NukeEntity = 1 --leave a value for the death explosion entity to use later.
    end,
}
TypeClass = XNB2305