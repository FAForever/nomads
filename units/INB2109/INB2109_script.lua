# T1 torpedo launcher

local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local TorpedoWeapon1 = import('/lua/nomadweapons.lua').TorpedoWeapon1

INB2109 = Class(NStructureUnit) {
    Weapons = {
        Turret01 = Class(TorpedoWeapon1) {},
    },
}

TypeClass = INB2109

