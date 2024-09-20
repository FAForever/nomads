local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NLandFactoryUnit = AddRapidRepair(NLandFactoryUnit)

--- Tech 3 Support Land Factory
---@class ZNB9601 : NLandFactoryUnit
ZNB9601 = Class(NLandFactoryUnit) {

    ---@param self ZNB9601
    OnCreate = function(self)
        NLandFactoryUnit.OnCreate(self)
    end,
}
TypeClass = ZNB9601