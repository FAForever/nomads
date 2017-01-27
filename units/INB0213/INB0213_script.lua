-- T2 naval factory (support, non HQ)

local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit

INB0213 = Class(NSeaFactoryUnit) {

    OnCreate = function(self)
        NSeaFactoryUnit.OnCreate(self)

        -- hide bones
    end,
}

TypeClass = INB0213