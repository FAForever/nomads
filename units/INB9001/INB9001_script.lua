-- civilian structure with gun

local AddLights = import('/lua/nomadutils.lua').AddLights
local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local GattlingWeapon1 = import('/lua/nomadweapons.lua').GattlingWeapon1

NStructureUnit = AddLights(NStructureUnit)

INB9001 = Class(NStructureUnit) {
    Weapons = {
        MainGun = Class(GattlingWeapon1) {
		    Rotates = false,
		},
    },
    LightBones = { {'Light1', 'Light2', }, {}, {}, {'Light3', 'Light4', }, },
}

TypeClass = INB9001