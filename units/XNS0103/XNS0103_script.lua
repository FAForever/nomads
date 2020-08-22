-- T1 frigate

local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local NDFRotatingAutocannonWeapon = import('/lua/nomadsweapons.lua').NDFRotatingAutocannonWeapon
local NAMFlakWeapon = import('/lua/nomadsweapons.lua').NAMFlakWeapon

XNS0103 = Class(NSeaUnit) {
    Weapons = {
        MainGun = Class(NDFRotatingAutocannonWeapon) {
            FxMuzzleScale = 2.25,
        },
        TMD01 = Class(NAMFlakWeapon) {
            TMDEffectBones = {'TMD_Targeter01','TMD_Targeter02',},
            SalvoReloadTime = 2, --Change this to the correct amount for the weapon.
        },
    },
}

TypeClass = XNS0103