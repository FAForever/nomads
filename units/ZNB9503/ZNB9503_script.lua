-- T2 naval factory (support, non HQ)

local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit

ZNB9503 = Class(NSeaFactoryUnit) {

    OnCreate = function(self)
        NSeaFactoryUnit.OnCreate(self)

        -- hide bones
    end,
}

TypeClass = ZNB9503