-- T3 bomber

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local EnergyBombWeapon = import('/lua/nomadsweapons.lua').EnergyBombWeapon

XNA0304 = Class(NAirUnit) {
    Weapons = {
        Bomb = Class(EnergyBombWeapon) {},
    },
}

TypeClass = XNA0304
