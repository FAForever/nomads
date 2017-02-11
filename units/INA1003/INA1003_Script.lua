-- T1 bomber

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local RocketWeapon1Bomber = import('/lua/nomadsweapons.lua').RocketWeapon1Bomber

INA1003 = Class(NAirUnit) {
    Weapons = {
        Rocket1 = Class(RocketWeapon1Bomber) {},
        Rocket2 = Class(RocketWeapon1Bomber) {},
        Rocket3 = Class(RocketWeapon1Bomber) {},
        Rocket4 = Class(RocketWeapon1Bomber) {},
    },
}

TypeClass = INA1003

