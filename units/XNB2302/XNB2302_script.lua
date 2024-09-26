local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit

--- Tech 3 Stationary Artillery
---@class XNB2302 : NStructureUnit
XNB2302 = Class(NStructureUnit) {

    ---@param self XNB2302
    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
    end,

    ---@param self XNB2302
    OnDestroy = function(self)
        NStructureUnit.OnDestroy(self)
    end,

    ---@param self XNB2302
    ---@param instigator Unit
    ---@param damageType DamageType
    ---@param overkillRatio number
    OnKilled = function(self, instigator, damageType, overkillRatio)
        NStructureUnit.OnKilled(self, instigator, damageType, overkillRatio)
    end,

    ---@param self XNB2302
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self, builder, layer)
        NStructureUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}
TypeClass = XNB2302