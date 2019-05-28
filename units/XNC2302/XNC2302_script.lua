-- T3 orbital artillery unit (the one that floats in space), version for the campaign

local NOrbitUnit = import('/lua/nomadsunits.lua').NOrbitUnit
local OrbitalGun = import('/lua/nomadsweapons.lua').OrbitalGun

XNC2302 = Class(NOrbitUnit) {
    Weapons = {
        MainGun = Class(OrbitalGun) { },
    },

    EngineRotateBones = { 'Panel_L', 'Panel_R', },
}

TypeClass = XNC2302
