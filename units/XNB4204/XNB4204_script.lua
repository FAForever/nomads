-- TMD

local AddLights = import('/lua/nomadsutils.lua').AddLights
local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local NAMFlakWeapon = import('/lua/nomadsweapons.lua').NAMFlakWeapon

NStructureUnit = AddLights(NStructureUnit)

XNB4204 = Class(NStructureUnit) {
    Weapons = {
        Turret01 = Class(NAMFlakWeapon) {
            TMDEffectBones = {'RadarDish',},
            SalvoReloadTime = 1.4, --Change this to the correct amount for the weapon.
        },
    },

    LightBones = {
        { 'Light1', }, { 'Light2', }, { 'Light3', }, { 'Light4', }, { 'Light5', }, { 'Light6', },
    },
}

TypeClass = XNB4204