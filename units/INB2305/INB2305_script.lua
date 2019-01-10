-- T3 nuke launcher

local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local StrategicMissileWeapon = import('/lua/nomadsweapons.lua').StrategicMissileWeapon

INB2305 = Class(NStructureUnit) {
    Weapons = {
        NukeMissiles = Class(StrategicMissileWeapon) {},
    },
    
    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
        self.NukeEntity = 1 --leave a value for the death explosion entity to use later.
    end,
}

TypeClass = INB2305
