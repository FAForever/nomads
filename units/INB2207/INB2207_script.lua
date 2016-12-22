# T2 under water railgun defense

local AddLights = import('/lua/nomadutils.lua').AddLights
local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local UnderwaterRailgunWeapon1 = import('/lua/nomadweapons.lua').UnderwaterRailgunWeapon1

NStructureUnit = AddLights(NStructureUnit)

INB2207 = Class(NStructureUnit) {
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

TypeClass = INB2207