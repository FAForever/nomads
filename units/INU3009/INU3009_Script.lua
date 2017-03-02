-- T3 tank

local AddAnchorAbilty = import('/lua/nomadsutils.lua').AddAnchorAbilty
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local PlasmaCannon = import('/lua/nomadsweapons.lua').PlasmaCannon

NLandUnit = AddAnchorAbilty(NLandUnit)

INU3009 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(PlasmaCannon) {},
    },

    EnableSpecialToggle = function(self)
        self:EnableAnchor(self)
    end,

    DisableSpecialToggle = function(self)
        self:DisableAnchor(self)
    end,
}

TypeClass = INU3009