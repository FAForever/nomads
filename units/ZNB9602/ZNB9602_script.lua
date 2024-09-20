local NAirFactoryUnit = import('/lua/nomadsunits.lua').NAirFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NAirFactoryUnit = AddRapidRepair(NAirFactoryUnit)

--- Tech 3 Support Air Factory
---@class ZNB9602 : NAirFactoryUnit
ZNB9602 = Class(NAirFactoryUnit) {

    ---@param self ZNB9602
    OnCreate = function(self)
        NAirFactoryUnit.OnCreate(self)
    end,
}
TypeClass = ZNB9602