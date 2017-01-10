-- mobile t2 anti air

local NLandUnit = import('/lua/nomadunits.lua').NLandUnit
local RocketWeapon1 = import('/lua/nomadweapons.lua').RocketWeapon1

INU2004 = Class(NLandUnit) {
    Weapons = {
        AAGun = Class(RocketWeapon1) {},
    },
}

TypeClass = INU2004