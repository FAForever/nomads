-- T3 tank

local AddAnchorAbilty = import('/lua/nomadsutils.lua').AddAnchorAbilty
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local PlasmaCannon = import('/lua/nomadsweapons.lua').PlasmaCannon

XNL0305 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(PlasmaCannon) {},
    },
}

TypeClass = XNL0305