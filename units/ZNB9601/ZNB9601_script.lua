-- T3 Land factory (support, non HQ)

local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit

ZNB9601 = Class(NLandFactoryUnit) {

    OnCreate = function(self)
        NLandFactoryUnit.OnCreate(self)

        -- hide bones
    end,
}

TypeClass = ZNB9601