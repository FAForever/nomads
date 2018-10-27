-- T1 bomber

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local RocketWeapon1Bomber = import('/lua/nomadsweapons.lua').RocketWeapon1Bomber

INA1003 = Class(NAirUnit) {
    Weapons = {
        Rocket1 = Class(RocketWeapon1Bomber) {},
    },
}

TypeClass = INA1003

