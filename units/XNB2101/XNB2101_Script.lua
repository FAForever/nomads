-- T1 point defense

local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local NDFRotatingAutocannonWeapon = import('/lua/nomadsweapons.lua').NDFRotatingAutocannonWeapon
local EffectUtils = import('/lua/effectutilities.lua')
local Effects = import('/lua/effecttemplates.lua')

XNB2101 = Class(NStructureUnit) {
    Weapons = {
        MainGun = Class(NDFRotatingAutocannonWeapon) {
            FxMuzzleScale = 2.25,
        },
    },
}

TypeClass = XNB2101