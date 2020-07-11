-- T2 naval factory

local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NSeaFactoryUnit = AddRapidRepair(NSeaFactoryUnit)

XNB0203 = Class(NSeaFactoryUnit) {}

TypeClass = XNB0203