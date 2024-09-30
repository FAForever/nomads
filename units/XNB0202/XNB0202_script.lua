local NAirFactoryUnit = import('/lua/nomadsunits.lua').NAirFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NAirFactoryUnit = AddRapidRepair(NAirFactoryUnit)

--- Tech 2 Air Factory
---@class XNB0202 : NAirFactoryUnit
XNB0202 = Class(NAirFactoryUnit) {}
TypeClass = XNB0202