-- T3 Land factory

local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NLandFactoryUnit = AddRapidRepair(NLandFactoryUnit)

XNB0301 = Class(NLandFactoryUnit) {}

TypeClass = XNB0301