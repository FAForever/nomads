-- T1 tank

local NHoverLandUnit = import('/lua/nomadunits.lua').NHoverLandUnit
local ParticleBlaster1 = import('/lua/nomadweapons.lua').ParticleBlaster1

INU1004 = Class(NHoverLandUnit) {
    Weapons = {
        MainGun = Class(ParticleBlaster1) {},
    },
}

TypeClass = INU1004
