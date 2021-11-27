-- T1 transport

local NAirTransportUnit = import('/lua/nomadsunits.lua').NAirTransportUnit
local DummyWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

XNA0107 = Class(NAirTransportUnit) {

    Weapons = {
        GuidanceSystem = Class(DummyWeapon) {},
    },

    DestructionPartsLowToss = {0},
    DestroySeconds = 7.5,

    OnKilled = function(self, instigator, type, overkillRatio)
        self:TransportDetachAllUnits(false)
        NAirTransportUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = XNA0107