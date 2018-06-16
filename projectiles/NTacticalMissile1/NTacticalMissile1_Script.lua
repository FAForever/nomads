local NIFCruiseMissile = import('/lua/nomadsprojectiles.lua').NIFCruiseMissile
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NTacticalMissile1 = Class(NIFCruiseMissile) {
    FxImpactAirUnit = NomadsEffectTemplate.TacticalMissileHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.TacticalMissileHitLand2,
    FxImpactNone = NomadsEffectTemplate.TacticalMissileHitNone2,
    FxImpactProp = NomadsEffectTemplate.TacticalMissileHitProp2,
    FxImpactShield = NomadsEffectTemplate.TacticalMissileHitShield2,
    FxImpactUnit = NomadsEffectTemplate.TacticalMissileHitUnit2,
    FxImpactWater = NomadsEffectTemplate.TacticalMissileHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.TacticalMissileHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.TacticalMissileHitUnderWater2,

    MovementThread = function(self)
        self.WaitTime = 0.1
        if self:GetDistanceToTarget() <= 10 then
            self:SetTurnRate(180)
        else
            self:SetTurnRate(10)
        end
        WaitSeconds(0.2)
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget() --defined in NIFCruiseMissile class
        if dist > 50 then
            self:SetTurnRate(25)
        elseif dist > 40 and dist <= 213 then
            self:SetTurnRate(20)
            WaitSeconds(0.5)
            self:SetTurnRate(30)
        elseif dist > 20 and dist <= 40 then
            WaitSeconds(0.3)
            self:SetTurnRate(50)
        elseif dist > 0 and dist <= 20 then
            self:SetTurnRate(100)
            KillThread(self.MoveThread)
        end
    end,
}

TypeClass = NTacticalMissile1
