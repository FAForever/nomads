-- T3 tank

local NLandUnit = import('/lua/nomadunits.lua').NLandUnit
local PlasmaCannon = import('/lua/nomadweapons.lua').PlasmaCannon

INU3009 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(PlasmaCannon) {},
    }
}

TypeClass = INU3009