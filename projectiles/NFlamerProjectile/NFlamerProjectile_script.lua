local Flamer = import('/lua/nomadsprojectiles.lua').Flamer

NFlamerProjectile = Class(Flamer) {

    FxTrailScale = 0,
    FxAirUnitHitScale = 0.0,
    FxLandHitScale = 0.0,
    FxNoneHitScale = 0.0,
    FxPropHitScale = 0.0,
    FxProjectileHitScale = 0.0,
    FxProjectileUnderWaterHitScale = 0.0,
    FxShieldHitScale = 0.0,
    FxUnderWaterHitScale = 0.0,
    FxUnitHitScale = 0.0,
    FxWaterHitScale = 0.0,
    FxOnKilledScale = 0.0,

    OnCreate = function(self)
        NapalmProjectile.OnCreate(self)
        self:ForkThread(self.DamageAreaThread)
    end,

    DamageAreaThread = function(self)
        while self and not self:BeenDestroyed() do
-- use to better see the projectile traveling
--    CreateLightParticle( self, -1, self:GetLauncher():GetArmy(), 6, 14, 'glow_03', 'ramp_flare_02' )
            DamageArea( self:GetLauncher() or self, self:GetPosition(), self.DamageData.DamageRadius, self.DamageData.DamageAmount, self.DamageData.DamageType, self.DamageData.DamageFriendly, false )
            WaitTicks(1)
        end
    end,

    OnCollisionCheck = function(self,other)
        if self and other and ( IsUnit(other) or IsProjectile(other) or IsProp(other) ) then
            return false
        else
            NapalmProjectile.OnCollisionCheck(self,other)
        end
    end,

    OnImpactDestroy = function( self, targetType, targetEntity )
        if targetType == "Terrain" or targetType == "Shield" or targetType == "Air" then
            NapalmProjectile.OnImpactDestroy(self, targetType, targetEntity)
        end
    end,
}

TypeClass = NFlamerProjectile