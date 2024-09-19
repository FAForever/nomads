local NEnergyCreationUnit = import('/lua/nomadsunits.lua').NEnergyCreationUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NEnergyCreationUnit = AddRapidRepair(NEnergyCreationUnit)

--- Tech 1 Power Generator
---@class XNB1101 : NEnergyCreationUnit
XNB1101 = Class(NEnergyCreationUnit) {
    ActiveEffectBone = 'exhaust',
    ActiveEffectTemplateName = 'T1PGAmbient',
}
TypeClass = XNB1101