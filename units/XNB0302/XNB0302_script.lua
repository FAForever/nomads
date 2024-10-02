local NAirFactoryUnit = import('/lua/nomadsunits.lua').NAirFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NAirFactoryUnit = AddRapidRepair(NAirFactoryUnit)

--- Tech 3 Air Factory
---@class XNB0302 : NAirFactoryUnit
XNB0302 = Class(NAirFactoryUnit) {}
TypeClass = XNB0302