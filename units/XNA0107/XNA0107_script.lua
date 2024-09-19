local NAirTransportUnit = import('/lua/nomadsunits.lua').NAirTransportUnit
local DummyWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

--- Tech 1 Air Transport
---@class XNA0107 : NAirTransportUnit
XNA0107 = Class(NAirTransportUnit) {

    Weapons = {
        GuidanceSystem = Class(DummyWeapon) {},
    },

    DestructionPartsLowToss = {0},
    DestroySeconds = 7.5,

    ---@param self XNA0107
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        self:TransportDetachAllUnits(false)
        NAirTransportUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = XNA0107