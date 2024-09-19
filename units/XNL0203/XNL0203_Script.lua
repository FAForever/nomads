local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local DarkMatterWeapon1 = import('/lua/nomadsweapons.lua').DarkMatterWeapon1
local SlowHoverLandUnit = import('/lua/defaultunits.lua').SlowHoverLandUnit

--- Tech 2 Fast Attack Tank
---@class XNL0203 : NHoverLandUnit, SlowHoverLandUnit
XNL0203 = Class(NHoverLandUnit, SlowHoverLandUnit) {
    Weapons = {
        MainGun = Class(DarkMatterWeapon1) {},
    },
}
TypeClass = XNL0203