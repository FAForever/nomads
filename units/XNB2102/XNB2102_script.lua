-- t1 AA gun

local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1

XNB2102 = Class(NStructureUnit) {
    Weapons = {
        AAGun = Class(ParticleBlaster1) {},
    },
}

TypeClass = XNB2102
