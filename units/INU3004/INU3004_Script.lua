-- t3 arillery

local AddAnchorAbilty = import('/lua/nomadutils.lua').AddAnchorAbilty
local SupportedArtilleryWeapon = import('/lua/nomadutils.lua').SupportedArtilleryWeapon
local NLandUnit = import('/lua/nomadunits.lua').NLandUnit
local ArtilleryWeapon = import('/lua/nomadweapons.lua').ArtilleryWeapon

NLandUnit = AddAnchorAbilty(NLandUnit)
ArtilleryWeapon = SupportedArtilleryWeapon( ArtilleryWeapon )

INU3004 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(ArtilleryWeapon) {},
    },

    EnableSpecialToggle = function(self)
        self:EnableAnchor(self)
    end,

    DisableSpecialToggle = function(self)
        self:DisableAnchor(self)
    end,
}

TypeClass = INU3004