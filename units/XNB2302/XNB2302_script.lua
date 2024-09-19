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
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        NStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    ---@param self XNB2302
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self, builder, layer)
        NStructureUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}
TypeClass = XNB2302

--#region Backwards Compatibility
local NUtils = import('/lua/nomadsutils.lua')
--#endregion