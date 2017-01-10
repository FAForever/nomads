-- T3 ASF

local NAirUnit = import('/lua/nomadunits.lua').NAirUnit
local AirToAirGun1 = import('/lua/nomadweapons.lua').AirToAirGun1

INA3003 = Class(NAirUnit) {
    Weapons = {
        RightGun = Class(AirToAirGun1) {},
        LeftGun = Class(AirToAirGun1) {},
    },
}

TypeClass = INA3003