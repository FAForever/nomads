-- T3 tank

local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local AnnihilatorCannon1 = import('/lua/nomadsweapons.lua').AnnihilatorCannon1
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

INU3002 = Class(NHoverLandUnit, SlowHover) {
    Weapons = {
        MainGun = Class(AnnihilatorCannon1) {},
        Rocket = Class(RocketWeapon1) {},
    },
}

TypeClass = INU3002
