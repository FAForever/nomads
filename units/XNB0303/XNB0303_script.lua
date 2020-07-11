-- T3 naval factory

local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NSeaFactoryUnit = AddRapidRepair(NSeaFactoryUnit)

XNB0303 = Class(NSeaFactoryUnit) {}

TypeClass = XNB0303