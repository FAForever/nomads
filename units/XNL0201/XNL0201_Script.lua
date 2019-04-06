-- T1 tank

local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

XNL0201 = Class(NHoverLandUnit, SlowHover) {
    Weapons = {
        MainGun = Class(ParticleBlaster1) {},
    },
}

TypeClass = XNL0201
