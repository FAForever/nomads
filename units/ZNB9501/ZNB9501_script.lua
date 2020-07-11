-- T2 land factory (support, non HQ)

local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NLandFactoryUnit = AddRapidRepair(NLandFactoryUnit)

ZNB9501 = Class(NLandFactoryUnit) {

    OnCreate = function(self)
        NLandFactoryUnit.OnCreate(self)

        -- hide bones to show difference between this factory and the HQ
--        self:HideBone('', true)
    end,
}

TypeClass = ZNB9501