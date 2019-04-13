-- T2 under water railgun defense

local AddLights = import('/lua/nomadsutils.lua').AddLights
local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local UnderwaterRailgunWeapon1 = import('/lua/nomadsweapons.lua').UnderwaterRailgunWeapon1

NStructureUnit = AddLights(NStructureUnit)

XNB2207 = Class(NStructureUnit) {
    Weapons = {
        MainGun = Class(UnderwaterRailgunWeapon1) {},
    },
    LightBones = {
        { 'flashlight.001', },
        { 'flashlight.002', },
        { 'flashlight.003', },
        { 'flashlight.004', },
    },
}

TypeClass = XNB2207