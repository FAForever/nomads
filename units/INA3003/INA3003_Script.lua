-- T3 ASF

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local AirToAirGun1 = import('/lua/nomadsweapons.lua').AirToAirGun1

INA3003 = Class(NAirUnit) {
    Weapons = {
        RightGun = Class(AirToAirGun1) {},
        LeftGun = Class(AirToAirGun1) {},
    },
}

TypeClass = INA3003