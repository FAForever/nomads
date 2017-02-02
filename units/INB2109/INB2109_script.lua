-- T1 torpedo launcher

local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local TorpedoWeapon1 = import('/lua/nomadsweapons.lua').TorpedoWeapon1

INB2109 = Class(NStructureUnit) {
    Weapons = {
        Turret01 = Class(TorpedoWeapon1) {},
    },
}

TypeClass = INB2109

