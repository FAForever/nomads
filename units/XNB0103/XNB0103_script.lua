local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NSeaFactoryUnit = AddRapidRepair(NSeaFactoryUnit)

--- Tech 1 Naval Factory
---@class XNB0103 : NSeaFactoryUnit
XNB0103 = Class(NSeaFactoryUnit) {

    ---@param self XNB0103
    ---@return number
    ---@return number
    Calc = function(self)
        local initial, length = NSeaFactoryUnit.Calc(self)
        return -initial, -length
    end,
}
TypeClass = XNB0103