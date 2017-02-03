-- T1 tank

local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

INU1004 = Class(NHoverLandUnit) {
    Weapons = {
        MainGun = Class(ParticleBlaster1) {},
    },
}

TypeClass = INU1004
