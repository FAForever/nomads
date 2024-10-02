local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NLandFactoryUnit = AddRapidRepair(NLandFactoryUnit)

--- Tech 2 Support Land Factory
---@class ZNB9501 : NLandFactoryUnit
ZNB9501 = Class(NLandFactoryUnit) {

    ---@param self ZNB9501
    OnCreate = function(self)
        NLandFactoryUnit.OnCreate(self)
    end,
}
TypeClass = ZNB9501