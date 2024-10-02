local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NSeaFactoryUnit = AddRapidRepair(NSeaFactoryUnit)

--- Tech 3 Support Naval Factory
---@class ZNB9603 : NSeaFactoryUnit
ZNB9603 = Class(NSeaFactoryUnit) {

    ---@param self ZNB9603
    OnCreate = function(self)
        NSeaFactoryUnit.OnCreate(self)
    end,
}
TypeClass = ZNB9603