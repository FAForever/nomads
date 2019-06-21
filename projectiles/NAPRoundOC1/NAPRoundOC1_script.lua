local APRoundCap = import('/lua/nomadsprojectiles.lua').APRoundCap
local OverchargeProjectile = import('/lua/sim/DefaultProjectiles.lua').OverchargeProjectile

NAPRoundOC1 = Class(APRoundCap, OverchargeProjectile) {

    OnImpact = function(self, targetType, targetEntity)
        OverchargeProjectile.OnImpact(self, targetType, targetEntity)
        APRoundCap.OnImpact(self, targetType, targetEntity)
    end,
    
    OnCreate = function(self)
        OverchargeProjectile.OnCreate(self)
        APRoundCap.OnCreate(self)
    end,
}

TypeClass = NAPRoundOC1
