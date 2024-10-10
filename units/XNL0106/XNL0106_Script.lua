local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local DarkMatterWeapon1 = import('/lua/nomadsweapons.lua').DarkMatterWeapon1
local SlowHoverLandUnit = import('/lua/defaultunits.lua').SlowHoverLandUnit

--- Tech 1 Light Tank (LAB Equivalent)  
---@class XNL0106 : NHoverLandUnit, SlowHoverLandUnit
XNL0106 = Class(NHoverLandUnit, SlowHoverLandUnit) {
    Weapons = {
        MainGun = Class(DarkMatterWeapon1) {},
    },
}
TypeClass = XNL0106