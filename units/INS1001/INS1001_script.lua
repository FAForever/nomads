-- T1 submarine

local NSubUnit = import('/lua/nomadsunits.lua').NSubUnit
local TorpedoWeapon1 = import('/lua/nomadsweapons.lua').TorpedoWeapon1

INS1001 = Class(NSubUnit) {
    Weapons = {
        Torpedo01 = Class(TorpedoWeapon1) {},
    },
}

TypeClass = INS1001