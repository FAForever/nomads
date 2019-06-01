local APRound = import('/lua/nomadsprojectiles.lua').APRound
local OverchargeProjectile = import('/lua/sim/DefaultProjectiles.lua').OverchargeProjectile


NAPRoundOC1 = Class(APRound, OverchargeProjectile) {

    OnImpact = function(self, targetType, targetEntity)
        OverchargeProjectile.OnImpact(self, targetType, targetEntity)
        APRound.OnImpact(self, targetType, targetEntity)
    end,
    
    OnCreate = function(self)
        OverchargeProjectile.OnCreate(self)
        APRound.OnCreate(self)
    end,
}

TypeClass = NAPRoundOC1
