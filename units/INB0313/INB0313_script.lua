-- T3 naval factory (support, non HQ)

local NSeaFactoryUnit = import('/lua/nomadunits.lua').NSeaFactoryUnit

INB0313 = Class(NSeaFactoryUnit) {

    OnCreate = function(self)
        NSeaFactoryUnit.OnCreate(self)

        -- hide bones
    end,
}

TypeClass = INB0313