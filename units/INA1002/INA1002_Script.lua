-- T1 interceptor

local NAirUnit = import('/lua/nomadunits.lua').NAirUnit
local AirToAirGun1 = import('/lua/nomadweapons.lua').AirToAirGun1

INA1002 = Class(NAirUnit) {
    Weapons = {
        MainGun = Class(AirToAirGun1) {},
    },
    PlayDestructionEffects = true,
    DamageEffectPullback = 0.25,
    DestroySeconds = 7.5,
}

TypeClass = INA1002