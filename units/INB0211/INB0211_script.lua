-- T2 land factory (support, non HQ)

local NLandFactoryUnit = import('/lua/nomadsunits.lua').NLandFactoryUnit

INB0211 = Class(NLandFactoryUnit) {

    OnCreate = function(self)
        NLandFactoryUnit.OnCreate(self)

        -- hide bones to show difference between this factory and the HQ
--        self:HideBone('', true)
    end,
}

TypeClass = INB0211