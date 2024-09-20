local NAirFactoryUnit = import('/lua/nomadsunits.lua').NAirFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NAirFactoryUnit = AddRapidRepair(NAirFactoryUnit)

--- Tech 2 Support Air Factory
---@class ZNB9502 : NAirFactoryUnit
ZNB9502 = Class(NAirFactoryUnit) {

    ---@param self ZNB9502
    OnCreate = function(self)
        NAirFactoryUnit.OnCreate(self)
    end,
}
TypeClass = ZNB9502