local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local ArcingTacticalMissile = import('/lua/nomadsprojectiles.lua').ArcingTacticalMissile
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local util = import('/lua/utilities.lua')
local GetRandomFloat = util.GetRandomFloat

NTacticalMissile3_HighArc = Class(ArcingTacticalMissile) {
    FxImpactAirUnit = NomadsEffectTemplate.ArcingTacticalMissileHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.ArcingTacticalMissileHitLand2,
    FxImpactNone = NomadsEffectTemplate.ArcingTacticalMissileHitNone2,
    FxImpactProp = NomadsEffectTemplate.ArcingTacticalMissileHitProp2,
    FxImpactShield = NomadsEffectTemplate.ArcingTacticalMissileHitShield2,
    FxImpactUnit = NomadsEffectTemplate.ArcingTacticalMissileHitUnit2,
    FxImpactWater = NomadsEffectTemplate.ArcingTacticalMissileHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.ArcingTacticalMissileHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.ArcingTacticalMissileHitUnderWater2,

    -- To accomodate the Aeon TMD that uses flares to distract and redirect tactical missiles some additional code is added here.
    -- It makes missiles not speed up if flared by the Aeon TMD but missiles that have sped up do not react to the TMD (this is
    -- handled in the defaultantimissile.lua file).
	
    OnImpact = function(self, targetType, targetEntity)
        if targetType == 'Air' and not targetEntity then
            if self:IsFlared() then
                self:ChangeDetonateBelowHeight(0)
            else
                self:SpeedUp()
            end
        else
            ArcingTacticalMissile.OnImpact(self, targetType, targetEntity)
        end
    end,

    SpeedUp = function(self)
        -- create clone projectile, the original can't increase speed for some reason but a clone can
--        local ChildProjectileBP = '/projectiles/NTacticalMissile3_HighArc/NTacticalMissile3_HighArc_proj.bp'
        local ChildProjectileBP = '/projectiles/NPlasmaProj1_arty/NPlasmaProj1_arty_proj.bp'
        local vx, vy, vz = self:GetVelocity()
        local velocity = self:GetCurrentSpeed() * 30

        local child = self:CreateChildProjectile(ChildProjectileBP)
        child:ChangeDetonateBelowHeight(0)
        child:SetMaxSpeed(velocity)
        child:SetVelocity(vx, vy, vz)
        child:SetVelocity(velocity)
        child:PassDamageData(self.DamageData)
        child:SetLifetime( child:GetBlueprint().Physics.LifetimeSpeedup or child:GetBlueprint().Physics.Lifetime or 1 )
        child.OnFlare_SetTrackTarget = false

        -- Split effects
        for k, v in NomadsEffectTemplate.ArcingTacticalMissileSpeedupFlash do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end

        self:Destroy()
    end,
}

TypeClass = NTacticalMissile3_HighArc
