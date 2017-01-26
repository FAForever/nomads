-- T1 naval factory

local NSeaFactoryUnit = import('/lua/nomadsunits.lua').NSeaFactoryUnit

INB0103 = Class(NSeaFactoryUnit) {    

    Calc = function(self)
        local initial, length = NSeaFactoryUnit.Calc(self)
        return -initial, -length
    end,
}

TypeClass = INB0103