-- T1 light tank (should match LABs in power)

local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

XNL0106 = Class(NHoverLandUnit, SlowHover) {
    Weapons = {
        MainGun = Class(ParticleBlaster1) {},
    },
}

TypeClass = XNL0106
