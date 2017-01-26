-- T1 transport

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit

INA1005 = Class(NAirUnit) {

    DestructionPartsLowToss = {'INA1005'},
    DestroySeconds = 7.5,

    OnKilled = function(self, instigator, type, overkillRatio)
        self:TransportDetachAllUnits(false)
        NAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = INA1005