-- T1 frigate

local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local NDFRotatingAutocannonWeapon = import('/lua/nomadsweapons.lua').NDFRotatingAutocannonWeapon
local NAMFlakWeapon = import("/lua/terranweapons.lua").TAMPhalanxWeapon

XNS0103 = Class(NSeaUnit) {
    Weapons = {
        MainGun = Class(NDFRotatingAutocannonWeapon) {
            FxMuzzleScale = 2.25,
        },
        TMD01 = Class(NAMFlakWeapon) {
            TMDEffectBones = {'TMD_Targeter01','TMD_Targeter02',},
        },
    },
}

TypeClass = XNS0103
