# T1 light tank (should match LABs in power)

local NHoverLandUnit = import('/lua/nomadunits.lua').NHoverLandUnit
local DarkMatterWeapon1 = import('/lua/nomadweapons.lua').DarkMatterWeapon1

INU1007 = Class(NHoverLandUnit) {
    Weapons = {
        MainGun = Class(DarkMatterWeapon1) {},
    },
}

TypeClass = INU1007