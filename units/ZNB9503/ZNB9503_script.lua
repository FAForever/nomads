local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NSeaFactoryUnit = AddRapidRepair(NSeaFactoryUnit)

--- Tech 2 Support Naval Factory
---@class ZNB9503 : NSeaFactoryUnit
ZNB9503 = Class(NSeaFactoryUnit) {

    ---@param self ZNB9503
    OnCreate = function(self)
        NSeaFactoryUnit.OnCreate(self)
    end,
}
TypeClass = ZNB9503