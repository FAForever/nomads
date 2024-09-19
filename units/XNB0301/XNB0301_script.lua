local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NLandFactoryUnit = AddRapidRepair(NLandFactoryUnit)

--- Tech 3 Land Factory
---@class XNB0301 : NLandFactoryUnit
XNB0301 = Class(NLandFactoryUnit) {}
TypeClass = XNB0301