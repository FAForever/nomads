-- T3 bomber

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local EnergyBombWeapon = import('/lua/nomadsweapons.lua').EnergyBombWeapon

INA3004 = Class(NAirUnit) {
    Weapons = {
        Bomb = Class(EnergyBombWeapon) {},
    },
}

TypeClass = INA3004
