-- t1 land scout

local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local DarkMatterWeapon1 = import('/lua/nomadsweapons.lua').DarkMatterWeapon1
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

NHoverLandUnit = AddAnchorAbilty(NHoverLandUnit)

XNL0101 = Class(NHoverLandUnit, SlowHover) {
    Weapons = {
        MainGun = Class(DarkMatterWeapon1) {},
    },
}

TypeClass = XNL0101
