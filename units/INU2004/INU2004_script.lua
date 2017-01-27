-- mobile t2 anti air

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1

INU2004 = Class(NLandUnit) {
    Weapons = {
        AAGun = Class(RocketWeapon1) {},
    },
}

TypeClass = INU2004