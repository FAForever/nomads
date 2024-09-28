local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local AirToAirGun1 = import('/lua/nomadsweapons.lua').AirToAirGun1

--- Tech 1 Interceptor
---@class XNA0102 : NAirUnit
XNA0102 = Class(NAirUnit) {
    Weapons = {
        MainGun = Class(AirToAirGun1) {},
    },
    PlayDestructionEffects = true,
    DamageEffectPullback = 0.25,
    DestroySeconds = 7.5,
}

TypeClass = XNA0102