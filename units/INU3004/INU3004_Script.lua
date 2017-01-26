-- t3 arillery

local AddAnchorAbilty = import('/lua/nomadsutils.lua').AddAnchorAbilty
local SupportedArtilleryWeapon = import('/lua/nomadsutils.lua').SupportedArtilleryWeapon
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ArtilleryWeapon = import('/lua/nomadsweapons.lua').ArtilleryWeapon

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