local StrategicMissile = import('/lua/nomadsprojectiles.lua').StrategicMissile
local NIFMissile = import('/lua/nomadsprojectiles.lua').NIFMissile
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local NomadsExplosions = import('/lua/nomadsexplosions.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

NOrbitalMissile1 = Class(NIFMissile) {

    FxImpactAirUnit = NomadsEffectTemplate.ArtilleryHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.ArtilleryHitLand1,
    FxImpactNone = NomadsEffectTemplate.ArtilleryHitNone1,
    FxImpactProp = NomadsEffectTemplate.ArtilleryHitProp1,
    FxImpactShield = NomadsEffectTemplate.ArtilleryHitShield1,
    FxImpactUnit = NomadsEffectTemplate.ArtilleryHitUnit1,
    FxImpactWater = NomadsEffectTemplate.ArtilleryHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.ArtilleryHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.ArtilleryHitUnderWater1,
    
    FxTrails = NomadsEffectTemplate.TacticalMissileTrail,
    PolyTrail = NomadsEffectTemplate.TacticalMissilePolyTrail,
    DoImpactFlash = true,

    -- small correction to make the smoke appear to come from the missile
    FxTrailOffset = -0.32,
    PolyTrailOffset = -0.22,
    MoveThreadDelay = 1,
    TargetSpread = 10,--This controls the spread of the bombardment projectiles

    OnCreate = function(self, inWater)
        self:SetLifetime(300)
        
        NIFMissile.OnCreate(self)
        --Adjust the target location to spread out the missiles, and make them fly above the target first
        self.TargetPos = self:GetCurrentTargetPosition()
        self.TargetPos[1] = self.TargetPos[1] + RandomFloat(-self.TargetSpread,self.TargetSpread)
        self.TargetPos[3] = self.TargetPos[3] + RandomFloat(-self.TargetSpread,self.TargetSpread)
        self:SetNewTargetGround({self.TargetPos[1],self:GetPosition()[2],self.TargetPos[3]})
        
        self:ForkThread(self.TrailThread)
    end,

    MovementThread = function(self)
        self:SetTurnRate(10)
        WaitSeconds(0.1)
        self:SetTurnRate(200) --Turn the missiles in the right direction after they exit the frigate
        WaitSeconds(0.5)
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(0.1)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > 250 then
            self:SetStage(0)
        elseif dist > 150 and dist <= 250 then
            self:SetStage(1)
            WaitSeconds(2)
        elseif dist > 60 and dist <= 150 then
            self:SetNewTargetGround(self.TargetPos) --target the ground again
            self:SetStage(2)
            WaitSeconds(3)
        elseif dist > 25 and dist <= 60 then
            self:SetStage(3)
        elseif dist > 0 and dist <= 25 then
            self:SetStage(4)
            KillThread(self.MoveThread)
        end
    end,

    --TODO:refactor this, this is crazy. use turnratebydist instead
    SetStage = function(self, stage)
        local bp = self:GetBlueprint().Physics
        local stageSetting = ''
        if stage > 0 then
            stageSetting = 'S'..stage
        end
        
        self:SetTurnRate( bp['TurnRate'..stageSetting] or bp.TurnRate)
        self:SetMaxSpeed( bp['MaxSpeed'..stageSetting] or bp.MaxSpeed)
        self:SetVelocity( bp['MaxSpeed'..stageSetting] or bp.MaxSpeed)
        self:ChangeMaxZigZag( bp['MaxZigZag'..stageSetting] or bp.MaxZigZag)
        self:ChangeZigZagFrequency( bp['ZigZagFrequency'..stageSetting] or bp.ZigZagFrequency)
    end,
    
    OnImpact = function(self, targetType, targetEntity)
        NIFMissile.OnImpact(self, targetType, targetEntity)
        
        local army = self:GetArmy()
        local pos = self:GetPosition()

        NomadsExplosions.CreateArtilleryImpactLarge(self, pos, army, targetType)
    end,

    TrailThread = function(self)
        -- add a trail when the projectile enters the atmosphere

        local bp = self:GetBlueprint().Display.Trail
        local pos = self:GetPosition()
        local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
        local height = surface + bp.AtmosphereHeight

        while self and not self:BeenDestroyed() and pos[2] > height do
            WaitTicks(1)
            pos = self:GetPosition()
        end
        
        if self and not self:BeenDestroyed() then
            for k, v in  NomadsEffectTemplate.OrbitalStrikeMissile_AtmosphereTrail do
                self.Trash:Add( CreateAttachedEmitter( self, -1, self:GetArmy(), v ) )
            end
        end
    end,
}

TypeClass = NOrbitalMissile1
