-- t3 arillery

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ArtilleryWeapon = import('/lua/nomadsweapons.lua').ArtilleryWeapon
local Utilities = import('/lua/utilities.lua')
local SupportedArtilleryWeapon = import('/lua/nomadsutils.lua').SupportedArtilleryWeapon
local EffectUtil = import('/lua/EffectUtilities.lua')
local ArtilleryWeapon = SupportedArtilleryWeapon( ArtilleryWeapon )

INU3004 = Class(NLandUnit) {
    Weapons = {
		ArtilleryGun = Class(ArtilleryWeapon) {},
    },
	
	OnCreate = function(self)
        NLandUnit.OnCreate(self)
    end,
}

TypeClass = INU3004
