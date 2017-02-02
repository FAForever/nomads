-- T3 tank

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local PlasmaCannon = import('/lua/nomadsweapons.lua').PlasmaCannon

INU3009 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(PlasmaCannon) {},
    }
}

TypeClass = INU3009