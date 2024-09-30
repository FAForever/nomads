local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NSeaFactoryUnit = AddRapidRepair(NSeaFactoryUnit)

--- Tech 3 Naval Factory
---@class XNB0303 : NSeaFactoryUnit
XNB0303 = Class(NSeaFactoryUnit) {}
TypeClass = XNB0303