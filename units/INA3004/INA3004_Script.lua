-- T3 bomber

local NAirUnit = import('/lua/nomadunits.lua').NAirUnit
local EnergyBombWeapon = import('/lua/nomadweapons.lua').EnergyBombWeapon

INA3004 = Class(NAirUnit) {
    Weapons = {
        Bomb = Class(EnergyBombWeapon) {},
    },
}

TypeClass = INA3004
