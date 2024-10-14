local NConstructionUnit = import('/lua/nomadsunits.lua').NConstructionUnit
local NAMFlakWeapon = import('/lua/nomadsweapons.lua').NAMFlakWeapon

--- Tech 2 Field Engineer
---@class XNL0209 : NConstructionUnit
XNL0209 = Class(NConstructionUnit) {
    Weapons = {
        MainGun = Class(NAMFlakWeapon) {
            SalvoReloadTime = 1.4, --Change this to the correct amount for the weapon.
            TMDEffectBones = { 'TMD_Fx1', 'TMD_Fx2', },
        },
    },
}
TypeClass = XNL0209

