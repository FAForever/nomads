# T2 fast attack tank

local NHoverLandUnit = import('/lua/nomadunits.lua').NHoverLandUnit
local DarkMatterWeapon1 = import('/lua/nomadweapons.lua').DarkMatterWeapon1

INU2002 = Class(NHoverLandUnit) {
    Weapons = {
        MainGun = Class(DarkMatterWeapon1) {},
    },
}

TypeClass = INU2002