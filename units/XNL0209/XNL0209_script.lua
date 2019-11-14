-- T2 field engineer

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NConstructionUnit = import('/lua/nomadsunits.lua').NConstructionUnit
local NAMFlakWeapon = import('/lua/nomadsweapons.lua').NAMFlakWeapon

XNL0209 = Class(NConstructionUnit) {
    Weapons = {
        MainGun = Class(NAMFlakWeapon) {
            SalvoReloadTime = 1.4, --Change this to the correct amount for the weapon.
            TMDEffectBones = { 'TMD_Fx1', 'TMD_Fx2', },
        },
    },
}

TypeClass = XNL0209