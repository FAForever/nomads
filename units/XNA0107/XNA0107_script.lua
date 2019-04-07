-- T1 transport

local NAirTransportUnit = import('/lua/nomadsunits.lua').NAirTransportUnit

XNA0107 = Class(NAirTransportUnit) {

    DestructionPartsLowToss = {'XNA0107'},
    DestroySeconds = 7.5,

    OnKilled = function(self, instigator, type, overkillRatio)
        self:TransportDetachAllUnits(false)
        NAirTransportUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = XNA0107