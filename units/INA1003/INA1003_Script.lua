-- T1 bomber

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1

INA1003 = Class(NAirUnit) {
    Weapons = {
        Rocket1 = Class(RocketWeapon1) {},
        Rocket2 = Class(RocketWeapon1) {},
        Rocket3 = Class(RocketWeapon1) {},
        Rocket4 = Class(RocketWeapon1) {},
    },
}

TypeClass = INA1003

