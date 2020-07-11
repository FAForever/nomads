-- T1 air factory

local NAirFactoryUnit = import('/lua/nomadsunits.lua').NAirFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NAirFactoryUnit = AddRapidRepair(NAirFactoryUnit)

XNB0102 = Class(NAirFactoryUnit) {}

TypeClass = XNB0102
