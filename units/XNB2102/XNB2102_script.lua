local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1

--- Tech 1 Anti-Air Gun
---@class XNB2102 : NStructureUnit
XNB2102 = Class(NStructureUnit) {
    Weapons = {
        AAGun = Class(ParticleBlaster1) {},
    },
}
TypeClass = XNB2102