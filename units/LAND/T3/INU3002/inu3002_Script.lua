# T3 tank

local SupportingArtilleryAbility = import('/lua/nomadutils.lua').SupportingArtilleryAbility
local NHoverLandUnit = import('/lua/nomadunits.lua').NHoverLandUnit
local AnnihilatorCannon1 = import('/lua/nomadweapons.lua').AnnihilatorCannon1
local RocketWeapon1 = import('/lua/nomadweapons.lua').RocketWeapon1

NHoverLandUnit = SupportingArtilleryAbility( NHoverLandUnit )

INU3002 = Class(NHoverLandUnit) {
    Weapons = {
        MainGun = Class(AnnihilatorCannon1) {},
        Rocket = Class(RocketWeapon1) {},
    },

    ArtillerySupportFxBone = 'photon_turret', # TODO: this tank needs a model adjustment, put an artillery support ability pinger thing on it
}

TypeClass = INU3002
