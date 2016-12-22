# T2 air factory (support, non HQ)

local NAirFactoryUnit = import('/lua/nomadunits.lua').NAirFactoryUnit

INB0212 = Class(NAirFactoryUnit) {

    OnCreate = function(self)
        NAirFactoryUnit.OnCreate(self)

        # Hide bones
    end,
}

TypeClass = INB0212
