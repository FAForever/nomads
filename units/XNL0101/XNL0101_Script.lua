local NHoverLandUnit = import('/lua/nomadsunits.lua').NHoverLandUnit
local SlowHoverLandUnit = import('/lua/defaultunits.lua').SlowHoverLandUnit

--- Tech 1 Land Scout
---@class XNL0101 : NHoverLandUnit, SlowHoverLandUnit
XNL0101 = Class(NHoverLandUnit, SlowHoverLandUnit) {
}
TypeClass = XNL0101