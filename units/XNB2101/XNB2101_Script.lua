local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local NDFRotatingAutocannonWeapon = import('/lua/nomadsweapons.lua').NDFRotatingAutocannonWeapon

--- Tech 1 Point Defence
---@class XNB2101 : NStructureUnit
XNB2101 = Class(NStructureUnit) {
    Weapons = {
        MainGun = Class(NDFRotatingAutocannonWeapon) {
            FxMuzzleScale = 2.25,
        },
    },
}
TypeClass = XNB2101