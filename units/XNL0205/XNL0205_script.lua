local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1

--- Tech 2 Mobile Anti-Air
---@class XNL0205 : NLandUnit
XNL0205 = Class(NLandUnit) {
    Weapons = {
        AAGun = Class(RocketWeapon1) {},
    },
}
TypeClass = XNL0205