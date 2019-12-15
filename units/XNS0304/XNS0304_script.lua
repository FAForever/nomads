-- T3 strategic sub

local Buff = import('/lua/sim/buff.lua')
local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSubUnit = import('/lua/nomadsunits.lua').NSubUnit
local TorpedoWeapon1 = import('/lua/nomadsweapons.lua').TorpedoWeapon1
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon1

NSubUnit = AddNavalLights(NSubUnit)

XNS0304 = Class(NSubUnit) {
    Weapons = {
        MissileLauncher1 = Class(TacticalMissileWeapon1) {},
        Torpedo = Class(TorpedoWeapon1) {},
    },

    DeathThreadDestructionWaitTime = 2,
    LightBone_Left = 'Light1',
    LightBone_Right = 'Light2',
}

TypeClass = XNS0304

