-- T3 air factory (support, non HQ)

local NAirFactoryUnit = import('/lua/nomadunits.lua').NAirFactoryUnit

INB0312 = Class(NAirFactoryUnit) {

    OnCreate = function(self)
        NAirFactoryUnit.OnCreate(self)

        -- hide bones
    end,
}

TypeClass = INB0312
