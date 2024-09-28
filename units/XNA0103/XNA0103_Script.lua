local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local RocketWeapon1Bomber = import('/lua/nomadsweapons.lua').RocketWeapon1Bomber

--- Tech 1 Bomber
---@class XNA0103 : NAirUnit
XNA0103 = Class(NAirUnit) {
    Weapons = {
        Rocket1 = Class(RocketWeapon1Bomber) {},
    },
}
TypeClass = XNA0103