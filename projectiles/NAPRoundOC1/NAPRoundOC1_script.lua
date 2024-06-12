local APRoundCap = import('/lua/nomadsprojectiles.lua').APRoundCap
local OverchargeProjectile = import('/lua/sim/defaultprojectiles.lua').OverchargeProjectile

---@class NAPRoundOC1 : APRoundCap, OverchargeProjectile
NAPRoundOC1 = Class(APRoundCap, OverchargeProjectile) {

    ---@param self NAPRoundOC1
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        OverchargeProjectile.OnImpact(self, targetType, targetEntity)
        APRoundCap.OnImpact(self, targetType, targetEntity)
    end,

    ---@param self NAPRoundOC1
    OnCreate = function(self)
        OverchargeProjectile.OnCreate(self)
        APRoundCap.OnCreate(self)
    end,
}
TypeClass = NAPRoundOC1