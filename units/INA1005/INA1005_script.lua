-- T1 transport

local NAirTransportUnit = import('/lua/nomadsunits.lua').NAirTransportUnit

INA1005 = Class(NAirTransportUnit) {

    DestructionPartsLowToss = {'INA1005'},
    DestroySeconds = 7.5,

    OnKilled = function(self, instigator, type, overkillRatio)
        self:TransportDetachAllUnits(false)
        NAirTransportUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = INA1005