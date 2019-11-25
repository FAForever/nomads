-- T2 torpedo gunship

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local DroppedTorpedoWeapon1  = import('/lua/nomadsweapons.lua').DroppedTorpedoWeapon1

XNA0203 = Class(NAirUnit) {
     Weapons = {
        MainGun = Class(DroppedTorpedoWeapon1) {},
    },
}

TypeClass = XNA0203