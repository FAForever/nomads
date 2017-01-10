-- T3 Land factory (support, non HQ)

local NLandFactoryUnit = import('/lua/nomadunits.lua').NLandFactoryUnit

INB0311 = Class(NLandFactoryUnit) {

    OnCreate = function(self)
        NLandFactoryUnit.OnCreate(self)

        -- hide bones
    end,
}

TypeClass = INB0311