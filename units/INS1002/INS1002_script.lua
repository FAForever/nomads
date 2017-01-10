-- T1 frigate

local AddNavalLights = import('/lua/nomadutils.lua').AddNavalLights
local NSeaUnit = import('/lua/nomadunits.lua').NSeaUnit
local StingrayCannon1 = import('/lua/nomadweapons.lua').StingrayCannon1
local RocketWeapon1 = import('/lua/nomadweapons.lua').RocketWeapon1

NSeaUnit = AddNavalLights(NSeaUnit)

INS1002 = Class(NSeaUnit) {
    Weapons = {
        MainGun = Class(StingrayCannon1) {},
        AAGun = Class(RocketWeapon1) {},
    },

    LightBone_Left = 'light.002',
    LightBone_Right = 'light.001',
}

TypeClass = INS1002