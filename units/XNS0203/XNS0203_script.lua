-- T1 submarine

local NSubUnit = import('/lua/nomadsunits.lua').NSubUnit
local TorpedoWeapon1 = import('/lua/nomadsweapons.lua').TorpedoWeapon1

XNS0203 = Class(NSubUnit) {
    Weapons = {
        Torpedo01 = Class(TorpedoWeapon1) {},
    },
}

TypeClass = XNS0203