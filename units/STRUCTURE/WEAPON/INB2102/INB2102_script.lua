# t1 AA gun

local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local ParticleBlaster1 = import('/lua/nomadweapons.lua').ParticleBlaster1

INB2102 = Class(NStructureUnit) {
    Weapons = {
        AAGun = Class(ParticleBlaster1) {},
    },
}

TypeClass = INB2102
