local NWallStructureUnit = import('/lua/nomadsunits.lua').NWallStructureUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair
NWallStructureUnit = AddRapidRepair(NWallStructureUnit)

--- Wall
---@class XNB5101 :NWallStructureUnit
XNB5101 = Class(NWallStructureUnit) {}
TypeClass = XNB5101