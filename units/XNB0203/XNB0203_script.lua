local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NSeaFactoryUnit = AddRapidRepair(NSeaFactoryUnit)

--- Tech 2 Naval Factory
---@class XNB0203 : NSeaFactoryUnit
XNB0203 = Class(NSeaFactoryUnit) {}
TypeClass = XNB0203