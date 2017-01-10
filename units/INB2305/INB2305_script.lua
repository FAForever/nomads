-- T3 nuke launcher

local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local StrategicMissileWeapon = import('/lua/nomadweapons.lua').StrategicMissileWeapon

INB2305 = Class(NStructureUnit) {
    Weapons = {
        NukeMissiles = Class(StrategicMissileWeapon) {},
    },
}

TypeClass = INB2305
