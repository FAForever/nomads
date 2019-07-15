-- T2 torpedo gunship

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local SupportingArtilleryAbility = import('/lua/nomadsutils.lua').SupportingArtilleryAbility
NAirUnit = SupportingArtilleryAbility( NAirUnit )
local StingrayCannon1 = import('/lua/nomadsweapons.lua').StingrayCannon1
local DroppedTorpedoWeapon1  = import('/lua/nomadsweapons.lua').DroppedTorpedoWeapon1

XNA0203 = Class(NAirUnit) {
     Weapons = {
        MainGun = Class(StingrayCannon1) {},
        Torpedo = Class(DroppedTorpedoWeapon1) {},
    },
}

TypeClass = XNA0203