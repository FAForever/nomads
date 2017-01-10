-- t1 land scout

local AddAnchorAbilty = import('/lua/nomadutils.lua').AddAnchorAbilty
local NHoverLandUnit = import('/lua/nomadunits.lua').NHoverLandUnit
local DarkMatterWeapon1 = import('/lua/nomadweapons.lua').DarkMatterWeapon1

NHoverLandUnit = AddAnchorAbilty(NHoverLandUnit)

INU1002 = Class(NHoverLandUnit) {
    Weapons = {
        MainGun = Class(DarkMatterWeapon1) {},
    },

    EnableSpecialToggle = function(self)
        self:EnableAnchor(self)
    end,

    DisableSpecialToggle = function(self)
        self:DisableAnchor(self)
    end,
}

TypeClass = INU1002