local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NLandFactoryUnit = AddRapidRepair(NLandFactoryUnit)

--- Tech 1 Land Factory
---@class XNB0101 : NLandFactoryUnit
XNB0101 = Class(NLandFactoryUnit) {}

TypeClass = XNB0101