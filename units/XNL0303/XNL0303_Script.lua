-- T3 tank

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local AnnihilatorCannon1 = import('/lua/nomadsweapons.lua').AnnihilatorCannon1
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair
local AddRapidRepairToWeapon = import('/lua/nomadsutils.lua').AddRapidRepairToWeapon

NLandUnit = AddRapidRepair(NLandUnit)

XNL0303 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(AddRapidRepairToWeapon(AnnihilatorCannon1)) {},
        Rocket = Class(AddRapidRepairToWeapon(RocketWeapon1)) {},
    },
}

TypeClass = XNL0303
