-- T2 fast attack tank

local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local DarkMatterWeapon1 = import('/lua/nomadsweapons.lua').DarkMatterWeapon1
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

INU2002 = Class(NHoverLandUnit, SlowHover) {
    Weapons = {
        MainGun = Class(DarkMatterWeapon1) {},
    },
}

TypeClass = INU2002
