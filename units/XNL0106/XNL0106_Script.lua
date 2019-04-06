-- T1 light tank (should match LABs in power)

local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local DarkMatterWeapon1 = import('/lua/nomadsweapons.lua').DarkMatterWeapon1
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

XNL0106 = Class(NHoverLandUnit, SlowHover) {
    Weapons = {
        MainGun = Class(DarkMatterWeapon1) {},
    },
}

TypeClass = XNL0106
