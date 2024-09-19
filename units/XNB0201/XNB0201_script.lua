local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NLandFactoryUnit = AddRapidRepair(NLandFactoryUnit)

--- Tech 2 Land Factory
---@class XNB0201 : NLandFactoryUnit
XNB0201 = Class(NLandFactoryUnit) {}
TypeClass = XNB0201