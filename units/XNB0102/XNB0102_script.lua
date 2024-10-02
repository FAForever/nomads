local NAirFactoryUnit = import('/lua/nomadsunits.lua').NAirFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NAirFactoryUnit = AddRapidRepair(NAirFactoryUnit)

--- Tech 1 Air Factory
---@class XNB0102 :NAirFactoryUnit
XNB0102 = Class(NAirFactoryUnit) {}
TypeClass = XNB0102