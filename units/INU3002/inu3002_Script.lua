-- T3 tank

local SupportingArtilleryAbility = import('/lua/nomadsutils.lua').SupportingArtilleryAbility
local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local AnnihilatorCannon1 = import('/lua/nomadsweapons.lua').AnnihilatorCannon1
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1

NHoverLandUnit = SupportingArtilleryAbility( NHoverLandUnit )

INU3002 = Class(NHoverLandUnit) {
    Weapons = {
        MainGun = Class(AnnihilatorCannon1) {},
        Rocket = Class(RocketWeapon1) {},
    },

    ArtillerySupportFxBone = 'photon_turret', -- TODO: this tank needs a model adjustment, put an artillery support ability pinger thing on it
}

TypeClass = INU3002
