local NWep = import('/lua/nomadsweapons.lua')
local NUtils = import('/lua/nomadsutils.lua')
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit

local AnnihilatorCannon1 = NWep.AnnihilatorCannon1
local RocketWeapon1 = NWep.RocketWeapon1
local AddRapidRepair = NUtils.AddRapidRepair
local AddRapidRepairToWeapon = NUtils.AddRapidRepairToWeapon

NLandUnit = AddRapidRepair(NLandUnit)

--- Tech 3 Tank
---@class XNL0303 : NLandUnit
XNL0303 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(AddRapidRepairToWeapon(AnnihilatorCannon1)) {},
        Rocket = Class(AddRapidRepairToWeapon(RocketWeapon1)) {},
    },
}
TypeClass = XNL0303