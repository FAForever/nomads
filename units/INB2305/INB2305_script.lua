-- T3 nuke launcher

local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local StrategicMissileWeapon = import('/lua/nomadsweapons.lua').StrategicMissileWeapon

INB2305 = Class(NStructureUnit) {
    Weapons = {
        NukeMissiles = Class(StrategicMissileWeapon) {},
    },
}

TypeClass = INB2305
