local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = DefaultProjectileFile.EmitterProjectile
local OnWaterEntryEmitterProjectile = DefaultProjectileFile.OnWaterEntryEmitterProjectile
local SingleBeamProjectile = DefaultProjectileFile.SingleBeamProjectile
local MultiBeamProjectile = DefaultProjectileFile.MultiBeamProjectile
local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile
local NukeProjectile = DefaultProjectileFile.NukeProjectile
local NullShell = DefaultProjectileFile.NullShell

local Projectile = import('/lua/sim/Projectile.lua').Projectile

local EffectTemplate = import('/lua/EffectTemplates.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

local UtilsFile = import('/lua/utilities.lua')
local RandomFloat = UtilsFile.GetRandomFloat
local XZDist = UtilsFile.XZDistanceTwoVectors
local RandomOffsetTrackingTarget = UtilsFile.RandomOffsetTrackingTarget
local NomadsExplosions = import('/lua/nomadsexplosions.lua')


--When adding weapon classes, follow the FAF naming conventions - NIFMissile

-- -----------------------------------------------------------------------------------------------------
-- Missiles
-- -----------------------------------------------------------------------------------------------------

--- Base missile classes
--- Missiles that lead target units, while not homing in on the units themselves. Not a standalone class.
---@class NIFTargetLeadingMissile
NIFTargetLeadingMissile = Class() {

    ---@param self NIFTargetLeadingMissile
    LeadTargetGroundThread = function(self)
        local trackingTarget = self:GetTrackingTarget()
        if trackingTarget and IsUnit(trackingTarget) and trackingTarget:GetCurrentLayer() == 'Land' then
            WaitSeconds(0.1)
            --Save the target incase we need to turn on target tracking later
            self.TargetUnit = trackingTarget

            local targetData = {pos=self.TargetUnit:GetPosition(), vel=VMult(Vector(self.TargetUnit:GetVelocity()), 10)}
            local deltaDistance = XZDist(self:GetPosition(), self.TargetUnit:GetPosition())
            local deltaVelocity = XZDist(VMult(Vector(self:GetVelocity()), 10), targetData.vel)

            if deltaVelocity == 0 then return end

            local deltaTime = deltaDistance / deltaVelocity

            -- find out where the target will be when the projectile will hit it
            targetData.tpos = {targetData.pos[1] + deltaTime * targetData.vel[1], 0, targetData.pos[3] + deltaTime * targetData.vel[3]}
            targetData.tpos[2] = GetSurfaceHeight(targetData.tpos[1], targetData.tpos[3])
            self:SetNewTargetGround(targetData.tpos)
        end
    end,
}

--- Anti Air Missiles
---@class NAAMissle :SingleCompositeEmitterProjectile
NAAMissile = Class(SingleCompositeEmitterProjectile) { 
    --TODO:give it a better name?

    BeamName = NomadsEffectTemplate.MissileBeam,

    FxImpactAirUnit = NomadsEffectTemplate.MissileHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.MissileHitLand1,
    FxImpactNone = NomadsEffectTemplate.MissileHitNone1,
    FxImpactProp = NomadsEffectTemplate.MissileHitProp1,
    FxImpactShield = NomadsEffectTemplate.MissileHitShield1,
    FxImpactUnit = NomadsEffectTemplate.MissileHitUnit1,
    FxImpactWater = NomadsEffectTemplate.MissileHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.MissileHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.MissileHitUnderWater1,

    FxTrails = NomadsEffectTemplate.MissileTrail,
    PolyTrail = NomadsEffectTemplate.MissilePolyTrail,

    ---@param self NAAMissile
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SingleCompositeEmitterProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1.5, 2.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

-- Direct Fire Missiles

-- These can enter the water and act as torpedoes
---@class NDFAmphibiousMissile : NAAMissile, NIFTargetLeadingMissile
NDFAmphibiousMissile = Class(NAAMissile, NIFTargetLeadingMissile) {
    EnterWaterSound = 'Torpedo_Enter_Water_01',
    FxTrailsWater = {'/effects/emitters/torpedo_munition_trail_01_emit.bp',},
    FxEnterWater= EffectTemplate.WaterSplash01,

    ---@param self NDFAmphibiousMissile
    ---@param inWater boolean # Unused
    OnCreate = function(self, inWater)
        NAAMissile.OnCreate(self)
        self:ForkThread(NIFTargetLeadingMissile.LeadTargetGroundThread)
    end,

    ---@param self NDFAmphibiousMissile
    OnEnterWater = function(self)
        NAAMissile.OnEnterWater(self)
        self:TrackTarget(true)
        self:StayUnderwater(true)
        self:SetMaxSpeed(5)
        self:ChangeMaxZigZag(0)
        self:SetTurnRate(360)
        if self.TargetUnit and IsUnit(self.TargetUnit) then
            self:SetNewTarget(self.TargetUnit) --turn on full-on tracking if we are targeting stuff in the water
        end
        --play some water effects
        for i in self.FxTrailsWater do
            CreateEmitterOnEntity(self, self.Army, self.FxTrailsWater[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end

        for k, v in self.FxEnterWater do
            CreateEmitterAtEntity(self, self.Army ,v)
        end
        
        self:ForkThread(self.WaterEntryThread)
    end,

    ---@param self NDFAmphibiousMissile
    WaterEntryThread = function(self)
        WaitSeconds(0.2)
        self:SetMaxSpeed(10)
    end,
}

-- Cruise Missiles -- MML TML, indirect fire

-- base class for missiles that target the ground, and so need a turn rate by distance mechanic.
---@class NIFMissile : SingleCompositeEmitterProjectile
NIFMissile = Class(SingleCompositeEmitterProjectile) {
    MoveThreadDelay = 0.2,

    ---@param self NIFMissile
    ---@param inwater Boolean
    OnCreate = function(self, inwater)
        SingleCompositeEmitterProjectile.OnCreate(self, inwater)
        self:SetDestroyOnWater(true)
        self.MoveThread = self:ForkThread( self.MovementThread )
    end,

    ---@param self NIFMissile
    MovementThread = function(self)
        self.WaitTime = 0.1
        if self:GetDistanceToTarget() <= 10 then
            self:SetTurnRate(180)
        else
            self:SetTurnRate(10)
        end
        WaitSeconds(self.MoveThreadDelay)
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    ---@param self NIFMissile
    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
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

    ---@param self NIFMissile
    ---@return nil
    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
}

---@class NIFOrbitalMissile : NIFMissile
NIFOrbitalMissile = Class(NIFMissile) {
    FxImpactAirUnit = NomadsEffectTemplate.ArtilleryHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.ArtilleryHitLand1,
    FxImpactNone = NomadsEffectTemplate.ArtilleryHitNone1,
    FxImpactProp = NomadsEffectTemplate.ArtilleryHitProp1,
    FxImpactShield = NomadsEffectTemplate.ArtilleryHitShield1,
    FxImpactUnit = NomadsEffectTemplate.ArtilleryHitUnit1,
    FxImpactWater = NomadsEffectTemplate.ArtilleryHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.ArtilleryHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.ArtilleryHitUnderWater1,

    --the effects were a bit much so just scaling them down a bit
    FxAirUnitHitScale = 0.7,
    FxLandHitScale = 0.7,
    FxNoneHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxProjectileHitScale = 0.7,
    FxProjectileUnderWaterHitScale = 0.7,
    FxShieldHitScale = 0.7,
    FxUnderWaterHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxWaterHitScale = 0.7,
    FxOnKilledScale = 0.7,

    FxTrails = NomadsEffectTemplate.TacticalMissileTrail,
    PolyTrail = NomadsEffectTemplate.TacticalMissilePolyTrail,
    DoImpactFlash = true,

    -- small correction to make the smoke appear to come from the missile
    FxTrailOffset = -0.32,
    PolyTrailOffset = -0.22,
    TargetSpread = 10,--This controls the spread of the bombardment projectiles

    ---@param self NIFOrbitalMissile
    ---@param inWater boolean # Unused
    OnCreate = function(self, inWater)
        self:SetLifetime(100)
        self:SetCollisionShape('Sphere', 0, 0, 0, 3)

        NIFMissile.OnCreate(self)
        --Save the target location to spread out the missiles
        self.TargetPos = RandomOffsetTrackingTarget(self, self.TargetSpread)

        self:ForkThread(self.TrailThread)
    end,

    ---@param self NIFOrbitalMissile
    ---@return nil
    GetLauncher = function(self)
        --this just swaps the priorities on returning the launcher value before the engine function so we can use this to transfer veterancy.
        --ideally we would use an Instigator variable and set that in OnImpact directly, but that would need destructive hooks.
        return self.Launcher or NIFMissile.GetLauncher(self)
    end,

    ---@param self NIFOrbitalMissile
    MovementThread = function(self)
        self:SetTurnRate(10)
        WaitSeconds(0.1)
        self:SetTurnRate(200) --Turn the missiles in the right direction after they exit the frigate
        local pos = self:GetPosition()
        self:SetNewTargetGround({pos[1],pos[2] - 70,pos[3]}) --make the missiles fly down to similar elevation to other TMLs
        WaitSeconds(2.8)
        --make the missiles fly across horizontally before arcing down further
        self:SetNewTargetGround({self.TargetPos[1],self:GetPosition()[2],self.TargetPos[3]})
        WaitSeconds(0.2)
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(0.1)
        end
    end,

    ---@param self NIFOrbitalMissile
    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > 250 then
            self:SetStage(0)
            WaitSeconds(0.5)
        elseif dist > 60 and dist <= 250 then
            self:SetStage(1)
            WaitSeconds(1)
        elseif dist > 25 and dist <= 60 then
            self:SetNewTargetGround(self.TargetPos) --target the ground again
            self:SetStage(2)
            WaitSeconds(0.1)
        elseif dist > 0 and dist <= 25 then
            self:SetNewTargetGround(self.TargetPos) --target the ground again
            self:SetStage(3)
            KillThread(self.MoveThread)
        end
    end,

    --TODO:refactor this, this is crazy. use turnratebydist instead
    ---@param self NIFOrbitalMissile
    ---@param stage any
    SetStage = function(self, stage)
        local bp = self:GetBlueprint().Physics
        local stageSetting = ''
        if stage > 0 then
            stageSetting = 'S'..stage
        end
        self:SetTurnRate( bp['TurnRate'..stageSetting] or bp.TurnRate)
        self:SetMaxSpeed( bp['MaxSpeed'..stageSetting] or bp.MaxSpeed)
        self:SetVelocity( bp['MaxSpeed'..stageSetting] or bp.MaxSpeed)
        self:ChangeZigZagFrequency( bp['ZigZagFrequency'..stageSetting] or bp.ZigZagFrequency)
    end,

    ---@param self NIFOrbitalMissile
    ---@param targetType any
    ---@param targetEntity Enitiy
    OnImpact = function(self, targetType, targetEntity)
        NIFMissile.OnImpact(self, targetType, targetEntity)
        local pos = self:GetPosition()
        NomadsExplosions.CreateArtilleryImpactLarge(self, pos, self.Army, targetType)
    end,

    --Prevent taking damage from friendly targets such as AOE explosions
    ---@param self NIFOrbitalMissile
    ---@param instigator Unit
    ---@param amount number
    ---@param vector Vector2
    ---@param damageType string
    OnDamage = function(self, instigator, amount, vector, damageType)
        if instigator.Army ~= self.Army then
            NIFMissile.OnDamage(self, instigator, amount, vector, damageType)
        end
    end,

    ---@param self NIFOrbitalMissile
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
                self.Trash:Add( CreateAttachedEmitter( self, -1, self.Army, v ) )
            end
        end
    end,
}

--Longrange tactical missile (used by Crawler, Devourer, could be reused for Leviathan later)
---@class NIFArtilleryMissile : NIFMissile
NIFArtilleryMissile = Class(NIFMissile) {

    BeamName = NomadsEffectTemplate.TacticalMissileBeam,

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
    FxTrailsUnderWater = NomadsEffectTemplate.TacticalMissileTrail,
    PolyTrail = NomadsEffectTemplate.TacticalMissilePolyTrail,

    -- small correction to make the smoke appear to come from the missile
    FxTrailOffset = -0.16,
    PolyTrailOffset = -0.11,
    FxTrailScale = 0.5,

    FxImpactTrajectoryAligned = false,

    DoImpactFlash = true,

    ---@param self NIFArtilleryMissile
    ---@param inwater boolean
    OnCreate = function(self, inwater)
        self:SetCollisionShape('Sphere', 0, 0, 0, 3.0)
        --if we are underwater we want to do things differently, like have different Fx and stuff.
        if inwater then
            --we bypass much of the trail creation stuff here, and add our own things instead, later.
            Projectile.OnCreate(self)
            self:SetDestroyOnWater(false)
            self.UnderWaterEmitters = TrashBag()
            self:CreateUnderWaterEffects( self.UnderWaterEmitters )
            --velocity adjustments while we are underwater
            self:SetVelocity(0)--i dont know why but setting this to anything except 0 doesnt do anything!
            self:SetAcceleration(3)
        else
            SingleCompositeEmitterProjectile.OnCreate(self, inwater)
            self:SetDestroyOnWater(true)
            self.MoveThread = self:ForkThread( self.MovementThread )
            self:ForkThread( self.UnpackThread )
        end
    end,

    ---@param self NIFArtilleryMissile
    OnExitWater = function(self)
        SingleCompositeEmitterProjectile.OnExitWater(self)
        self:SetDestroyOnWater( self:GetBlueprint().Physics.DestroyOnWaterAfterExitingWater or true )
        if not self.MoveThread then
            self.MoveThread = self:ForkThread(self.MovementThread)
            self:ForkThread(self.UnpackThread)
        end
        --water exit sequence
        self:ForkThread( self.WaterExitEffectsThread )
    end,

    ---@param self NIFArtilleryMissile
    OnDestroy = function(self)
        if self.UnderWaterEmitters and self.UnderWaterEmitters.Destroy then
            self.UnderWaterEmitters:Destroy()
        end
        SingleCompositeEmitterProjectile.OnDestroy(self)
    end,

    ---@param self NIFArtilleryMissile
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SingleCompositeEmitterProjectile.OnImpact(self, targetType, targetEntity)
        
        local pos = self:GetPosition()

        NomadsExplosions.CreateImpactMedium(self, pos, self.Army, targetType)
    end,

    ---@param self NIFArtilleryMissile
    WaterExitEffectsThread = function(self)
        -- remove water trail
        if self.UnderWaterEmitters and self.UnderWaterEmitters.Destroy then
            self.UnderWaterEmitters:Destroy()
        end
        
        --create some water exiting effects, splashes and all that
--        for k, v in self.FxExitWaterEmitter do
--            CreateEmitterAtBone(self, -2, self.Army, v)
--        end
        
        --adjust velocity to what it would have been from a land launch, but in a fancy way (5+3 = 8)
        self:SetVelocity(5)
        self:SetAcceleration(10)
        WaitSeconds(0.1) --small delay for the missile to get a bit above the water
        
        --since we dont have any of the effects of the land projectile, we need to recreate them here.
        
        --create the EmitterProjectile effects
        for i in self.FxTrails do
            CreateEmitterOnEntity(self, self.Army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end
        
        --create the SinglePolyTrailProjectile trail
        if self.PolyTrail ~= '' then
            CreateTrail(self, -1, self.Army, self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
        end
        
        --create the SingleCompositeEmitterProjectile beam
        if self.BeamName ~= '' then
            CreateBeamEmitterOnEntity(self, -1, self.Army, self.BeamName)
        end
        
        WaitSeconds(0.2) --finish accelerating at really high acceleration
        self:SetAcceleration(3)
    end,

    ---@param self NIFArtilleryMissile
    UnpackThread = function(self)
        WaitSeconds(0.5) --delay before deploying fins
        self:SetMesh('/projectiles/NTacticalMissile1/NTacticalMissile1Unpacked_mesh')
    end,

    ---@param self NIFArtilleryMissile
    ---@param EffectsBag TrashBag
    CreateUnderWaterEffects = function(self, EffectsBag)
        -- create attached air bubbles emitter
        local army, emit = self:GetLauncher().Army
        for k, v in NomadsEffectTemplate.TacticalMissileTrailFxUnderWaterAddon do
            emit = CreateAttachedEmitter( self, -1, army, v )
            EffectsBag:Add( emit )
            self.Trash:Add( emit )
        end
    end,
}

-- Unpacking Cruise Missiles
---@class NIFCruiseMissile : NIFMissile
NIFCruiseMissile = Class(NIFMissile) {

    BeamName = NomadsEffectTemplate.TacticalMissileBeam,

    FxImpactAirUnit = NomadsEffectTemplate.TacticalMissileHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.TacticalMissileHitLand2,
    FxImpactNone = NomadsEffectTemplate.TacticalMissileHitNone2,
    FxImpactProp = NomadsEffectTemplate.TacticalMissileHitProp2,
    FxImpactShield = NomadsEffectTemplate.TacticalMissileHitShield2,
    FxImpactUnit = NomadsEffectTemplate.TacticalMissileHitUnit2,
    FxImpactWater = NomadsEffectTemplate.TacticalMissileHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.TacticalMissileHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.TacticalMissileHitUnderWater2,

    FxTrails = NomadsEffectTemplate.TacticalMissileTrail,
    FxTrailsUnderWater = NomadsEffectTemplate.TacticalMissileTrail,
    PolyTrail = NomadsEffectTemplate.TacticalMissilePolyTrail,

    -- small correction to make the smoke appear to come from the missile
    FxTrailOffset = -0.16,
    PolyTrailOffset = -0.11,
    FxTrailScale = 0.5,

    FxImpactTrajectoryAligned = false,

    DoImpactFlash = true,

    ---@param self NIFCruiseMissile
    ---@param inwater boolean
    OnCreate = function(self, inwater)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        --if we are underwater we want to do things differently, like have different Fx and stuff.
        if inwater then
            --we bypass much of the trail creation stuff here, and add our own things instead, later.
            Projectile.OnCreate(self)
            self:SetDestroyOnWater(false)
            self.UnderWaterEmitters = TrashBag()
            self:CreateUnderWaterEffects( self.UnderWaterEmitters )
            --velocity adjustments while we are underwater
            self:SetVelocity(0)--i dont know why but setting this to anything except 0 doesnt do anything!
            self:SetAcceleration(3)
        else
            SingleCompositeEmitterProjectile.OnCreate(self, inwater)
            self:SetDestroyOnWater(true)
            self.MoveThread = self:ForkThread( self.MovementThread )
            self:ForkThread( self.UnpackThread )
        end
    end,

    ---@param self NIFCruiseMissile
    OnExitWater = function(self)
        SingleCompositeEmitterProjectile.OnExitWater(self)
        self:SetDestroyOnWater( self:GetBlueprint().Physics.DestroyOnWaterAfterExitingWater or true )
        if not self.MoveThread then
            self.MoveThread = self:ForkThread(self.MovementThread)
            self:ForkThread(self.UnpackThread)
        end
        --water exit sequence
        self:ForkThread( self.WaterExitEffectsThread )
    end,

    ---@param self NIFCruiseMissile
    OnDestroy = function(self)
        if self.UnderWaterEmitters and self.UnderWaterEmitters.Destroy then
            self.UnderWaterEmitters:Destroy()
        end
        SingleCompositeEmitterProjectile.OnDestroy(self)
    end,

    ---@param self NIFCruiseMissile
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SingleCompositeEmitterProjectile.OnImpact(self, targetType, targetEntity)
        
        local pos = self:GetPosition()

        NomadsExplosions.CreateImpactMedium(self, pos, self.Army, targetType)
    end,

    ---@param self NIFCruiseMissile
    WaterExitEffectsThread = function(self)
        -- remove water trail
        if self.UnderWaterEmitters and self.UnderWaterEmitters.Destroy then
            self.UnderWaterEmitters:Destroy()
        end
        
        --create some water exiting effects, splashes and all that
--        for k, v in self.FxExitWaterEmitter do
--            CreateEmitterAtBone(self, -2, self.Army, v)
--        end
        
        --adjust velocity to what it would have been from a land launch, but in a fancy way (5+3 = 8)
        self:SetVelocity(5)
        self:SetAcceleration(10)
        WaitSeconds(0.1) --small delay for the missile to get a bit above the water
        
        --since we dont have any of the effects of the land projectile, we need to recreate them here.
        
        --create the EmitterProjectile effects
        for i in self.FxTrails do
            CreateEmitterOnEntity(self, self.Army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end
        
        --create the SinglePolyTrailProjectile trail
        if self.PolyTrail ~= '' then
            CreateTrail(self, -1, self.Army, self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
        end
        
        --create the SingleCompositeEmitterProjectile beam
        if self.BeamName ~= '' then
            CreateBeamEmitterOnEntity(self, -1, self.Army, self.BeamName)
        end
        
        WaitSeconds(0.2) --finish accelerating at really high acceleration
        self:SetAcceleration(3)
    end,

    ---@param self NIFCruiseMissile
    UnpackThread = function(self)
        WaitSeconds(0.5) --delay before deploying fins
        self:SetMesh('/projectiles/NTacticalMissile1/NTacticalMissile1Unpacked_mesh')
    end,

    ---@param self NIFCruiseMissile
    ---@param EffectsBag TrashBag
    CreateUnderWaterEffects = function(self, EffectsBag)
        -- create attached air bubbles emitter
        local army, emit = self:GetLauncher().Army
        for k, v in NomadsEffectTemplate.TacticalMissileTrailFxUnderWaterAddon do
            emit = CreateAttachedEmitter( self, -1, army, v )
            EffectsBag:Add( emit )
            self.Trash:Add( emit )
        end
    end,
}

-- -----------------------------------------------------------------------------------------------------
-- LEGACY PROJECTILES - These are used by older versions of nomads, and as such have an older organisation structure.
-- Where possible, create new projectiles and tie them into the new structure instead, so that the old ones eventually dont need to be used.
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
-- BALLISTIC PROJECTILES        (UNGUIDED, NOT PROPELED)
-- -----------------------------------------------------------------------------------------------------

---@class RailGunProj : SinglePolyTrailProjectile
RailGunProj = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.RailgunHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.RailgunHitLand1,
    FxImpactNone = NomadsEffectTemplate.RailgunHitNone1,
    FxImpactProp = NomadsEffectTemplate.RailgunHitProp1,
    FxImpactShield = NomadsEffectTemplate.RailgunHitShield1,
    FxImpactUnit = NomadsEffectTemplate.RailgunHitUnit1,
    FxImpactWater = NomadsEffectTemplate.RailgunHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.RailgunHitProjectile1,

    FxTrails = NomadsEffectTemplate.RailgunTrail,
    PolyTrail = NomadsEffectTemplate.RailgunPolyTrail,

    CollisionCats = {},
    MaxCollisions = -1,

    ---@param self RailGunProj
    ---@param InWater boolean
    OnCreate = function(self, InWater)
        SinglePolyTrailProjectile.OnCreate(self, InWater)
        if self.CollisionCats and table.getn(self.CollisionCats) > 0 then
            self:SetCollisionShape('Sphere', 0, 0, 0, 1.8)  -- size of the collision hit box, larger means easier to eat projectiles
        end
    end,

    ---@param self RailGunProj
    ---@param other any
    ---@return boolean
    OnCollisionCheck = function(self, other)

        local ok = false

        -- filtering out only projectiles that dont fit the categories
        if not self.CollisionCats or table.getn(self.CollisionCats) < 1 then
            return false
        elseif self.Army == other.Army or IsAlly( self.Army, other.Army ) then
            return false
        else
            for k, cat in self.CollisionCats do
                if EntityCategoryContains( cat, other ) then
                    ok = true
                    break
                end
            end
        end

        return ok
    end,
}

---@class GattlingRound : MultiPolyTrailProjectile
GattlingRound = Class(MultiPolyTrailProjectile) {

    FxImpactAirUnit = NomadsEffectTemplate.GattlingHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.GattlingHitLand1,
    FxImpactNone = NomadsEffectTemplate.GattlingHitNone1,
    FxImpactProp = NomadsEffectTemplate.GattlingHitProp1,
    FxImpactShield = NomadsEffectTemplate.GattlingHitShield1,
    FxImpactUnit = NomadsEffectTemplate.GattlingHitUnit1,
    FxImpactWater = NomadsEffectTemplate.GattlingHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.GattlingHitProjectile1,

    FxTrails = NomadsEffectTemplate.GattlingTrail1,
    PolyTrails = NomadsEffectTemplate.GattlingPolyTrails1,
    PolyTrailOffset = {0,0,0,0},
}

---@class KineticRound :SinglePolyTrailProjectile
KineticRound = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.KineticCannonHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.KineticCannonHitLand1,
    FxImpactNone = NomadsEffectTemplate.KineticCannonHitNone1,
    FxImpactProp = NomadsEffectTemplate.KineticCannonHitProp1,
    FxImpactShield = NomadsEffectTemplate.KineticCannonHitShield1,
    FxImpactUnit = NomadsEffectTemplate.KineticCannonHitUnit1,
    FxImpactWater = NomadsEffectTemplate.KineticCannonHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.KineticCannonHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.KineticCannonHitUnderWater1,

    FxImpactTrajectoryAligned = false,
    FxTrails = NomadsEffectTemplate.KineticCannonTrail,
    PolyTrail = NomadsEffectTemplate.KineticCannonPolyTrail,

    ---@param self KineticRound
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(2, 3)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_010_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

---@class APRound : SinglePolyTrailProjectile
APRound = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.APCannonHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.APCannonHitLand1,
    FxImpactNone = NomadsEffectTemplate.APCannonHitNone1,
    FxImpactProp = NomadsEffectTemplate.APCannonHitProp1,
    FxImpactShield = NomadsEffectTemplate.APCannonHitShield1,
    FxImpactUnit = NomadsEffectTemplate.APCannonHitUnit1,
    FxImpactWater = NomadsEffectTemplate.APCannonHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.APCannonHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.APCannonHitUnderWater1,

    FxAirUnitHitScale = 0.95,
    FxLandHitScale = 0.95,
    FxNoneHitScale = 0.95,
    FxPropHitScale = 0.95,
    FxProjectileHitScale = 0.95,
    FxProjectileUnderWaterHitScale = 0.95,
    FxShieldHitScale = 0.95,
    FxUnderWaterHitScale = 0.95 * 0.25,
    FxUnitHitScale = 0.95,
    FxWaterHitScale = 0.95,
    FxOnKilledScale = 0.95,

    FxImpactTrajectoryAligned = false,
    FxTrails = NomadsEffectTemplate.APCannonTrail,
    PolyTrail = NomadsEffectTemplate.APCannonPolyTrail,

    ---@param self APRound
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 1.475*0.95, 5, 'glow_06_red', 'ramp_transparency_flash_dark_2' )
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 0.315*0.95, 36.5, 'glow_06_red', 'ramp_transparency_flash_dark_2' )

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1, 1.8)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_002_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

---@class APRoundCap : SinglePolyTrailProjectile
APRoundCap = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.APCannonHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.APCannonHitLand2,
    FxImpactNone = NomadsEffectTemplate.APCannonHitNone2,
    FxImpactProp = NomadsEffectTemplate.APCannonHitProp2,
    FxImpactShield = NomadsEffectTemplate.APCannonHitShield2,
    FxImpactUnit = NomadsEffectTemplate.APCannonHitUnit2,
    FxImpactWater = NomadsEffectTemplate.APCannonHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.APCannonHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.APCannonHitUnderWater2,

    FxAirUnitHitScale = 0.775,
    FxLandHitScale = 0.775,
    FxNoneHitScale = 0.775,
    FxPropHitScale = 0.775,
    FxProjectileHitScale = 0.775,
    FxProjectileUnderWaterHitScale = 0.775,
    FxShieldHitScale = 0.775,
    FxUnderWaterHitScale = 0.775 * 0.25,
    FxUnitHitScale = 0.775,
    FxWaterHitScale = 0.775,
    FxOnKilledScale = 0.775,

    FxImpactTrajectoryAligned = false,
    FxTrails = NomadsEffectTemplate.APCannonTrail2,
    PolyTrail = NomadsEffectTemplate.APCannonPolyTrail2,

    ---@param self APRoundCap
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 2.435*0.775, 8, 'glow_06_red', 'ramp_transparency_flash_dark_2' )
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 0.635*0.775, 66.5, 'glow_06_red', 'ramp_transparency_flash_dark_2' )

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1, 1.8)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_002_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

---@class Annihilator : SinglePolyTrailProjectile
Annihilator = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.AnnihilatorHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.AnnihilatorHitLand1,
    FxImpactNone = NomadsEffectTemplate.AnnihilatorHitNone1,
    FxImpactProp = NomadsEffectTemplate.AnnihilatorHitProp1,
    FxImpactShield = NomadsEffectTemplate.AnnihilatorHitShield1,
    FxImpactUnit = NomadsEffectTemplate.AnnihilatorHitUnit1,
    FxImpactWater = NomadsEffectTemplate.AnnihilatorHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.AnnihilatorHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.AnnihilatorHitUnderWater1,

    FxImpactTrajectoryAligned = false,
    FxTrails = NomadsEffectTemplate.AnnihilatorTrail,
    PolyTrail = NomadsEffectTemplate.AnnihilatorPolyTrail,

    FxTrailOffset = 0,

    OnImpact = function(self, targetType, targetEntity)
        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(2, 3)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_001_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

---@class ArtilleryShell : SinglePolyTrailProjectile
ArtilleryShell = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.ArtilleryHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.ArtilleryHitLand1,
    FxImpactNone = NomadsEffectTemplate.ArtilleryHitNone1,
    FxImpactProp = NomadsEffectTemplate.ArtilleryHitProp1,
    FxImpactShield = NomadsEffectTemplate.ArtilleryHitShield1,
    FxImpactUnit = NomadsEffectTemplate.ArtilleryHitUnit1,
    FxImpactWater = NomadsEffectTemplate.ArtilleryHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.ArtilleryHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.ArtilleryHitUnderWater1,

    FxTrails = NomadsEffectTemplate.ArtilleryTrail,
    PolyTrail = NomadsEffectTemplate.ArtilleryPolyTrail,

    DoImpactFlash = true,

    OnImpact = function(self, targetType, targetEntity)
        local pos = self:GetPosition()

        NomadsExplosions.CreateArtilleryImpactLarge(self, pos, self.Army, targetType)

        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

---@class ParticleBlastArtilleryShell : SinglePolyTrailProjectile
ParticleBlastArtilleryShell = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.ParticleBlastArtilleryHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.ParticleBlastArtilleryHitLand1,
    FxImpactNone = NomadsEffectTemplate.ParticleBlastArtilleryHitNone1,
    FxImpactProp = NomadsEffectTemplate.ParticleBlastArtilleryHitProp1,
    FxImpactShield = NomadsEffectTemplate.ParticleBlastArtilleryHitShield1,
    FxImpactUnit = NomadsEffectTemplate.ParticleBlastArtilleryHitUnit1,
    FxImpactWater = NomadsEffectTemplate.ParticleBlastArtilleryHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.ParticleBlastArtilleryHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.ParticleBlastArtilleryHitUnderWater1,
    FxTrails = NomadsEffectTemplate.ParticleBlastArtilleryTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadsEffectTemplate.ParticleBlastArtilleryPolyTrail,
    PolyTrailOffset = 0,

    FxImpactTrajectoryAligned = false,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(8, 12)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

---@class SplittingArtilleryShell : SinglePolyTrailProjectile
SplittingArtilleryShell = Class(SinglePolyTrailProjectile) {

    FxImpactAirUnit = NomadsEffectTemplate.ConcussionBombHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.ConcussionBombHitLand1,
    FxImpactNone = NomadsEffectTemplate.ConcussionBombHitNone1,
    FxImpactProp = NomadsEffectTemplate.ConcussionBombHitProp1,
    FxImpactShield = NomadsEffectTemplate.ConcussionBombHitShield1,
    FxImpactUnit = NomadsEffectTemplate.ConcussionBombHitUnit1,
    FxImpactWater = NomadsEffectTemplate.ConcussionBombHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.ConcussionBombHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.ConcussionBombHitUnderWater1,

    FxTrails = NomadsEffectTemplate.ConcussionBombTrail,
    PolyTrail = NomadsEffectTemplate.ArtilleryPolyTrail,

    FxImpactTrajectoryAligned = false,

    DoImpactFlash = true,

    PassDamageData = function(self, DamageData)
        SinglePolyTrailProjectile.PassDamageData(self, DamageData)
        self.DamageData.NumFragments = DamageData.NumFragments
        self.DamageData.FragmentDispersalRadius = DamageData.FragmentDispersalRadius
    end,

    OnImpact = function(self, targetType, targetEntity)
        if self.DoImpactFlash then
            CreateLightParticle( self, -1, self.Army, RandomFloat(15,17), RandomFloat(8,12), 'glow_03', 'ramp_antimatter_02' )
        end
        if targetType ~= "Shield" then
            local rotation = RandomFloat(0, 2*math.pi)
            local size = RandomFloat(2, 3)
            local life = RandomFloat(50, 100)
            CreateDecal(self:GetPosition(), rotation, '/textures/splats/ConcussionBomb/ConcussionBomb_decal_albedo.dds', '', 'Albedo', size, size, 350, life, self.Army)
        end
        self:Fragments()
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,

    Fragments = function(self)

        local numProjectiles = self.DamageData.NumFragments or 15
        if numProjectiles < 1 then
            return
        end

        -- split damage between projectiles
        self.DamageData.DamageAmount = self.DamageData.DamageAmount / (numProjectiles + 1)   -- plus one cause the parent projectile also counts

        -- calc angles
        local angle = (2*math.pi) / numProjectiles
        local angleInitial = RandomFloat( 0, angle )

        -- Randomization of the spread
        local angleVariation = angle * 0.75 -- Adjusts angle variance spread
        local spreadMul = 0.5 -- Adjusts the width of the dispersal
        local velocity = self.DamageData.FragmentDispersalRadius
        local variation = velocity / 3

        local ChildProjectileBP = '/projectiles/NBombProj2Child/NBombProj2Child_proj.bp'
        local vx, vy, vz = self:GetVelocity()
        local xVec, zVec = 0, 0
        local yVec = -vy * 0.35

        for i = 0, (numProjectiles - 1) do
            xVec = (math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            zVec = (math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            local proj = self:CreateChildProjectile(ChildProjectileBP)
            proj:SetVelocity( xVec, yVec, zVec )
            proj:SetVelocity( RandomFloat( (velocity-variation), (velocity+variation) ) )
            proj:PassDamageData(self.DamageData)
        end
    end,
}

---@class DarkMatterProj : MultiPolyTrailProjectile
DarkMatterProj = Class(MultiPolyTrailProjectile) {
    --As a test to unify all the ugly DarkMatter weapons, this is commented out. If necessary, will make separate versions if the unified look does not fit particular weapons

    --FxImpactAirUnit = NomadsEffectTemplate.DarkMatterWeaponHitAirUnit1,
    --FxImpactLand = NomadsEffectTemplate.DarkMatterWeaponHitLand1,
    --FxImpactNone = NomadsEffectTemplate.DarkMatterWeaponHitNone1,
    --FxImpactProp = NomadsEffectTemplate.DarkMatterWeaponHitProp1,
    --FxImpactShield = NomadsEffectTemplate.DarkMatterWeaponHitShield1,
    --FxImpactUnit = NomadsEffectTemplate.DarkMatterWeaponHitUnit1,
    --FxImpactWater = NomadsEffectTemplate.DarkMatterWeaponHitWater1,
    --FxImpactProjectile = NomadsEffectTemplate.DarkMatterWeaponHitProjectile1,
    --FxImpactUnderWater = NomadsEffectTemplate.DarkMatterWeaponHitUnderWater1,

    --FxTrails = NomadsEffectTemplate.DarkMatterWeaponTrail,

    --PolyTrails = NomadsEffectTemplate.DarkMatterWeaponPolyTrails,
    --PolyTrailOffset = {0,0,0,0,},
    --RandomPolyTrails = 1,

    FxImpactAirUnit = NomadsEffectTemplate.DarkMatterAirWeaponHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.DarkMatterAirWeaponHitLand1,
    FxImpactNone = NomadsEffectTemplate.DarkMatterAirWeaponHitNone1,
    FxImpactProp = NomadsEffectTemplate.DarkMatterAirWeaponHitProp1,
    FxImpactShield = NomadsEffectTemplate.DarkMatterAirWeaponHitShield1,
    FxImpactUnit = NomadsEffectTemplate.DarkMatterAirWeaponHitUnit1,
    FxImpactWater = NomadsEffectTemplate.DarkMatterAirWeaponHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.DarkMatterAirWeaponHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.DarkMatterAirWeaponHitUnderWater1,

    FxTrails = NomadsEffectTemplate.DarkMatterAirWeaponTrail,

    PolyTrails = NomadsEffectTemplate.DarkMatterAirWeaponPolyTrails,
    PolyTrailOffset = {0,0,0,0,},
    RandomPolyTrails = 1,
    
    FactionColour = true,
    BeamsToRecolour = {'PolyTrails',},
}

---@class DarkMatterProj2 : MultiPolyTrailProjectile
DarkMatterProj2 = Class(MultiPolyTrailProjectile) {
    --As a test to unify all the ugly DarkMatter weapons, this is commented out. If necessary, will make separate versions if the unified look does not fit particular weapons

    --BeamName = NomadsEffectTemplate.DarkMatterWeaponBeam2,

    --FxImpactAirUnit = NomadsEffectTemplate.DarkMatterWeaponHitAirUnit2,
    --FxImpactLand = NomadsEffectTemplate.DarkMatterWeaponHitLand2,
    --FxImpactNone = NomadsEffectTemplate.DarkMatterWeaponHitNone2,
    --FxImpactProp = NomadsEffectTemplate.DarkMatterWeaponHitProp2,
    --FxImpactShield = NomadsEffectTemplate.DarkMatterWeaponHitShield2,
    --FxImpactUnit = NomadsEffectTemplate.DarkMatterWeaponHitUnit2,
    --FxImpactWater = NomadsEffectTemplate.DarkMatterWeaponHitWater2,
    --FxImpactProjectile = NomadsEffectTemplate.DarkMatterWeaponHitProjectile2,
    --FxImpactUnderWater = NomadsEffectTemplate.DarkMatterWeaponHitUnderWater2,

    FxImpactAirUnit = NomadsEffectTemplate.DarkMatterAirWeaponHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.DarkMatterAirWeaponHitLand1,
    FxImpactNone = NomadsEffectTemplate.DarkMatterAirWeaponHitNone1,
    FxImpactProp = NomadsEffectTemplate.DarkMatterAirWeaponHitProp1,
    FxImpactShield = NomadsEffectTemplate.DarkMatterAirWeaponHitShield1,
    FxImpactUnit = NomadsEffectTemplate.DarkMatterAirWeaponHitUnit1,
    FxImpactWater = NomadsEffectTemplate.DarkMatterAirWeaponHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.DarkMatterAirWeaponHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.DarkMatterAirWeaponHitUnderWater1,

    FxTrails = NomadsEffectTemplate.DarkMatterAirWeaponTrail,

    PolyTrails = NomadsEffectTemplate.DarkMatterAirWeaponPolyTrails,
    PolyTrailOffset = {0,0,0,0,},
    RandomPolyTrails = 1,
    FactionColour = true,
    BeamsToRecolour = {'PolyTrails',},
}

---@class DarkMatterProjAir : MultiPolyTrailProjectile
DarkMatterProjAir = Class(MultiPolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.DarkMatterAirWeaponHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.DarkMatterAirWeaponHitLand1,
    FxImpactNone = NomadsEffectTemplate.DarkMatterAirWeaponHitNone1,
    FxImpactProp = NomadsEffectTemplate.DarkMatterAirWeaponHitProp1,
    FxImpactShield = NomadsEffectTemplate.DarkMatterAirWeaponHitShield1,
    FxImpactUnit = NomadsEffectTemplate.DarkMatterAirWeaponHitUnit1,
    FxImpactWater = NomadsEffectTemplate.DarkMatterAirWeaponHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.DarkMatterAirWeaponHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.DarkMatterAirWeaponHitUnderWater1,

    FxTrails = NomadsEffectTemplate.DarkMatterAirWeaponTrail,

    PolyTrails = NomadsEffectTemplate.DarkMatterAirWeaponPolyTrails,
    PolyTrailOffset = {0,0,0,0,},
    RandomPolyTrails = 1,
    FactionColour = true,
    BeamsToRecolour = {'PolyTrails',},
}

---@class IonBlast : SinglePolyTrailProjectile
IonBlast = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.IonBlastHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.IonBlastHitLand1,
    FxImpactNone = NomadsEffectTemplate.IonBlastHitNone1,
    FxImpactProp = NomadsEffectTemplate.IonBlastHitProp1,
    FxImpactShield = NomadsEffectTemplate.IonBlastHitShield1,
    FxImpactUnit = NomadsEffectTemplate.IonBlastHitUnit1,
    FxImpactWater = NomadsEffectTemplate.IonBlastHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.IonBlastHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.IonBlastHitUnderWater1,
    FxTrails = NomadsEffectTemplate.IonBlastTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadsEffectTemplate.IonBlastPolyTrail,
    PolyTrailOffset = 0,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1, 1.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

---@class ParticleBlast : SinglePolyTrailProjectile
ParticleBlast = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.ParticleBlastHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.ParticleBlastHitLand1,
    FxImpactNone = NomadsEffectTemplate.ParticleBlastHitNone1,
    FxImpactProp = NomadsEffectTemplate.ParticleBlastHitProp1,
    FxImpactShield = NomadsEffectTemplate.ParticleBlastHitShield1,
    FxImpactUnit = NomadsEffectTemplate.ParticleBlastHitUnit1,
    FxImpactWater = NomadsEffectTemplate.ParticleBlastHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.ParticleBlastHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.ParticleBlastHitUnderWater1,
    FxTrails = NomadsEffectTemplate.ParticleBlastTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadsEffectTemplate.ParticleBlastPolyTrail,
    PolyTrailOffset = 0,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1, 1.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

---@class Stingray : MultiPolyTrailProjectile
Stingray = Class(MultiPolyTrailProjectile) {

    FxImpactAirUnit = NomadsEffectTemplate.StingrayHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.StingrayHitLand1,
    FxImpactNone = NomadsEffectTemplate.StingrayHitNone1,
    FxImpactProp = NomadsEffectTemplate.StingrayHitProp1,
    FxImpactShield = NomadsEffectTemplate.StingrayHitShield1,
    FxImpactUnit = NomadsEffectTemplate.StingrayHitUnit1,
    FxImpactWater = NomadsEffectTemplate.StingrayHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.StingrayHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.StingrayHitUnderWater1,
    FxTrails = NomadsEffectTemplate.StingrayTrail,

    PolyTrails = NomadsEffectTemplate.StingrayPolyTrails,
    PolyTrailOffset = {0,0,},
}

---@class EmpShell : SinglePolyTrailProjectile
EmpShell = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.EMPGunHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.EMPGunHitLand1,
    FxImpactNone = NomadsEffectTemplate.EMPGunHitNone1,
    FxImpactProp = NomadsEffectTemplate.EMPGunHitProp1,
    FxImpactShield = NomadsEffectTemplate.EMPGunHitShield1,
    FxImpactUnit = NomadsEffectTemplate.EMPGunHitUnit1,
    FxImpactWater = NomadsEffectTemplate.EMPGunHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.EMPGunHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.EMPGunHitUnderWater1,
    FxTrails = NomadsEffectTemplate.EMPGunTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadsEffectTemplate.EMPGunPolyTrail,
    PolyTrailOffset = 0,


    OnImpact = function(self, targetType, targetEntity)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)

        -- create custom electricity effect based on stun duration
        local Duration = false
        for k, buff in self.DamageData.Buffs do
            if buff.BuffType == "STUN" then
                Duration = (buff.Duration or Duration)
                break
            end
        end

        if Duration then

            local ImpactEffectScale = 1
            Duration = Duration * (NomadsEffectTemplate.EMPGunElectricityEffectDurationMulti or 1)
            if targetType == 'Water' then
                ImpactEffectScale = self.FxWaterHitScale
            elseif targetType == 'Underwater' or targetType == 'UnitUnderwater' then
                ImpactEffectScale = self.FxUnderWaterHitScale
            elseif targetType == 'Unit' then
                ImpactEffectScale = self.FxUnitHitScale
            elseif targetType == 'UnitAir' then
                ImpactEffectScale = self.FxAirUnitHitScale
            elseif targetType == 'Terrain' then
                ImpactEffectScale = self.FxLandHitScale
            elseif targetType == 'Air' then
                ImpactEffectScale = self.FxNoneHitScale
            elseif targetType == 'Projectile' then
                ImpactEffectScale = self.FxProjectileHitScale
            elseif targetType == 'ProjectileUnderwater' then
                ImpactEffectScale = self.FxProjectileUnderWaterHitScale
            elseif targetType == 'Prop' then
                ImpactEffectScale = self.FxPropHitScale
            elseif targetType == 'Shield' then
                ImpactEffectScale = self.FxShieldHitScale
            end
            self:PlayElectricityEffects( self.Army, NomadsEffectTemplate.EMPGunElectricityEffect, ImpactEffectScale, Duration )
        end
        
        if targetType ~= 'Shield' then
            targetEntity = targetEntity.MyShield
        end

        if not targetEntity then return end

        -- Never cause overspill damage to the unit, 1 min to avoid logspam with 0 declared damage
        local damage = math.max(math.min(self.Data or 0, targetEntity:GetHealth()), 1)
        Damage(self, {0,0,0}, targetEntity, damage, 'Normal')
    end,

    PlayElectricityEffects = function( self, army, EffectTable, EffectScale, EffectDuration )
        local emit = nil
        for k, v in EffectTable do
            if self.FxImpactTrajectoryAligned then
                emit = CreateEmitterAtBone(self,-2,army,v)
            else
                emit = CreateEmitterAtEntity(self,army,v)
            end
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
            if emit then
                emit:SetEmitterParam('LIFETIME', EffectDuration or 10)
            end
        end
    end,
}

---@class PlasmaProj : SinglePolyTrailProjectile
PlasmaProj = Class(SinglePolyTrailProjectile) {
    BeamName = NomadsEffectTemplate.PlasmaBoltBeam,

    FxImpactAirUnit = NomadsEffectTemplate.PlasmaBoltHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.PlasmaBoltHitLand1,
    FxImpactNone = NomadsEffectTemplate.PlasmaBoltHitNone1,
    FxImpactProp = NomadsEffectTemplate.PlasmaBoltHitProp1,
    FxImpactShield = NomadsEffectTemplate.PlasmaBoltHitShield1,
    FxImpactUnit = NomadsEffectTemplate.PlasmaBoltHitUnit1,
    FxImpactWater = NomadsEffectTemplate.PlasmaBoltHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.PlasmaBoltHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.PlasmaBoltHitUnderWater1,

    FxTrails = NomadsEffectTemplate.PlasmaBoltTrail,
    PolyTrail = NomadsEffectTemplate.PlasmaBoltPolyTrail,

    DoImpactFlash = false,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(2.5, 4)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_009_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
        if self.DoImpactFlash then
            CreateLightParticle( self, -1, self.Army, 6, 5, 'glow_03', 'ramp_yellow_blue_01' )
            CreateLightParticle( self, -1, self.Army, 8, 16, 'glow_03', 'ramp_antimatter_02' )
        end
    end,
}

---@class PlasmaProjHighArcMissileArtillery : SinglePolyTrailProjectile
PlasmaProjHighArcMissileArtillery = Class(SinglePolyTrailProjectile) {
    BeamName = NomadsEffectTemplate.PlasmaBoltBeam,

    FxImpactAirUnit = NomadsEffectTemplate.PlasmaBoltHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.PlasmaBoltHitLand1,
    FxImpactNone = NomadsEffectTemplate.PlasmaBoltHitNone1,
    FxImpactProp = NomadsEffectTemplate.PlasmaBoltHitProp1,
    FxImpactShield = NomadsEffectTemplate.PlasmaBoltHitShield1,
    FxImpactUnit = NomadsEffectTemplate.PlasmaBoltHitUnit1,
    FxImpactWater = NomadsEffectTemplate.PlasmaBoltHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.PlasmaBoltHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.PlasmaBoltHitUnderWater1,

    FxTrails = NomadsEffectTemplate.PlasmaBoltTrail,
    PolyTrail = NomadsEffectTemplate.PlasmaBoltPolyTrail,

    DoImpactFlash = false,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)
        --NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 1, 43, 'glow_03_red', 'ramp_transparency_flash_dark_2' )
        --NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 1, 43, 'glow_03_red', 'ramp_transparency_flash_dark_2' )
        --NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 4, 5, 'glow_03_red', 'ramp_transparency_flash_dark' )

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(2.5, 4)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_009_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
        if self.DoImpactFlash then
            CreateLightParticle( self, -1, self.Army, 6, 5, 'glow_03', 'ramp_yellow_blue_01' )
            CreateLightParticle( self, -1, self.Army, 8, 16, 'glow_03', 'ramp_antimatter_02' )
        end
    end,
}

---@class PlasmaProjHighArcMissileArtilleryStatic : SinglePolyTrailProjectile
PlasmaProjHighArcMissileArtilleryStatic = Class(SinglePolyTrailProjectile) {
    BeamName = NomadsEffectTemplate.RcktArtyPlasmaBoltBeam,

    FxImpactAirUnit = NomadsEffectTemplate.RcktArtyPlasmaBoltHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.RcktArtyPlasmaBoltHitLand1,
    FxImpactNone = NomadsEffectTemplate.RcktArtyPlasmaBoltHitNone1,
    FxImpactProp = NomadsEffectTemplate.RcktArtyPlasmaBoltHitProp1,
    FxImpactShield = NomadsEffectTemplate.RcktArtyPlasmaBoltHitShield1,
    FxImpactUnit = NomadsEffectTemplate.RcktArtyPlasmaBoltHitUnit1,
    FxImpactWater = NomadsEffectTemplate.RcktArtyPlasmaBoltHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.RcktArtyPlasmaBoltHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.RcktArtyPlasmaBoltHitUnderWater1,

    FxTrails = NomadsEffectTemplate.RcktArtyPlasmaBoltTrail,
    PolyTrail = NomadsEffectTemplate.RcktArtyPlasmaBoltPolyTrail,

    DoImpactFlash = false,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 1, 43, 'glow_03_red', 'ramp_transparency_flash_dark_2' )
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 1, 43, 'glow_03_red', 'ramp_transparency_flash_dark_2' )
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 4, 5, 'glow_03_red', 'ramp_transparency_flash_dark' )

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(2.5, 4)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_009_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
        if self.DoImpactFlash then
            CreateLightParticle( self, -1, self.Army, 6, 5, 'glow_03', 'ramp_yellow_blue_01' )
            CreateLightParticle( self, -1, self.Army, 8, 16, 'glow_03', 'ramp_antimatter_02' )
        end
    end,
}

---@class EnergyProj : SinglePolyTrailProjectile
EnergyProj = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.EnergyProjHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.EnergyProjHitLand1,
    FxImpactNone = NomadsEffectTemplate.EnergyProjHitNone1,
    FxImpactProp = NomadsEffectTemplate.EnergyProjHitProp1,
    FxImpactShield = NomadsEffectTemplate.EnergyProjHitShield1,
    FxImpactUnit = NomadsEffectTemplate.EnergyProjHitUnit1,
    FxImpactWater = NomadsEffectTemplate.EnergyProjHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.EnergyProjHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.EnergyProjHitUnderWater1,

    FxTrails = NomadsEffectTemplate.EnergyProjTrail,
    PolyTrail = NomadsEffectTemplate.EnergyProjPolyTrail,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local pos = self:GetPosition()
        DamageArea(self, pos, (self.DamageData.DamageRadius or 1) * 1.2, 1, 'BigFire', true)  -- light trees on fire
        local ok = (GetSurfaceHeight(pos[1],pos[3]) == GetTerrainHeight(pos[1],pos[3]) and targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(8, 10)
            local life = Random(40, 60)
            local albedo = { 'Scorch_001_albedo', 'Scorch_002_albedo', 'Scorch_003_albedo', }  -- keep the 'random' up to date in next line
            CreateDecal(pos, rotation, albedo[ Random(1, 3) ], '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

-- -----------------------------------------------------------------------------------------------------
-- MISSILES       (GUIDED, PROPELED)
-- -----------------------------------------------------------------------------------------------------

---@class Missile1 : SingleCompositeEmitterProjectile
Missile1 = Class(SingleCompositeEmitterProjectile) {

    BeamName = NomadsEffectTemplate.MissileBeam,

    FxImpactAirUnit = NomadsEffectTemplate.MissileHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.MissileHitLand1,
    FxImpactNone = NomadsEffectTemplate.MissileHitNone1,
    FxImpactProp = NomadsEffectTemplate.MissileHitProp1,
    FxImpactShield = NomadsEffectTemplate.MissileHitShield1,
    FxImpactUnit = NomadsEffectTemplate.MissileHitUnit1,
    FxImpactWater = NomadsEffectTemplate.MissileHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.MissileHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.MissileHitUnderWater1,

    FxTrails = NomadsEffectTemplate.MissileTrail,
    PolyTrail = NomadsEffectTemplate.MissilePolyTrail,

    OnImpact = function(self, targetType, targetEntity)
        SingleCompositeEmitterProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1.5, 2.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

---@class FusionMissile : SingleCompositeEmitterProjectile
FusionMissile = Class(SingleCompositeEmitterProjectile) {

    BeamName = NomadsEffectTemplate.FusionMissileBeam,

    FxImpactAirUnit = NomadsEffectTemplate.FusionMissileHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.FusionMissileHitLand1,
    FxImpactNone = NomadsEffectTemplate.FusionMissileHitNone1,
    FxImpactProp = NomadsEffectTemplate.FusionMissileHitProp1,
    FxImpactShield = NomadsEffectTemplate.FusionMissileHitShield1,
    FxImpactUnit = NomadsEffectTemplate.FusionMissileHitUnit1,
    FxImpactWater = NomadsEffectTemplate.FusionMissileHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.FusionMissileHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.FusionMissileHitUnderWater1,

    FxTrails = NomadsEffectTemplate.FusionMissileTrail,
    PolyTrail = NomadsEffectTemplate.FusionMissilePolyTrail,

    FxImpactTrajectoryAligned = false,

    NoCollisions = false,

    OnCreate = function(self)
        SingleCompositeEmitterProjectile.OnCreate(self)
        self._TrackTarget = false
        if not self.NoCollisions then
            self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        end
        self:ForkThread( self.MonitorTargetPosition )
    end,

    OnImpact = function(self, targetType, TargetEntity)
        -- create decal
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(4.5, 6.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
        SingleCompositeEmitterProjectile.OnImpact( self, targetType, TargetEntity )
    end,

    TrackTarget = function(self, enable)
        self._TrackTarget = (enable == true)
        SingleCompositeEmitterProjectile.TrackTarget(self, self._TrackTarget)
    end,

    MonitorTargetPosition = function(self)
        -- Monitors the target and updates it's known position regularly. If the target is destroyed then the projectile is guided to the
        -- last known position of the target, instead of blowing the missile up as is done with other tracking projectiles.
        -- If the target is destroyed GetCurrentTargetPosition() reports a bad position, with values 1.--qnan. The "strange" code with
        -- ctp[1]+1 > ctp[1] is to check for number values. The bad position is filtered out this way.
        local targetPos, ctp = false, false
        while self and not self:BeenDestroyed() do
            ctp = self:GetCurrentTargetPosition()
            if ctp[1] and ctp[2] and ctp[3] and ctp[1]+1 > ctp[1] and ctp[2]+1 > ctp[2] and ctp[3]+1 > ctp[3] then
                targetPos = ctp
            else
                -- make sure the new target is at the ground to make the missile hit the surface instead of nothing-ness (and thus hang around)
                targetPos[2] = GetTerrainHeight(targetPos[1], targetPos[3]) + GetTerrainTypeOffset(targetPos[1], targetPos[3])
                self:SetNewTargetGround(targetPos)
                self:TrackTarget(self._TrackTarget)
                self:SetBallisticAcceleration(-0.02)
                break
            end
            WaitTicks(2)
        end
    end,

    OnLostTarget = function(self)
        local lt = self:GetBlueprint().Physics.LifetimeAfterTargetLost or 10
        self:SetLifetime(lt)
        self:ForkThread(self.LifetimeWatchThread, lt)
    end,

    LifetimeWatchThread = function(self, seconds)
        WaitSeconds(seconds)
        self:Kill()
    end,
}

---@class EMPMissile : FusionMissile
EMPMissile = Class(FusionMissile) {
    BeamName = NomadsEffectTemplate.EMPMissileBeam,

    FxImpactAirUnit = NomadsEffectTemplate.EMPMissileHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.EMPMissileHitLand1,
    FxImpactNone = NomadsEffectTemplate.EMPMissileHitNone1,
    FxImpactProp = NomadsEffectTemplate.EMPMissileHitProp1,
    FxImpactShield = NomadsEffectTemplate.EMPMissileHitShield1,
    FxImpactUnit = NomadsEffectTemplate.EMPMissileHitUnit1,
    FxImpactWater = NomadsEffectTemplate.EMPMissileHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.EMPMissileHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.EMPMissileHitUnderWater1,

    FxTrails = NomadsEffectTemplate.EMPMissileTrail,
    PolyTrail = NomadsEffectTemplate.EMPMissilePolyTrail,

    OnImpact = function(self, targetType, targetEntity)
        FusionMissile.OnImpact(self, targetType, targetEntity)

        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 2, 52, 'glow_05_green', 'ramp_jammer_01_transparent' )
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 3, 3, 'glow_05_green', 'ramp_jammer_01' )

        -- create custom electricity effect based on stun duration
        local Duration = false
        for k, buff in self.DamageData.Buffs do
            if buff.BuffType == "STUN" then
                Duration = (buff.Duration or Duration)
                break
            end
        end

        if Duration then

            local ImpactEffectScale = 1
            Duration = Duration * (NomadsEffectTemplate.EMPMissileElectricityEffectDurationMulti or 1)
            if targetType == 'Water' then
                ImpactEffectScale = self.FxWaterHitScale or ImpactEffectScale
            elseif targetType == 'Underwater' or targetType == 'UnitUnderwater' then
                ImpactEffectScale = self.FxUnderWaterHitScale or ImpactEffectScale
            elseif targetType == 'Unit' then
                ImpactEffectScale = self.FxUnitHitScale or ImpactEffectScale
            elseif targetType == 'UnitAir' then
                ImpactEffectScale = self.FxAirUnitHitScale or ImpactEffectScale
            elseif targetType == 'Terrain' then
                ImpactEffectScale = self.FxLandHitScale or ImpactEffectScale
            elseif targetType == 'Air' then
                ImpactEffectScale = self.FxNoneHitScale or ImpactEffectScale
            elseif targetType == 'Projectile' then
                ImpactEffectScale = self.FxProjectileHitScale or ImpactEffectScale
            elseif targetType == 'ProjectileUnderwater' then
                ImpactEffectScale = self.FxProjectileUnderWaterHitScale or ImpactEffectScale
            elseif targetType == 'Prop' then
                ImpactEffectScale = self.FxPropHitScale or ImpactEffectScale
            elseif targetType == 'Shield' then
                ImpactEffectScale = self.FxShieldHitScale or ImpactEffectScale
            end
            self:PlayElectricityEffects( self.Army, NomadsEffectTemplate.EMPMissileElectricityEffect, ImpactEffectScale, Duration )
        end
    end,

    PlayElectricityEffects = function( self, army, EffectTable, EffectScale, EffectDuration )
        local emit = nil
        for k, v in EffectTable do
            if self.FxImpactTrajectoryAligned then
                emit = CreateEmitterAtBone(self,-2,army,v)
            else
                emit = CreateEmitterAtEntity(self,army,v)
            end
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale)
            end
            if emit then
                emit:SetEmitterParam('LIFETIME', EffectDuration or 10)
            end
        end
    end,
}

---@class TacticalMissile : SingleCompositeEmitterProjectile
TacticalMissile = Class(SingleCompositeEmitterProjectile) {
    -- Weapon BP item: NumChildProjectiles, should be supported in weapon aswell.

    BeamName = NomadsEffectTemplate.TacticalMissileBeam,
    FxImpactAirUnit = NomadsEffectTemplate.TacticalMissileHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.TacticalMissileHitLand1,
    FxImpactNone = NomadsEffectTemplate.TacticalMissileHitNone1,
    FxImpactProp = NomadsEffectTemplate.TacticalMissileHitProp1,
    FxImpactShield = NomadsEffectTemplate.TacticalMissileHitShield1,
    FxImpactUnit = NomadsEffectTemplate.TacticalMissileHitUnit1,
    FxImpactWater = NomadsEffectTemplate.TacticalMissileHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.TacticalMissileHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.TacticalMissileHitUnderWater1,

    FxTrails = NomadsEffectTemplate.TacticalMissileTrail,
    PolyTrail = NomadsEffectTemplate.TacticalMissilePolyTrail,

    -- small correction to make the smoke appear to come from the missile
    FxTrailOffset = -0.32,
    PolyTrailOffset = -0.22,

    FxImpactTrajectoryAligned = false,

    DoSplit = false,
    DoImpactFlash = false,

    OnCreate = function(self, inwater)
        SingleCompositeEmitterProjectile.OnCreate(self, inwater)
        self._IsFlared = false
        self.UnderWaterEmitters = TrashBag()
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self:ForkThread( self.MovementThread )
        self.IsUnderWater = (inwater == true)
        if self.IsUnderWater then
            self:SetDestroyOnWater(false)
            self:ForkThread( self.UnderWaterThread, self.UnderWaterEmitters )
        elseif (self:GetBlueprint().Physics.DestroyOnWaterAfterExitingWater or true) then
            self:SetDestroyOnWater(true)
        end
    end,

    OnDestroy = function(self)
        if self.UnderWaterEmitters and self.UnderWaterEmitters.Destroy then
            self.UnderWaterEmitters:Destroy()
        end
        SingleCompositeEmitterProjectile.OnDestroy(self)
    end,

    PassDamageData = function(self, DamageData)
        SingleCompositeEmitterProjectile.PassDamageData(self, DamageData)
        self.DamageData.NumChildProjectiles = DamageData.NumChildProjectiles or 0
        self.DoSplit = (self.DamageData.NumChildProjectiles > 0)
    end,

    MovementThread = function(self)
        self:SetTurnRate(0)

        -- wait till exitting water before leveling off
        if self.IsUnderWater then
            while self and self.IsUnderWater do
                WaitTicks(1)
            end
        end

        WaitSeconds( self.Data.TrackTargetDelay or 0.3 )

        if self.Data.TrackTargetProjectileVelocity and self.Data.TrackTargetProjectileVelocity > 0 then
            self:SetVelocity( self.Data.TrackTargetProjectileVelocity )
        end

        self:SetTurnRate(2)
        WaitSeconds(0.7)
        local CheckHeight = false
        while not self:BeenDestroyed() do

            local dist, height = self:GetDistanceToTargetAndHeight()

            if height > 5 and not CheckHeight then
                CheckHeight = true
            end

            if self.DoSplit and CheckHeight and height <= 5 and not self:IsFlared() then
                self:ForkThread( self.Split )
                KillThread( self.MoveThread )
            end

            if CheckHeight then

                if dist > 40 then
                    self:SetTurnRate(20)
                    WaitTicks(19)

                elseif dist > 30 then
                    self:SetTurnRate(40)
                    WaitTicks(2)

                elseif dist > 0 and dist <= 30 then
                    self:SetTurnRate(100)

                end
            end

            WaitTicks(1)
        end
    end,

    UnderWaterThread = function(self, EffectsBag)

        -- create attached air bubbles emitter
        self.IsUnderWater = true
        local army, emit = self:GetLauncher().Army
        for k, v in NomadsEffectTemplate.TacticalMissileTrailFxUnderWaterAddon do
            emit = CreateAttachedEmitter( self, -1, army, v )
            EffectsBag:Add( emit )
            self.Trash:Add( emit )
        end

        -- monitor projectile height to see when it's below water surface
        local pos = self:GetPosition()
        local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
        while pos[2] < surface do
            WaitTicks(1)
            if not self or self:BeenDestroyed() then return end
            pos = self:GetPosition()
        end

        -- remove water trail
        EffectsBag:Destroy()

        self.IsUnderWater = false
        self:SetDestroyOnWater( self:GetBlueprint().Physics.DestroyOnWaterAfterExitingWater or true )
    end,

    GetDistanceToTargetAndHeight = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        local height = mpos[2] - ( GetSurfaceHeight(mpos[1], mpos[3]) + GetTerrainTypeOffset(mpos[1], mpos[3]) )
        return dist, height
    end,

    OnImpact = function(self, targetType, targetEntity)
        SingleCompositeEmitterProjectile.OnImpact(self, targetType, targetEntity)

        if targetType == 'Terrain' then
            DamageArea(self, self:GetPosition(), self.DamageData.DamageRadius * 1.2, 1, 'Force', true)
        end

        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 2.5, 5*2, 'glow_05_red', 'ramp_jammer_01' )
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 3, 2*2, 'glow_05_red', 'ramp_jammer_01' )

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(4, 5.5)
            local life = Random(100, 150)
            -- CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self.Army) not a smart idea to leave decals on something that fires so fast
            if self.DoImpactFlash then
                CreateLightParticle( self, -1, self.Army, 6, 5, 'glow_03', 'ramp_yellow_blue_01' )
                CreateLightParticle( self, -1, self.Army, 8, 16, 'glow_03', 'ramp_antimatter_02' )
            end
        end
    end,

    OnFlared = function(self, flare)
        self:SetLifetime(10)
        self:SetIsFlared(true)
    end,

    SetIsFlared = function(self, bool)
        self._IsFlared = (bool == true)
    end,

    IsFlared = function(self)
        return self._IsFlared or false
    end,

    Split = function(self)

        local ChildProjectileBP = '/projectiles/NBombProj2Child/NBombProj2Child_proj.bp'
        local numProjectiles = self.DamageData.NumChildProjectiles

        -- split damage between projectiles
        self.DamageData.DamageAmount = self.DamageData.DamageAmount / numProjectiles

        -- Split effects
        CreateLightParticle( self, -1, self.Army, 2, 3, 'glow_03', 'ramp_yellow_blue_01' )

        local vx, vy, vz = self:GetVelocity()
        local velocity = 6

        -- One initial projectile following same directional path as the original
        local child = self:CreateChildProjectile(ChildProjectileBP)
        child:SetVelocity(vx, vy, vz)
        child:SetVelocity(velocity)
        child:PassDamageData(self.DamageData)

        -- Create several other projectiles in a dispersal pattern
        local angle = (3*math.pi) / numProjectiles
        local angleInitial = RandomFloat( 0, angle )

        -- Randomization of the spread
        local angleVariation = angle * 0.75 -- Adjusts angle variance spread
        local spreadMul = 0.7 -- Adjusts the width of the dispersal

        local xVec = vx
        local yVec = vy
        local zVec = vz

        -- Launch projectiles at semi-random angles away from split location. NumProjs minus 2 iso 1 because we already made a
        -- child proj.
        for i = 0, (numProjectiles - 2) do
            xVec = vx + (math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            zVec = vz + (math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            local proj = self:CreateChildProjectile(ChildProjectileBP)
            proj:SetVelocity(xVec,yVec,zVec)
            proj:SetVelocity(velocity)
            proj:PassDamageData(self.DamageData)
        end

        self:Destroy()
    end,
}

---@class ArcingTacticalMissile : TacticalMissile
ArcingTacticalMissile = Class(TacticalMissile) {
    BeamName = NomadsEffectTemplate.ArcingTacticalMissileBeam,
    FxImpactAirUnit = NomadsEffectTemplate.ArcingTacticalMissileHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.ArcingTacticalMissileHitLand1,
    FxImpactNone = NomadsEffectTemplate.ArcingTacticalMissileHitNone1,
    FxImpactProp = NomadsEffectTemplate.ArcingTacticalMissileHitProp1,
    FxImpactShield = NomadsEffectTemplate.ArcingTacticalMissileHitShield1,
    FxImpactUnit = NomadsEffectTemplate.ArcingTacticalMissileHitUnit1,
    FxImpactWater = NomadsEffectTemplate.ArcingTacticalMissileHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.ArcingTacticalMissileHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.ArcingTacticalMissileHitUnderWater1,

    FxTrails = NomadsEffectTemplate.ArcingTacticalMissileTrail,
    PolyTrail = NomadsEffectTemplate.ArcingTacticalMissilePolyTrail,

    -- small correction to make the smoke appear to come from the missile
    FxTrailOffset = -0.32,
    PolyTrailOffset = -0.22,

    OnFlare_SetTrackTarget = true,  -- used to enable Aeon TMD working on this projectile

    MovementThread = function(self)
        -- since this projectile is supposed to act like a high artillery we dont need this
    end,
}







-----------------------------
-- 2023-03-10 Crimes commited to hotix game freeze - [e]Exotic_Retard
-- This needs some testing and so on but the triple inheritance of StrategicMissile = Class(SingularityProjectile, NukeProjectile, SingleBeamProjectile) caused the sim to freeze.
-- Also needs more investigating into why this even happened.
-- Also as of 2023-03-10 the nuke explosion has double effects - still mostly works though and its definitely an improvement over the situation of nothing working.
-----------------------------

---@class SingularityProjectile : NullShell
SingularityProjectile = Class(NullShell) {
    NukeProjBp = '/effects/Entities/NBlackhole/NBlackhole_proj.bp',

    -- no impact Fx, the blackhole entity script does this
    FxImpactUnit = {},
    FxImpactLand = {},
    FxImpactUnderWater = {},
    
    
    OnCreate = function(self)
        NullShell.OnCreate(self)
        self.Launcher = self:GetLauncher()
    end,
    
    OnImpact = function(self, targetType, TargetEntity)
        if self.AlreadyExploded then return end
        -- if we didn't impact with another projectile (that would be the anti nuke projectile) then create nuke effect
        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then
            self.AlreadyExploded = true --incase we decide to hit something else instead.

            -- Play the explosion sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end
            
            self:CreateSingularity(self.Launcher)
        end
        self:ForkThread( self.ExplosionDelayThread, targetType, TargetEntity)
    end,
    
    ExplosionDelayThread = function(self, targetType, TargetEntity)
        WaitSeconds(0.1)
        NullShell.OnImpact(self, targetType, TargetEntity)
    end,
    
    CreateSingularity = function(self, parent)
        if not parent.NukeEntity then
            WARN('nomads: parent entity for singularity is dead or missing')
        end
        parent.NukeEntity = self:CreateProjectile( self.NukeProjBp, 0, 0, 0, nil, nil, nil):SetCollision(false)
        parent.NukeEntity:SetParent(parent)
    end,
}

--a most unholy mergination of various classes but it all works! and has a linecount of approximately 0 as a result
--StrategicMissile = Class(SingularityProjectile, NukeProjectile, SingleBeamProjectile) {

---@class StrategicMissile : NukeProjectile
StrategicMissile = Class(NukeProjectile) {
    InitialEffects = NomadsEffectTemplate.NukeMissileInitialEffects,
    LaunchEffects = NomadsEffectTemplate.NukeMissileLaunchEffects,
    ThrustEffects = NomadsEffectTemplate.NukeMissileThrustEffects,
    BeamName = NomadsEffectTemplate.NukeMissileBeam,
    
    --OnCreate = function(self)
        --SingleBeamProjectile.OnCreate(self)
        --self:LauncherCallbacks()
    --end,
    
    --OnImpact = function(self, targetType, TargetEntity)
        --SingularityProjectile.OnImpact(self, targetType, TargetEntity)
    --end,
    
    
    
    NukeProjBp = '/effects/Entities/NBlackhole/NBlackhole_proj.bp',

    -- no impact Fx, the blackhole entity script does this
    FxImpactUnit = {},
    FxImpactLand = {},
    FxImpactUnderWater = {},
    
    
    OnCreate = function(self)
        NukeProjectile.OnCreate(self)
        self.effectEntityPath = '/effects/Entities/NBlackhole/NBlackhole_proj.bp' --TODO: right now the nomads projectile isnt made to be run like this so this both duplicates the effect and 
        self.Launcher = self:GetLauncher()
        self:LauncherCallbacks()
    end,
    
    OnImpact = function(self, targetType, TargetEntity)
        if self.AlreadyExploded then return end
        -- if we didn't impact with another projectile (that would be the anti nuke projectile) then create nuke effect
        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then
            self.AlreadyExploded = true --incase we decide to hit something else instead.

            -- Play the explosion sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end
            
            self:CreateSingularity(self.Launcher)
        end
        self:ForkThread( self.ExplosionDelayThread, targetType, TargetEntity)
    end,
    
    ExplosionDelayThread = function(self, targetType, TargetEntity)
        WaitSeconds(0.1)
        NukeProjectile.OnImpact(self, targetType, TargetEntity)
        self.effectEntity:SetParent(self.Launcher)
    end,
    
    CreateSingularity = function(self, parent)
        if not parent.NukeEntity then
            WARN('nomads: parent entity for singularity is dead or missing')
        end
        parent.NukeEntity = self:CreateProjectile( self.NukeProjBp, 0, 0, 0, nil, nil, nil):SetCollision(false)
        parent.NukeEntity:SetParent(parent)
    end,
}



-- -----------------------------------------------------------------------------------------------------
-- ROCKETS       (UNGUIDED, PROPELED)
-- -----------------------------------------------------------------------------------------------------

---@class Rocker1 : SingleCompositeEmitterProjectile
Rocket1 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadsEffectTemplate.RocketBeam,

    FxImpactAirUnit = NomadsEffectTemplate.RocketHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.RocketHitLand1,
    FxImpactNone = NomadsEffectTemplate.RocketHitNone1,
    FxImpactProp = NomadsEffectTemplate.RocketHitProp1,
    FxImpactShield = NomadsEffectTemplate.RocketHitShield1,
    FxImpactUnit = NomadsEffectTemplate.RocketHitUnit1,
    FxImpactWater = NomadsEffectTemplate.RocketHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.RocketHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.RocketHitUnderWater1,

    FxTrails = NomadsEffectTemplate.RocketTrail,
    PolyTrail = NomadsEffectTemplate.RocketPolyTrail,
}

---@class Rocker2 : SingleCompositeEmitterProjectile
Rocket2 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadsEffectTemplate.RocketBeam2,

    FxImpactAirUnit = NomadsEffectTemplate.RocketHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.RocketHitLand2,
    FxImpactNone = NomadsEffectTemplate.RocketHitNone2,
    FxImpactProp = NomadsEffectTemplate.RocketHitProp2,
    FxImpactShield = NomadsEffectTemplate.RocketHitShield2,
    FxImpactUnit = NomadsEffectTemplate.RocketHitUnit2,
    FxImpactWater = NomadsEffectTemplate.RocketHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.RocketHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.RocketHitUnderWater2,

    FxTrails = NomadsEffectTemplate.RocketTrail2,
    PolyTrail = NomadsEffectTemplate.RocketPolyTrail2,
}

---@class Rocker3 : SingleCompositeEmitterProjectile
Rocket3 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadsEffectTemplate.RocketBeam3,

    FxImpactAirUnit = NomadsEffectTemplate.RocketHitAirUnit3,
    FxImpactLand = NomadsEffectTemplate.RocketHitLand3,
    FxImpactNone = NomadsEffectTemplate.RocketHitNone3,
    FxImpactProp = NomadsEffectTemplate.RocketHitProp3,
    FxImpactShield = NomadsEffectTemplate.RocketHitShield3,
    FxImpactUnit = NomadsEffectTemplate.RocketHitUnit3,
    FxImpactWater = NomadsEffectTemplate.RocketHitWater3,
    FxImpactProjectile = NomadsEffectTemplate.RocketHitProjectile3,
    FxImpactUnderWater = NomadsEffectTemplate.RocketHitUnderWater3,

    OnImpact = function(self, targetType, targetEntity)
        -- create flash
        NomadsExplosions.CreateFlashCustom( self, -2, self.Army, 1, 5, 'glow_06_red', 'ramp_transparency_flash_dark_2' )
        SinglePolyTrailProjectile.OnImpact( self, targetType, targetEntity )
    end,

    FxTrails = NomadsEffectTemplate.RocketTrail3,
    PolyTrail = NomadsEffectTemplate.RocketPolyTrail3,
}

---@class Rocker4 : SingleCompositeEmitterProjectile
Rocket4 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadsEffectTemplate.RocketBeam4,

    FxImpactAirUnit = NomadsEffectTemplate.RocketHitAirUnit4,
    FxImpactLand = NomadsEffectTemplate.RocketHitLand4,
    FxImpactNone = NomadsEffectTemplate.RocketHitNone4,
    FxImpactProp = NomadsEffectTemplate.RocketHitProp4,
    FxImpactShield = NomadsEffectTemplate.RocketHitShield4,
    FxImpactUnit = NomadsEffectTemplate.RocketHitUnit4,
    FxImpactWater = NomadsEffectTemplate.RocketHitWater4,
    FxImpactProjectile = NomadsEffectTemplate.RocketHitProjectile4,
    FxImpactUnderWater = NomadsEffectTemplate.RocketHitUnderWater4,

    FxTrails = NomadsEffectTemplate.RocketTrail4,
    PolyTrail = NomadsEffectTemplate.RocketPolyTrail4,
}

---@class Rocker5 : SingleCompositeEmitterProjectile
Rocket5 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadsEffectTemplate.RocketBeam5,

    FxImpactAirUnit = NomadsEffectTemplate.RocketHitAirUnit5,
    FxImpactLand = NomadsEffectTemplate.RocketHitLand5,
    FxImpactNone = NomadsEffectTemplate.RocketHitNone5,
    FxImpactProp = NomadsEffectTemplate.RocketHitProp5,
    FxImpactShield = NomadsEffectTemplate.RocketHitShield5,
    FxImpactUnit = NomadsEffectTemplate.RocketHitUnit5,
    FxImpactWater = NomadsEffectTemplate.RocketHitWater5,
    FxImpactProjectile = NomadsEffectTemplate.RocketHitProjectile5,
    FxImpactUnderWater = NomadsEffectTemplate.RocketHitUnderWater5,

    FxTrails = NomadsEffectTemplate.RocketTrail5,
    PolyTrail = NomadsEffectTemplate.RocketPolyTrail5,
}

-- -----------------------------------------------------------------------------------------------------
-- Bombs and alike (dropped from aircraft)
-- -----------------------------------------------------------------------------------------------------

---@class ConventionalBomb : SinglePolyTrailProjectile
ConventionalBomb = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.ConventionalBombHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.ConventionalBombHitLand1,
    FxImpactNone = NomadsEffectTemplate.ConventionalBombHitNone1,
    FxImpactProp = NomadsEffectTemplate.ConventionalBombHitProp1,
    FxImpactShield = NomadsEffectTemplate.ConventionalBombHitShield1,
    FxImpactUnit = NomadsEffectTemplate.ConventionalBombHitUnit1,
    FxImpactWater = NomadsEffectTemplate.ConventionalBombHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.ConventionalBombHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.ConventionalBombHitUnderWater1,

    FxTrails = NomadsEffectTemplate.ConventionalBombTrail,
    PolyTrail = NomadsEffectTemplate.ConventionalBombPolyTrail,
}

---@class ConcussionBomb : SinglePolyTrailProjectile
ConcussionBomb = Class(SinglePolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,

    FxImpactAirUnit = NomadsEffectTemplate.ConcussionBombHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.ConcussionBombHitLand1,
    FxImpactNone = NomadsEffectTemplate.ConcussionBombHitNone1,
    FxImpactProp = NomadsEffectTemplate.ConcussionBombHitProp1,
    FxImpactShield = NomadsEffectTemplate.ConcussionBombHitShield1,
    FxImpactUnit = NomadsEffectTemplate.ConcussionBombHitUnit1,
    FxImpactWater = NomadsEffectTemplate.ConcussionBombHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.ConcussionBombHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.ConcussionBombHitUnderWater1,

    FxTrails = NomadsEffectTemplate.ConcussionBombTrail,
    PolyTrail = NomadsEffectTemplate.ConcussionBombPolyTrail,

    PassDamageData = function(self, DamageData)
        SinglePolyTrailProjectile.PassDamageData(self, DamageData)
        self.DamageData.NumFragments = DamageData.NumFragments
    end,

    OnImpact = function(self, targetType, targetEntity)
        -- create decal
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0, 2*math.pi)
            local size = RandomFloat(2, 3)
            local life = RandomFloat(50, 100)
            CreateDecal(self:GetPosition(), rotation, '/textures/splats/ConcussionBomb/ConcussionBomb_decal_albedo.dds', '', 'Albedo', size, size, 350, life, self.Army)
        end    
        SinglePolyTrailProjectile.OnImpact( self, targetType, targetEntity )
    end,
}

---@class EnergyBomb : SinglePolyTrailProjectile
EnergyBomb = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadsEffectTemplate.EnergyProjHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.EnergyProjHitLand2,
    FxImpactNone = NomadsEffectTemplate.EnergyProjHitNone2,
    FxImpactProp = NomadsEffectTemplate.EnergyProjHitProp2,
    FxImpactShield = NomadsEffectTemplate.EnergyProjHitShield2,
    FxImpactUnit = NomadsEffectTemplate.EnergyProjHitUnit2,
    FxImpactWater = NomadsEffectTemplate.EnergyProjHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.EnergyProjHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.EnergyProjHitUnderWater2,

    FxTrails = NomadsEffectTemplate.EnergyProjTrail,
    PolyTrail = NomadsEffectTemplate.EnergyProjPolyTrail,

    DoImpactFlash = true,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)

        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)

        if self.DoImpactFlash then
            CreateLightParticle(self, -1, self.Army, 15/3, 9, 'glow_02', 'ramp_red_01')
            CreateLightParticle(self, -1, self.Army, 25/3, 18, 'glow_02', 'ramp_red_01')
            CreateLightParticle(self, -1, self.Army, 25/3, 34, 'glow_02', 'ramp_red_01')
        end

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(15, 20)
            local life = Random(40, 60)
            local albedo = { 'Scorch_001_albedo', 'Scorch_002_albedo', 'Scorch_003_albedo', }  -- keep the 'random' up to date in next line
            CreateDecal(self:GetPosition(), rotation, albedo[ Random(1, 3) ], '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,
}

---@class Buoy1 : SinglePolyTrailProjectile
Buoy1 = Class(SinglePolyTrailProjectile) {

    FxImpactAirUnit = NomadsEffectTemplate.BuoyHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.BuoyHitLand1,
    FxImpactNone = NomadsEffectTemplate.BuoyHitNone1,
    FxImpactProp = NomadsEffectTemplate.BuoyHitProp1,
    FxImpactShield = NomadsEffectTemplate.BuoyHitShield1,
    FxImpactUnit = NomadsEffectTemplate.BuoyHitUnit1,
    FxImpactWater = NomadsEffectTemplate.BuoyHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.BuoyHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.BuoyHitUnderWater1,

    FxTrails = NomadsEffectTemplate.BuoyTrail,
    PolyTrail = NomadsEffectTemplate.BuoyPolyTrail,

    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)

        -- check for DoT damage, this destroys the buoy right away
        local bp = self:GetBlueprint()
        if bp.DoTPulses or bp.DoTTime then
            WARN('Buoy1: The projectile that creates a buoy is a damage over time weapon. This can destroy the buoy.')
        end
    end,

    OnImpact = function(self, targetType, targetEntity)
        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)
        local ok = (targetType ~= 'Water' and targetType ~= 'None' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1.5, 2.25)
            local life = Random(75, 100)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_005_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end
    end,
}

-- anti air missile flares
---@class Flare1 : SinglePolyTrailProjectile
Flare1 = Class(SinglePolyTrailProjectile) {

    FxImpactAirUnit = NomadsEffectTemplate.FlareHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.FlareHitLand1,
    FxImpactNone = NomadsEffectTemplate.FlareHitNone1,
    FxImpactProp = NomadsEffectTemplate.FlareHitProp1,
    FxImpactShield = NomadsEffectTemplate.FlareHitShield1,
    FxImpactUnit = NomadsEffectTemplate.FlareHitUnit1,
    FxImpactWater = NomadsEffectTemplate.FlareHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.FlareHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.FlareHitUnderWater1,

    FxTrails = NomadsEffectTemplate.FlareTrail,
    PolyTrail = NomadsEffectTemplate.FlarePolyTrail,

    DetectProjectileDistance = 10,

    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)

        local bp = self:GetBlueprint().Physics
        self:SetLifetime( bp.Lifetime )
        self:SetAcceleration( bp.Acceleration )
        self:SetVelocity( bp.InitialSpeed )

        local spec = {
            Category = 'ANTIAIR MISSILE',
            Radius = self.DetectProjectileDistance or 10,
        }
        self:AddFlare( spec )
    end,
}

--------------------------------------------------------------------------
-- Anti navy projectiles (under water)
--------------------------------------------------------------------------

---@class Torpedo1 : OnWaterEntryEmitterProjectile
Torpedo1 = Class(OnWaterEntryEmitterProjectile) {
    -- Can be dropped from aircraft

    FxImpactAirUnit = NomadsEffectTemplate.TorpedoHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.TorpedoHitLand1,
    FxImpactNone = NomadsEffectTemplate.TorpedoHitNone1,
    FxImpactProp = NomadsEffectTemplate.TorpedoHitProp1,
    FxImpactShield = NomadsEffectTemplate.TorpedoHitShield1,
    FxImpactUnit = NomadsEffectTemplate.TorpedoHitUnit1,
    FxImpactWater = NomadsEffectTemplate.TorpedoHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.TorpedoHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.TorpedoHitUnderWater1,

    FxTrails = NomadsEffectTemplate.TorpedoTrail,

    FxEnterWater = NomadsEffectTemplate.TorpedoEnterWater,

    DroppedFromAir = false,

    OnCreate = function(self, inWater)
        OnWaterEntryEmitterProjectile.OnCreate(self)

        self.DroppedFromAir = not inWater
        if self.DroppedFromAir then
            self:TrackTarget(false)
        else
            self:OnEnterWater(false)
        end
    end,

    OnEnterWater = function(self, UseEnterWaterTurnRate)
        OnWaterEntryEmitterProjectile.OnEnterWater(self)

        local bp = self:GetBlueprint().Physics

        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
        self:TrackTarget( bp.TrackTarget or true )
        self:SetMaxSpeed( bp.MaxSpeed or 18)
        self:StayUnderwater( bp.StayUnderwater or true )

        if UseEnterWaterTurnRate ~= false and bp.EnterWaterTurnRate and bp.EnterWaterTurnRate ~= bp.TurnRate then
            self:DelayedSetTurnRate( 0.3, bp.EnterWaterTurnRate or 400, bp.TurnRate or 120 )
        else
            self:SetTurnRate( bp.TurnRate or 120 )
        end

        if self.DroppedFromAir then
            -- if dropped from air create splash
            for k, v in self.FxEnterWater do
                CreateEmitterAtEntity(self, self.Army, v)
            end
        end
    end,

    DelayedSetTurnRate = function(self, delay, before, after)
        local fn = function(self, delay, before, after)
            self:SetTurnRate(before)
            WaitSeconds(delay)
            self:SetTurnRate(after)
        end
        self:ForkThread( fn, delay, before, after)
    end,
}

---@class UnderwaterRailGunProj : RailGunProj
UnderwaterRailGunProj = Class(RailGunProj) {
    FxImpactAirUnit = NomadsEffectTemplate.UnderWaterRailgunHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.UnderWaterRailgunHitLand1,
    FxImpactNone = NomadsEffectTemplate.UnderWaterRailgunHitNone1,
    FxImpactProp = NomadsEffectTemplate.UnderWaterRailgunHitProp1,
    FxImpactShield = NomadsEffectTemplate.UnderWaterRailgunHitShield1,
    FxImpactUnit = NomadsEffectTemplate.UnderWaterRailgunHitUnit1,
    FxImpactWater = NomadsEffectTemplate.UnderWaterRailgunHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.UnderWaterRailgunHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.UnderWaterRailgunHitUnderWater1,

    FxTrails = NomadsEffectTemplate.UnderWaterRailgunTrail,
    PolyTrail = NomadsEffectTemplate.UnderWaterRailgunPolyTrail,
}

---@class DepthChargeBomb : OnWaterEntryEmitterProjectile
DepthChargeBomb = Class(OnWaterEntryEmitterProjectile) {
    FxImpactTrajectoryAligned = false,

    FxImpactAirUnit = NomadsEffectTemplate.DepthChargeBombHitAirUnit1,
    FxImpactLand = NomadsEffectTemplate.DepthChargeBombHitLand1,
    FxImpactNone = NomadsEffectTemplate.DepthChargeBombHitNone1,
    FxImpactProp = NomadsEffectTemplate.DepthChargeBombHitProp1,
    FxImpactSeabed = NomadsEffectTemplate.DepthChargeBombHitSeabed1,
    FxImpactShield = NomadsEffectTemplate.DepthChargeBombHitShield1,
    FxImpactUnit = NomadsEffectTemplate.DepthChargeBombHitUnit1,
    FxImpactWater = NomadsEffectTemplate.DepthChargeBombHitWater1,
    FxImpactProjectile = NomadsEffectTemplate.DepthChargeBombHitProjectile1,
    FxImpactUnderWater = NomadsEffectTemplate.DepthChargeBombHitUnderWater1,

    FxImpactDeepWater = NomadsEffectTemplate.DepthChargeBombDeepWaterExplosion,  -- special for this one
    FxDeepWaterScale = 1,

    FxTrails = NomadsEffectTemplate.DepthChargeBombTrailWater,
    FxTrailsAir = NomadsEffectTemplate.DepthChargeBombTrailAir,
    FxTrailScaleAir = 1,

    FxTransitionAirToWater = NomadsEffectTemplate.DepthChargeBombTransitionAirToWater,

    MinDetonationDepth = 0,

    OnCreate = function(self, inWater)
        self.AirTrailEmitters = {}
        self.PlayFxImpactFlag = true
        OnWaterEntryEmitterProjectile.OnCreate(self, inWater)
        self:SetDestroyOnWater(false)
        if not inWater then
            -- trail while in air (parent class takes care of trail in water)
            self:CreateAirTrail()
        end
    end,

    PassData = function(self, data)
        OnWaterEntryEmitterProjectile.PassData(self, data)
        if self.Data.DetonateBelowDepth then
            self.Data.DetonateBelowDepth = math.max(self.Data.MinDetonationDepth or 0, self.Data.DetonateBelowDepth)
            self:SetDetonationDepth( self.Data.DetonateBelowDepth )
        end
    end,

    OnEnterWater = function(self)
        OnWaterEntryEmitterProjectile.OnEnterWater(self)
        self:PlayTransitionAirToWaterEffects()
        self:DestroyAirTrail()
        self:TrackTarget(false)
        self:SetVelocity(0,0,0)
        self:SetVelocity(0)
        self:SetBallisticAcceleration(-1)
    end,

    OnImpact = function(self, targetType, targetEntity)
        -- If this projectile impacts at a deep enough level under water then don't play regular fx but another one instead. We'll
        -- disable the normal fx in a function in this class somewhere based on a flag set here.
        -- BUG: sometimes water splashing is displayed even though the bomb hit shoreline / ground. This is engine related because
        -- it tells the script (GetTerrainType() in GetTerrainEffects()) that the projectile hit water instead of normal terrain.
        -- Cannot fix this problem.
        self.PlayFxImpactFlag = not self:PlayExtraImpactEffects(targetType)

        OnWaterEntryEmitterProjectile.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater' and targetType ~= 'Underwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(3, 5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_010_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end
    end,

    SetDetonationDepth = function(self, depth)
        --LOG('*DEBUG: SetDetonationDepth = '..repr(depth))
        self.DetonateBelowDepth = depth

        if not self.DepthMonitorThread then
            local fn = function(self)
                local pos = self:GetPosition()
                local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
                local curDepth
                while self do
                    pos = self:GetPosition()
                    curDepth = surface - pos[2]
                    if curDepth >= self.DetonateBelowDepth then
                        self:OnImpact('Underwater', nil)
                        break
                    end
                    WaitTicks(1)
                end
            end
            self.DepthMonitorThread = self:ForkThread(fn)
        end
    end,

    CreateAirTrail = function(self)
        self:DestroyAirTrail()
        local emit
        for k, v in self.FxTrailsAir do
            emit = CreateEmitterOnEntity(self, self.Army, v)
            emit:ScaleEmitter(self.FxTrailScaleAir)
            emit:OffsetEmitter(0, 0, self.FxTrailOffset)
            table.insert(self.AirTrailEmitters, emit)
        end
    end,

    DestroyAirTrail = function(self)
        for k, v in self.AirTrailEmitters do
            v:Destroy()
        end
        self.AirTrailEmitters = {}
    end,

    PlayTransitionAirToWaterEffects = function(self)
        local emitters, emit = {}
        for k, v in self.FxTransitionAirToWater do
            emit = CreateEmitterAtEntity(self, self.Army, v)
            table.insert(emitters, emit)
        end
        return emitters
    end,

    CreateImpactEffects = function(self, army, EffectTable, EffectScale)
        if self.PlayFxImpactFlag then
            OnWaterEntryEmitterProjectile.CreateImpactEffects(self, army, EffectTable, EffectScale)
        end
    end,

    PlayExtraImpactEffects = function(self, targetType)
        if targetType == 'UnitUnderwater' or targetType == 'Underwater' or targetType == 'Terrain' then

            local pos = self:GetPosition()
            local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])

            if pos[2] < surface then  -- below water surface

                -- Only create effect when we're deep enough in the water
                if self.DamageData.DamageRadius and self.DamageData.DamageRadius > 0 and (surface - pos[2]) > (self.DamageData.DamageRadius / 3) then
                    local spec = {
                        Army = self.Army,
                        Position = self:GetPosition(),
                        Scale = self.DamageData.DamageRadius or 1,
                    }
                    ExplEntity = import('/effects/Entities/NomadsDepthChargeExplosion01/NomadsDepthChargeExplosion01_script.lua').NomadsDepthChargeExplosion01(spec)

                    -- additional FX. (Use derived class to avoid the self.PlayFxImpactFlag )
                    OnWaterEntryEmitterProjectile.CreateImpactEffects(self, army, self.FxImpactDeepWater, self.FxDeepWaterScale)

                    return true   -- indicate that we're creating fx (used to not play certain other fx)
                end
            end
        end

        return false
    end,
}

--------------------------------------------------------------------------
-- Orbital weapons
--------------------------------------------------------------------------

---@class OrbitalEnergyProj : SinglePolyTrailProjectile
OrbitalEnergyProj = Class(SinglePolyTrailProjectile) {   
    -- big energy projectile dropped from high above the target

    FxImpactAirUnit = NomadsEffectTemplate.EnergyProjHitAirUnit2,
    FxImpactLand = NomadsEffectTemplate.EnergyProjHitLand2,
    FxImpactNone = NomadsEffectTemplate.EnergyProjHitNone2,
    FxImpactProp = NomadsEffectTemplate.EnergyProjHitProp2,
    FxImpactShield = NomadsEffectTemplate.EnergyProjHitShield2,
    FxImpactUnit = NomadsEffectTemplate.EnergyProjHitUnit2,
    FxImpactWater = NomadsEffectTemplate.EnergyProjHitWater2,
    FxImpactProjectile = NomadsEffectTemplate.EnergyProjHitProjectile2,
    FxImpactUnderWater = NomadsEffectTemplate.EnergyProjHitUnderWater2,

    FxTrails = NomadsEffectTemplate.EnergyProjTrail,
    FxTrailScale = 2,
    PolyTrail = NomadsEffectTemplate.EnergyProjPolyTrail,

    DoImpactFlash = false,

    OnImpact = function(self, targetType, targetEntity)
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)

        if self.DoImpactFlash then
            CreateLightParticle(self, -1, self.Army, 25, 9, 'glow_02', 'ramp_red_01')
        end

        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0, 2*math.pi)
            local size = RandomFloat(14, 16)
            local life = RandomFloat(200, 300)
            CreateDecal(pos, rotation, 'nuke_scorch_001_normals', '', 'Alpha Normals', size, size, 350, life, self.Army)
            CreateDecal(pos, rotation, 'nuke_scorch_002_albedo', '', 'Albedo', size, size, 350, life, self.Army)
        end    

        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)
    end,
}
