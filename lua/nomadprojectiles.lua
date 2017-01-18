local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = DefaultProjectileFile.EmitterProjectile
local OnWaterEntryEmitterProjectile = DefaultProjectileFile.OnWaterEntryEmitterProjectile
local SingleBeamProjectile = DefaultProjectileFile.SingleBeamProjectile
local MultiBeamProjectile = DefaultProjectileFile.MultiBeamProjectile
local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile 
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile

local EffectTemplate = import('/lua/EffectTemplates.lua')
local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat


-- -----------------------------------------------------------------------------------------------------
-- BALLISTIC PROJECTILES        (UNGUIDED, NOT PROPELED)
-- -----------------------------------------------------------------------------------------------------

RailGunProj = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.RailgunHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.RailgunHitLand1,
    FxImpactNone = NomadEffectTemplate.RailgunHitNone1,
    FxImpactProp = NomadEffectTemplate.RailgunHitProp1,
    FxImpactShield = NomadEffectTemplate.RailgunHitShield1,
    FxImpactUnit = NomadEffectTemplate.RailgunHitUnit1,
    FxImpactWater = NomadEffectTemplate.RailgunHitWater1,
    FxImpactProjectile = NomadEffectTemplate.RailgunHitProjectile1,

    FxTrails = NomadEffectTemplate.RailgunTrail,
    PolyTrail = NomadEffectTemplate.RailgunPolyTrail,

    CollisionCats = {},
    MaxCollisions = -1,

    OnCreate = function(self, InWater)
        SinglePolyTrailProjectile.OnCreate(self, InWater)
        if self.CollisionCats and table.getn(self.CollisionCats) > 0 then
            self:SetCollisionShape('Sphere', 0, 0, 0, 1.8)  -- size of the collision hit box, larger means easier to eat projectiles
        end
    end,

    OnCollisionCheck = function(self, other)

        local ok = false

        -- filtering out only projectiles that dont fit the categories
        if not self.CollisionCats or table.getn(self.CollisionCats) < 1 then
            return false
        elseif self:GetArmy() == other:GetArmy() or IsAlly( self:GetArmy(), other:GetArmy() ) then
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

GattlingRound = Class(MultiPolyTrailProjectile) {

    FxImpactAirUnit = NomadEffectTemplate.GattlingHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.GattlingHitLand1,
    FxImpactNone = NomadEffectTemplate.GattlingHitNone1,
    FxImpactProp = NomadEffectTemplate.GattlingHitProp1,
    FxImpactShield = NomadEffectTemplate.GattlingHitShield1,
    FxImpactUnit = NomadEffectTemplate.GattlingHitUnit1,
    FxImpactWater = NomadEffectTemplate.GattlingHitWater1,
    FxImpactProjectile = NomadEffectTemplate.GattlingHitProjectile1,

    FxTrails = NomadEffectTemplate.GattlingTrail1,
    PolyTrails = NomadEffectTemplate.GattlingPolyTrails1,
    PolyTrailOffset = {0,0,0,0},
}

KineticRound = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.KineticCannonHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.KineticCannonHitLand1,
    FxImpactNone = NomadEffectTemplate.KineticCannonHitNone1,
    FxImpactProp = NomadEffectTemplate.KineticCannonHitProp1,
    FxImpactShield = NomadEffectTemplate.KineticCannonHitShield1,
    FxImpactUnit = NomadEffectTemplate.KineticCannonHitUnit1,
    FxImpactWater = NomadEffectTemplate.KineticCannonHitWater1,
    FxImpactProjectile = NomadEffectTemplate.KineticCannonHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.KineticCannonHitUnderWater1,

    FxImpactTrajectoryAligned = false,
    FxTrails = NomadEffectTemplate.KineticCannonTrail,
    PolyTrail = NomadEffectTemplate.KineticCannonPolyTrail,

    OnImpact = function(self, targetType, targetEntity)
        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)  

        -- create some additional effects
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(2, 3)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_010_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
    end,
}

APRound = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.APCannonHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.APCannonHitLand1,
    FxImpactNone = NomadEffectTemplate.APCannonHitNone1,
    FxImpactProp = NomadEffectTemplate.APCannonHitProp1,
    FxImpactShield = NomadEffectTemplate.APCannonHitShield1,
    FxImpactUnit = NomadEffectTemplate.APCannonHitUnit1,
    FxImpactWater = NomadEffectTemplate.APCannonHitWater1,
    FxImpactProjectile = NomadEffectTemplate.APCannonHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.APCannonHitUnderWater1,

    FxImpactTrajectoryAligned = false,
    FxTrails = NomadEffectTemplate.APCannonTrail,
    PolyTrail = NomadEffectTemplate.APCannonPolyTrail,

    OnImpact = function(self, targetType, targetEntity)
        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)  

        -- create some additional effects
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1, 1.8)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_002_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
    end,
}

Annihilator = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.AnnihilatorHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.AnnihilatorHitLand1,
    FxImpactNone = NomadEffectTemplate.AnnihilatorHitNone1,
    FxImpactProp = NomadEffectTemplate.AnnihilatorHitProp1,
    FxImpactShield = NomadEffectTemplate.AnnihilatorHitShield1,
    FxImpactUnit = NomadEffectTemplate.AnnihilatorHitUnit1,
    FxImpactWater = NomadEffectTemplate.AnnihilatorHitWater1,
    FxImpactProjectile = NomadEffectTemplate.AnnihilatorHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.AnnihilatorHitUnderWater1,

    FxImpactTrajectoryAligned = false,
    FxTrails = NomadEffectTemplate.AnnihilatorTrail,
    PolyTrail = NomadEffectTemplate.AnnihilatorPolyTrail,

    FxTrailOffset = 0,

    OnImpact = function(self, targetType, targetEntity)
        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)  

        -- create some additional effects
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(2, 3)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_001_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
    end,
}

ArtilleryShell = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.ArtilleryHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.ArtilleryHitLand1,
    FxImpactNone = NomadEffectTemplate.ArtilleryHitNone1,
    FxImpactProp = NomadEffectTemplate.ArtilleryHitProp1,
    FxImpactShield = NomadEffectTemplate.ArtilleryHitShield1,
    FxImpactUnit = NomadEffectTemplate.ArtilleryHitUnit1,
    FxImpactWater = NomadEffectTemplate.ArtilleryHitWater1,
    FxImpactProjectile = NomadEffectTemplate.ArtilleryHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.ArtilleryHitUnderWater1,

    FxTrails = NomadEffectTemplate.ArtilleryTrail,
    PolyTrail = NomadEffectTemplate.ArtilleryPolyTrail,

    DoImpactFlash = true,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()
        local pos = self:GetPosition()

        DamageArea(self, pos, self.DamageData.DamageRadius * 3, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius * 3, 1, 'Force', true)

        if self.DoImpactFlash then
            CreateLightParticle( self, -1, army, 16, 6, 'glow_03', 'ramp_antimatter_02' )
        end

        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then
            if self.DoImpactFlash then
                CreateLightParticle( self, -1, army, 16, 6, 'glow_03', 'ramp_antimatter_02' )
            end
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(13, 16)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'nuke_scorch_002_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
            rotation = RandomFloat(0,2*math.pi)
        end	 

        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

ParticleBlastArtilleryShell = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.ParticleBlastArtilleryHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.ParticleBlastArtilleryHitLand1,
    FxImpactNone = NomadEffectTemplate.ParticleBlastArtilleryHitNone1,
    FxImpactProp = NomadEffectTemplate.ParticleBlastArtilleryHitProp1,
    FxImpactShield = NomadEffectTemplate.ParticleBlastArtilleryHitShield1,
    FxImpactUnit = NomadEffectTemplate.ParticleBlastArtilleryHitUnit1,
    FxImpactWater = NomadEffectTemplate.ParticleBlastArtilleryHitWater1,
    FxImpactProjectile = NomadEffectTemplate.ParticleBlastArtilleryHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.ParticleBlastArtilleryHitUnderWater1,
    FxTrails = NomadEffectTemplate.ParticleBlastArtilleryTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadEffectTemplate.ParticleBlastArtilleryPolyTrail,
    PolyTrailOffset = 0,

    FxImpactTrajectoryAligned = false,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)  

        -- create some additional effects
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(8, 12)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
    end,
}

SplittingArtilleryShell = Class(SinglePolyTrailProjectile) {

    FxImpactAirUnit = NomadEffectTemplate.ConcussionBombHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.ConcussionBombHitLand1,
    FxImpactNone = NomadEffectTemplate.ConcussionBombHitNone1,
    FxImpactProp = NomadEffectTemplate.ConcussionBombHitProp1,
    FxImpactShield = NomadEffectTemplate.ConcussionBombHitShield1,
    FxImpactUnit = NomadEffectTemplate.ConcussionBombHitUnit1,
    FxImpactWater = NomadEffectTemplate.ConcussionBombHitWater1,
    FxImpactProjectile = NomadEffectTemplate.ConcussionBombHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.ConcussionBombHitUnderWater1,

    FxTrails = NomadEffectTemplate.ConcussionBombTrail,
    PolyTrail = NomadEffectTemplate.ArtilleryPolyTrail,

    FxImpactTrajectoryAligned = false,

    DoImpactFlash = true,

    PassDamageData = function(self, DamageData)
        SinglePolyTrailProjectile.PassDamageData(self, DamageData)
        self.DamageData.NumFragments = DamageData.NumFragments
        self.DamageData.FragmentDispersalRadius = DamageData.FragmentDispersalRadius
    end,

    OnImpact = function(self, targetType, targetEntity)
        local army = self:GetArmy()

        if self.DoImpactFlash then
            CreateLightParticle( self, -1, army, RandomFloat(15,17), RandomFloat(8,12), 'glow_03', 'ramp_antimatter_02' )
        end
        if targetType ~= "Shield" then
            local rotation = RandomFloat(0, 2*math.pi)
            local size = RandomFloat(2, 3)
            local life = RandomFloat(50, 100)
            CreateDecal(self:GetPosition(), rotation, '/textures/splats/ConcussionBomb/ConcussionBomb_decal_albedo.dds', '', 'Albedo', size, size, 350, life, self:GetArmy())
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

DarkMatterProj = Class(MultiPolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.DarkMatterWeaponHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.DarkMatterWeaponHitLand1,
    FxImpactNone = NomadEffectTemplate.DarkMatterWeaponHitNone1,
    FxImpactProp = NomadEffectTemplate.DarkMatterWeaponHitProp1,
    FxImpactShield = NomadEffectTemplate.DarkMatterWeaponHitShield1,
    FxImpactUnit = NomadEffectTemplate.DarkMatterWeaponHitUnit1,
    FxImpactWater = NomadEffectTemplate.DarkMatterWeaponHitWater1,
    FxImpactProjectile = NomadEffectTemplate.DarkMatterWeaponHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.DarkMatterWeaponHitUnderWater1,

    FxTrails = NomadEffectTemplate.DarkMatterWeaponTrail,

    PolyTrails = NomadEffectTemplate.DarkMatterWeaponPolyTrails,
    PolyTrailOffset = {0,0,0,0,},
    RandomPolyTrails = 1,
}

DarkMatterProj2 = Class(SingleBeamProjectile) {
    BeamName = NomadEffectTemplate.DarkMatterWeaponBeam2,

    FxImpactAirUnit = NomadEffectTemplate.DarkMatterWeaponHitAirUnit2,
    FxImpactLand = NomadEffectTemplate.DarkMatterWeaponHitLand2,
    FxImpactNone = NomadEffectTemplate.DarkMatterWeaponHitNone2,
    FxImpactProp = NomadEffectTemplate.DarkMatterWeaponHitProp2,
    FxImpactShield = NomadEffectTemplate.DarkMatterWeaponHitShield2,
    FxImpactUnit = NomadEffectTemplate.DarkMatterWeaponHitUnit2,
    FxImpactWater = NomadEffectTemplate.DarkMatterWeaponHitWater2,
    FxImpactProjectile = NomadEffectTemplate.DarkMatterWeaponHitProjectile2,
    FxImpactUnderWater = NomadEffectTemplate.DarkMatterWeaponHitUnderWater2,
}

IonBlast = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.IonBlastHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.IonBlastHitLand1,
    FxImpactNone = NomadEffectTemplate.IonBlastHitNone1,
    FxImpactProp = NomadEffectTemplate.IonBlastHitProp1,
    FxImpactShield = NomadEffectTemplate.IonBlastHitShield1,
    FxImpactUnit = NomadEffectTemplate.IonBlastHitUnit1,
    FxImpactWater = NomadEffectTemplate.IonBlastHitWater1,
    FxImpactProjectile = NomadEffectTemplate.IonBlastHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.IonBlastHitUnderWater1,
    FxTrails = NomadEffectTemplate.IonBlastTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadEffectTemplate.IonBlastPolyTrail,
    PolyTrailOffset = 0,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)  

        -- create some additional effects
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1, 1.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
    end,
}

ParticleBlast = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.ParticleBlastHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.ParticleBlastHitLand1,
    FxImpactNone = NomadEffectTemplate.ParticleBlastHitNone1,
    FxImpactProp = NomadEffectTemplate.ParticleBlastHitProp1,
    FxImpactShield = NomadEffectTemplate.ParticleBlastHitShield1,
    FxImpactUnit = NomadEffectTemplate.ParticleBlastHitUnit1,
    FxImpactWater = NomadEffectTemplate.ParticleBlastHitWater1,
    FxImpactProjectile = NomadEffectTemplate.ParticleBlastHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.ParticleBlastHitUnderWater1,
    FxTrails = NomadEffectTemplate.ParticleBlastTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadEffectTemplate.ParticleBlastPolyTrail,
    PolyTrailOffset = 0,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)  

        -- create some additional effects
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1, 1.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
    end,
}

Stingray = Class(MultiPolyTrailProjectile) {

    FxImpactAirUnit = NomadEffectTemplate.StingrayHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.StingrayHitLand1,
    FxImpactNone = NomadEffectTemplate.StingrayHitNone1,
    FxImpactProp = NomadEffectTemplate.StingrayHitProp1,
    FxImpactShield = NomadEffectTemplate.StingrayHitShield1,
    FxImpactUnit = NomadEffectTemplate.StingrayHitUnit1,
    FxImpactWater = NomadEffectTemplate.StingrayHitWater1,
    FxImpactProjectile = NomadEffectTemplate.StingrayHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.StingrayHitUnderWater1,
    FxTrails = NomadEffectTemplate.StingrayTrail,

    PolyTrails = NomadEffectTemplate.StingrayPolyTrails,
    PolyTrailOffset = {0,0,},
}

EmpShell = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.EMPGunHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.EMPGunHitLand1,
    FxImpactNone = NomadEffectTemplate.EMPGunHitNone1,
    FxImpactProp = NomadEffectTemplate.EMPGunHitProp1,
    FxImpactShield = NomadEffectTemplate.EMPGunHitShield1,
    FxImpactUnit = NomadEffectTemplate.EMPGunHitUnit1,
    FxImpactWater = NomadEffectTemplate.EMPGunHitWater1,
    FxImpactProjectile = NomadEffectTemplate.EMPGunHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.EMPGunHitUnderWater1,
    FxTrails = NomadEffectTemplate.EMPGunTrail,
    FxTrailOffset = 0,

    PolyTrail = NomadEffectTemplate.EMPGunPolyTrail,
    PolyTrailOffset = 0,

-- DamageToShields globally implemented in defaultweapons.lua and projectile.lua per build 41
--    PassDamageData = function(self, DamageData)
--        EmitterProjectile.PassDamageData(self, DamageData)
--        if DamageData.DamageToShields then
--            self.DamageData.DamageToShields = DamageData.DamageToShields
--        end
--    end,
--
--    DoShieldDamage = function(self, shield)
--        if self.DamageData.DamageToShields and self.DamageData.DamageToShields > 0 and shield then
--            local damage = math.min( self.DamageData.DamageToShields, shield:GetHealth() )
--            if damage > 0 then
--                Damage( self:GetLauncher(), self:GetPosition(), shield, damage, self.DamageData.DamageType)
--            end
--        end
--    end,

    OnImpact = function(self, targetType, targetEntity)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)

-- DamageToShields globally implemented in defaultweapons.lua and projectile.lua per build 41
--        if targetType == 'Shield' then
--            self:DoShieldDamage( targetEntity )
--        end

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
            Duration = Duration * (NomadEffectTemplate.EMPGunElectricityEffectDurationMulti or 1)
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
            self:PlayElectricityEffects( self:GetArmy(), NomadEffectTemplate.EMPGunElectricityEffect, ImpactEffectScale, Duration )
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
                emit:ScaleEmitter(EffectScale or 1)
            end
            if emit then
                emit:SetEmitterParam('LIFETIME', EffectDuration or 10)
            end
        end
    end,
}

PlasmaProj = Class(SinglePolyTrailProjectile) {
    BeamName = NomadEffectTemplate.PlasmaBoltBeam,

    FxImpactAirUnit = NomadEffectTemplate.PlasmaBoltHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.PlasmaBoltHitLand1,
    FxImpactNone = NomadEffectTemplate.PlasmaBoltHitNone1,
    FxImpactProp = NomadEffectTemplate.PlasmaBoltHitProp1,
    FxImpactShield = NomadEffectTemplate.PlasmaBoltHitShield1,
    FxImpactUnit = NomadEffectTemplate.PlasmaBoltHitUnit1,
    FxImpactWater = NomadEffectTemplate.PlasmaBoltHitWater1,
    FxImpactProjectile = NomadEffectTemplate.PlasmaBoltHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.PlasmaBoltHitUnderWater1,

    FxTrails = NomadEffectTemplate.PlasmaBoltTrail,
    PolyTrail = NomadEffectTemplate.PlasmaBoltPolyTrail,

    DoImpactFlash = false,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)  

        -- create some additional effects
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(2.5, 4)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_009_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
        if self.DoImpactFlash then
            CreateLightParticle( self, -1, army, 6, 5, 'glow_03', 'ramp_yellow_blue_01' )
            CreateLightParticle( self, -1, army, 8, 16, 'glow_03', 'ramp_antimatter_02' )   
        end
    end,
}

EnergyProj = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.EnergyProjHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.EnergyProjHitLand1,
    FxImpactNone = NomadEffectTemplate.EnergyProjHitNone1,
    FxImpactProp = NomadEffectTemplate.EnergyProjHitProp1,
    FxImpactShield = NomadEffectTemplate.EnergyProjHitShield1,
    FxImpactUnit = NomadEffectTemplate.EnergyProjHitUnit1,
    FxImpactWater = NomadEffectTemplate.EnergyProjHitWater1,
    FxImpactProjectile = NomadEffectTemplate.EnergyProjHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.EnergyProjHitUnderWater1,

    FxTrails = NomadEffectTemplate.EnergyProjTrail,
    PolyTrail = NomadEffectTemplate.EnergyProjPolyTrail,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)  

        -- create some additional effects
        local pos = self:GetPosition()
        DamageArea(self, pos, (self.DamageData.DamageRadius or 1) * 1.2, 1, 'BigFire', true)  -- light trees on fire
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(8, 10)
            local life = Random(40, 60)
            local albedo = { 'Scorch_001_albedo', 'Scorch_002_albedo', 'Scorch_003_albedo', }  -- keep the 'random' up to date in next line
            CreateDecal(pos, rotation, albedo[ Random(1, 3) ], '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
    end,
}

-- -----------------------------------------------------------------------------------------------------
-- MISSILES       (GUIDED, PROPELED)
-- -----------------------------------------------------------------------------------------------------

Missile1 = Class(SingleCompositeEmitterProjectile) {

    BeamName = NomadEffectTemplate.MissileBeam,

    FxImpactAirUnit = NomadEffectTemplate.MissileHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.MissileHitLand1,
    FxImpactNone = NomadEffectTemplate.MissileHitNone1,
    FxImpactProp = NomadEffectTemplate.MissileHitProp1,
    FxImpactShield = NomadEffectTemplate.MissileHitShield1,
    FxImpactUnit = NomadEffectTemplate.MissileHitUnit1,
    FxImpactWater = NomadEffectTemplate.MissileHitWater1,
    FxImpactProjectile = NomadEffectTemplate.MissileHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.MissileHitUnderWater1,

    FxTrails = NomadEffectTemplate.MissileTrail,
    PolyTrail = NomadEffectTemplate.MissilePolyTrail,

    OnImpact = function(self, targetType, targetEntity)
        SingleCompositeEmitterProjectile.OnImpact(self, targetType, targetEntity)  

        -- create some additional effects
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1.5, 2.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
    end,
}

FusionMissile = Class(SingleCompositeEmitterProjectile) {

    BeamName = NomadEffectTemplate.FusionMissileBeam,

    FxImpactAirUnit = NomadEffectTemplate.FusionMissileHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.FusionMissileHitLand1,
    FxImpactNone = NomadEffectTemplate.FusionMissileHitNone1,
    FxImpactProp = NomadEffectTemplate.FusionMissileHitProp1,
    FxImpactShield = NomadEffectTemplate.FusionMissileHitShield1,
    FxImpactUnit = NomadEffectTemplate.FusionMissileHitUnit1,
    FxImpactWater = NomadEffectTemplate.FusionMissileHitWater1,
    FxImpactProjectile = NomadEffectTemplate.FusionMissileHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.FusionMissileHitUnderWater1,

    FxTrails = NomadEffectTemplate.FusionMissileTrail,
    PolyTrail = NomadEffectTemplate.FusionMissilePolyTrail,

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
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
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

EMPMissile = Class(FusionMissile) {
    BeamName = NomadEffectTemplate.EMPMissileBeam,

    FxImpactAirUnit = NomadEffectTemplate.EMPMissileHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.EMPMissileHitLand1,
    FxImpactNone = NomadEffectTemplate.EMPMissileHitNone1,
    FxImpactProp = NomadEffectTemplate.EMPMissileHitProp1,
    FxImpactShield = NomadEffectTemplate.EMPMissileHitShield1,
    FxImpactUnit = NomadEffectTemplate.EMPMissileHitUnit1,
    FxImpactWater = NomadEffectTemplate.EMPMissileHitWater1,
    FxImpactProjectile = NomadEffectTemplate.EMPMissileHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.EMPMissileHitUnderWater1,

    FxTrails = NomadEffectTemplate.EMPMissileTrail,
    PolyTrail = NomadEffectTemplate.EMPMissilePolyTrail,

    OnImpact = function(self, targetType, targetEntity)
        FusionMissile.OnImpact(self, targetType, targetEntity)

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
            Duration = Duration * (NomadEffectTemplate.EMPMissileElectricityEffectDurationMulti or 1)
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
            self:PlayElectricityEffects( self:GetArmy(), NomadEffectTemplate.EMPMissileElectricityEffect, ImpactEffectScale, Duration )
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

TacticalMissile = Class(SingleCompositeEmitterProjectile) {
    -- Weapon BP item: NumChildProjectiles, should be supported in weapon aswell.

    BeamName = NomadEffectTemplate.TacticalMissileBeam,
    FxImpactAirUnit = NomadEffectTemplate.TacticalMissileHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.TacticalMissileHitLand1,
    FxImpactNone = NomadEffectTemplate.TacticalMissileHitNone1,
    FxImpactProp = NomadEffectTemplate.TacticalMissileHitProp1,
    FxImpactShield = NomadEffectTemplate.TacticalMissileHitShield1,
    FxImpactUnit = NomadEffectTemplate.TacticalMissileHitUnit1,
    FxImpactWater = NomadEffectTemplate.TacticalMissileHitWater1,
    FxImpactProjectile = NomadEffectTemplate.TacticalMissileHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.TacticalMissileHitUnderWater1,

    FxTrails = NomadEffectTemplate.TacticalMissileTrail,
    PolyTrail = NomadEffectTemplate.TacticalMissilePolyTrail,

    -- small correction to make the smoke appear to come from the missile
    FxTrailOffset = -0.22,
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
        local army, emit = self:GetLauncher():GetArmy()
        for k, v in NomadEffectTemplate.TacticalMissileTrailFxUnderWaterAddon do
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

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then 
            local army = self:GetArmy()
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(4, 5.5)
            local life = Random(100, 150)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_012_albedo', '', 'Albedo', size, size, 300, life, army)
            if self.DoImpactFlash then
                CreateLightParticle( self, -1, army, 6, 5, 'glow_03', 'ramp_yellow_blue_01' )
                CreateLightParticle( self, -1, army, 8, 16, 'glow_03', 'ramp_antimatter_02' )
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
        CreateLightParticle( self, -1, self:GetArmy(), 2, 3, 'glow_03', 'ramp_yellow_blue_01' )
        
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

ArcingTacticalMissile = Class(TacticalMissile) {
    BeamName = NomadEffectTemplate.ArcingTacticalMissileBeam,
    FxImpactAirUnit = NomadEffectTemplate.ArcingTacticalMissileHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.ArcingTacticalMissileHitLand1,
    FxImpactNone = NomadEffectTemplate.ArcingTacticalMissileHitNone1,
    FxImpactProp = NomadEffectTemplate.ArcingTacticalMissileHitProp1,
    FxImpactShield = NomadEffectTemplate.ArcingTacticalMissileHitShield1,
    FxImpactUnit = NomadEffectTemplate.ArcingTacticalMissileHitUnit1,
    FxImpactWater = NomadEffectTemplate.ArcingTacticalMissileHitWater1,
    FxImpactProjectile = NomadEffectTemplate.ArcingTacticalMissileHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.ArcingTacticalMissileHitUnderWater1,

    FxTrails = NomadEffectTemplate.ArcingTacticalMissileTrail,
    PolyTrail = NomadEffectTemplate.ArcingTacticalMissilePolyTrail,

    -- small correction to make the smoke appear to come from the missile
    FxTrailOffset = -0.22,
    PolyTrailOffset = -0.22,

    OnFlare_SetTrackTarget = true,  -- used to enable Aeon TMD working on this projectile

    MovementThread = function(self)
        -- since this projectile is supposed to act like a high artillery we dont need this
    end,
}

StrategicMissile = Class(SingleBeamProjectile) {
    NukeProjBp = '/effects/Entities/NBlackhole/NBlackhole_proj.bp',

    InitialEffects = NomadEffectTemplate.NukeMissileInitialEffects,
    LaunchEffects = NomadEffectTemplate.NukeMissileLaunchEffects,
    ThrustEffects = NomadEffectTemplate.NukeMissileThrustEffects,
    BeamName = NomadEffectTemplate.NukeMissileBeam,

    -- no impact Fx, the blackhole script does this
    FxImpactUnit = {},
    FxImpactLand = {},
    FxImpactUnderWater = {},

    OnCreate = function(self)
        SingleBeamProjectile.OnCreate(self)

        -- allow collisions with other things so we can die during flight
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)

        -- movement stuff
        self:ForkThread( self.MovementThread )

        -- callback. I'm not really sure what this is used for, probably a campaign thingy
        local launcher = self:GetLauncher()
        if launcher and not launcher:IsDead() and launcher.EventCallbacks.ProjectileDamaged then
            self.ProjectileDamaged = {}
            for k,v in launcher.EventCallbacks.ProjectileDamaged do
                table.insert( self.ProjectileDamaged, v )
            end
        end
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
        -- do callback, probably used for campaign (but don't delete!!)
        if self.ProjectileDamaged then
            for k,v in self.ProjectileDamaged do
                v(self)
            end
        end
        SingleBeamProjectile.DoTakeDamage(self, instigator, amount, vector, damageType)
    end,

    OnImpact = function(self, targetType, TargetEntity)
        -- if we didn't impact with another projectile (that would be the anti nuke projectile) then create nuke effect
        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then

            -- Play the explosion sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end
           
            nukeProjectile = self:CreateProjectile( self.NukeProjBp, 0, 0, 0, nil, nil, nil):SetCollision(false)
            nukeProjectile.DamageData = table.deepcopy(self.DamageData)
            nukeProjectile:PassData(self.Data)
        end

        SingleBeamProjectile.OnImpact(self, targetType, TargetEntity)
    end,

    MovementThread = function(self)
        local army = self:GetArmy()
        local launcher = self:GetLauncher()
        self.CreateEffects( self, self.InitialEffects, army, 1 )
        self:TrackTarget(false)
        WaitSeconds(2.5)		-- Height
        self:SetCollision(true)
        self.CreateEffects( self, self.LaunchEffects, army, 1 )
        WaitSeconds(2.5)
        self.CreateEffects( self, self.ThrustEffects, army, 3 )
        WaitSeconds(2.5)
        self:TrackTarget(true) -- Turn ~90 degrees towards target
        self:SetDestroyOnWater(true)
        self:SetTurnRate(47.36)
        WaitSeconds(2) 					-- Now set turn rate to zero so nuke flies straight
        self:SetTurnRate(0)
        self:SetAcceleration(0.001)
        self.WaitTime = 0.5
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    CreateEffects = function( self, EffectTable, army, scale)
        for k, v in EffectTable do
            self.Trash:Add(CreateAttachedEmitter(self, -1, army, v):ScaleEmitter(scale))
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        --Get the nuke as close to 90 deg as possible
        if dist > 150 then        
            --Freeze the turn rate as to prevent steep angles at long distance targets
            self:SetTurnRate(0)
        elseif dist > 75 and dist <= 150 then
						-- Increase check intervals
            self.WaitTime = 0.3
        elseif dist > 32 and dist <= 75 then
						-- Further increase check intervals
            self.WaitTime = 0.1
        elseif dist < 32 then
						-- Turn the missile down
            self:SetTurnRate(50)
        end
    end,
    
    CheckMinimumSpeed = function(self, minSpeed)
        if self:GetCurrentSpeed() < minSpeed then
            return false
        end
        return true
    end,
    
    SetMinimumSpeed = function(self, minSpeed, resetAcceleration)
        if self:GetCurrentSpeed() < minSpeed then
            self:SetVelocity(minSpeed)
            if resetAcceleration then
                self:SetAcceleration(0)
            end
        end
    end,

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
}

-- -----------------------------------------------------------------------------------------------------
-- ROCKETS       (UNGUIDED, PROPELED)
-- -----------------------------------------------------------------------------------------------------

Rocket1 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadEffectTemplate.RocketBeam,

    FxImpactAirUnit = NomadEffectTemplate.RocketHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.RocketHitLand1,
    FxImpactNone = NomadEffectTemplate.RocketHitNone1,
    FxImpactProp = NomadEffectTemplate.RocketHitProp1,
    FxImpactShield = NomadEffectTemplate.RocketHitShield1,
    FxImpactUnit = NomadEffectTemplate.RocketHitUnit1,
    FxImpactWater = NomadEffectTemplate.RocketHitWater1,
    FxImpactProjectile = NomadEffectTemplate.RocketHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.RocketHitUnderWater1,

    FxTrails = NomadEffectTemplate.RocketTrail,
    PolyTrail = NomadEffectTemplate.RocketPolyTrail,
}

Rocket2 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadEffectTemplate.RocketBeam2,

    FxImpactAirUnit = NomadEffectTemplate.RocketHitAirUnit2,
    FxImpactLand = NomadEffectTemplate.RocketHitLand2,
    FxImpactNone = NomadEffectTemplate.RocketHitNone2,
    FxImpactProp = NomadEffectTemplate.RocketHitProp2,
    FxImpactShield = NomadEffectTemplate.RocketHitShield2,
    FxImpactUnit = NomadEffectTemplate.RocketHitUnit2,
    FxImpactWater = NomadEffectTemplate.RocketHitWater2,
    FxImpactProjectile = NomadEffectTemplate.RocketHitProjectile2,
    FxImpactUnderWater = NomadEffectTemplate.RocketHitUnderWater2,

    FxTrails = NomadEffectTemplate.RocketTrail2,
    PolyTrail = NomadEffectTemplate.RocketPolyTrail2,
}

Rocket3 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadEffectTemplate.RocketBeam3,

    FxImpactAirUnit = NomadEffectTemplate.RocketHitAirUnit3,
    FxImpactLand = NomadEffectTemplate.RocketHitLand3,
    FxImpactNone = NomadEffectTemplate.RocketHitNone3,
    FxImpactProp = NomadEffectTemplate.RocketHitProp3,
    FxImpactShield = NomadEffectTemplate.RocketHitShield3,
    FxImpactUnit = NomadEffectTemplate.RocketHitUnit3,
    FxImpactWater = NomadEffectTemplate.RocketHitWater3,
    FxImpactProjectile = NomadEffectTemplate.RocketHitProjectile3,
    FxImpactUnderWater = NomadEffectTemplate.RocketHitUnderWater3,

    FxTrails = NomadEffectTemplate.RocketTrail3,
    PolyTrail = NomadEffectTemplate.RocketPolyTrail3,
}

Rocket4 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadEffectTemplate.RocketBeam4,

    FxImpactAirUnit = NomadEffectTemplate.RocketHitAirUnit4,
    FxImpactLand = NomadEffectTemplate.RocketHitLand4,
    FxImpactNone = NomadEffectTemplate.RocketHitNone4,
    FxImpactProp = NomadEffectTemplate.RocketHitProp4,
    FxImpactShield = NomadEffectTemplate.RocketHitShield4,
    FxImpactUnit = NomadEffectTemplate.RocketHitUnit4,
    FxImpactWater = NomadEffectTemplate.RocketHitWater4,
    FxImpactProjectile = NomadEffectTemplate.RocketHitProjectile4,
    FxImpactUnderWater = NomadEffectTemplate.RocketHitUnderWater4,

    FxTrails = NomadEffectTemplate.RocketTrail4,
    PolyTrail = NomadEffectTemplate.RocketPolyTrail4,
}

Rocket5 = Class(SingleCompositeEmitterProjectile) {
    BeamName = NomadEffectTemplate.RocketBeam5,

    FxImpactAirUnit = NomadEffectTemplate.RocketHitAirUnit5,
    FxImpactLand = NomadEffectTemplate.RocketHitLand5,
    FxImpactNone = NomadEffectTemplate.RocketHitNone5,
    FxImpactProp = NomadEffectTemplate.RocketHitProp5,
    FxImpactShield = NomadEffectTemplate.RocketHitShield5,
    FxImpactUnit = NomadEffectTemplate.RocketHitUnit5,
    FxImpactWater = NomadEffectTemplate.RocketHitWater5,
    FxImpactProjectile = NomadEffectTemplate.RocketHitProjectile5,
    FxImpactUnderWater = NomadEffectTemplate.RocketHitUnderWater5,

    FxTrails = NomadEffectTemplate.RocketTrail5,
    PolyTrail = NomadEffectTemplate.RocketPolyTrail5,
}

-- -----------------------------------------------------------------------------------------------------
-- Bombs and alike (dropped from aircraft)
-- -----------------------------------------------------------------------------------------------------

ConventionalBomb = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.ConventionalBombHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.ConventionalBombHitLand1,
    FxImpactNone = NomadEffectTemplate.ConventionalBombHitNone1,
    FxImpactProp = NomadEffectTemplate.ConventionalBombHitProp1,
    FxImpactShield = NomadEffectTemplate.ConventionalBombHitShield1,
    FxImpactUnit = NomadEffectTemplate.ConventionalBombHitUnit1,
    FxImpactWater = NomadEffectTemplate.ConventionalBombHitWater1,
    FxImpactProjectile = NomadEffectTemplate.ConventionalBombHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.ConventionalBombHitUnderWater1,

    FxTrails = NomadEffectTemplate.ConventionalBombTrail,
    PolyTrail = NomadEffectTemplate.ConventionalBombPolyTrail,
}

ConcussionBomb = Class(SinglePolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,

    FxImpactAirUnit = NomadEffectTemplate.ConcussionBombHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.ConcussionBombHitLand1,
    FxImpactNone = NomadEffectTemplate.ConcussionBombHitNone1,
    FxImpactProp = NomadEffectTemplate.ConcussionBombHitProp1,
    FxImpactShield = NomadEffectTemplate.ConcussionBombHitShield1,
    FxImpactUnit = NomadEffectTemplate.ConcussionBombHitUnit1,
    FxImpactWater = NomadEffectTemplate.ConcussionBombHitWater1,
    FxImpactProjectile = NomadEffectTemplate.ConcussionBombHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.ConcussionBombHitUnderWater1,

    FxTrails = NomadEffectTemplate.ConcussionBombTrail,
    PolyTrail = NomadEffectTemplate.ConcussionBombPolyTrail,

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
            CreateDecal(self:GetPosition(), rotation, '/textures/splats/ConcussionBomb/ConcussionBomb_decal_albedo.dds', '', 'Albedo', size, size, 350, life, self:GetArmy())
        end	 
        SinglePolyTrailProjectile.OnImpact( self, targetType, targetEntity )
    end,
}

EnergyBomb = Class(SinglePolyTrailProjectile) {
    FxImpactAirUnit = NomadEffectTemplate.EnergyProjHitAirUnit2,
    FxImpactLand = NomadEffectTemplate.EnergyProjHitLand2,
    FxImpactNone = NomadEffectTemplate.EnergyProjHitNone2,
    FxImpactProp = NomadEffectTemplate.EnergyProjHitProp2,
    FxImpactShield = NomadEffectTemplate.EnergyProjHitShield2,
    FxImpactUnit = NomadEffectTemplate.EnergyProjHitUnit2,
    FxImpactWater = NomadEffectTemplate.EnergyProjHitWater2,
    FxImpactProjectile = NomadEffectTemplate.EnergyProjHitProjectile2,
    FxImpactUnderWater = NomadEffectTemplate.EnergyProjHitUnderWater2,

    FxTrails = NomadEffectTemplate.EnergyProjTrail,
    PolyTrail = NomadEffectTemplate.EnergyProjPolyTrail,

    DoImpactFlash = true,

    OnImpact = function(self, targetType, targetEntity)
        MultiPolyTrailProjectile.OnImpact(self, targetType, targetEntity)  

        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)

        if self.DoImpactFlash then
			CreateLightParticle(self, -1, self:GetArmy(), 15, 9, 'glow_02', 'ramp_red_01')
            CreateLightParticle(self, -1, self:GetArmy(), 25, 18, 'glow_02', 'ramp_red_01')
			CreateLightParticle(self, -1, self:GetArmy(), 25, 34, 'glow_02', 'ramp_red_01')
        end

        -- create some additional effects
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(15, 20)
            local life = Random(40, 60)
            local albedo = { 'Scorch_001_albedo', 'Scorch_002_albedo', 'Scorch_003_albedo', }  -- keep the 'random' up to date in next line
            CreateDecal(self:GetPosition(), rotation, albedo[ Random(1, 3) ], '', 'Albedo', size, size, 300, life, self:GetArmy())
        end	 
    end,
}

Buoy1 = Class(SinglePolyTrailProjectile) {

    FxImpactAirUnit = NomadEffectTemplate.BuoyHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.BuoyHitLand1,
    FxImpactNone = NomadEffectTemplate.BuoyHitNone1,
    FxImpactProp = NomadEffectTemplate.BuoyHitProp1,
    FxImpactShield = NomadEffectTemplate.BuoyHitShield1,
    FxImpactUnit = NomadEffectTemplate.BuoyHitUnit1,
    FxImpactWater = NomadEffectTemplate.BuoyHitWater1,
    FxImpactProjectile = NomadEffectTemplate.BuoyHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.BuoyHitUnderWater1,

    FxTrails = NomadEffectTemplate.BuoyTrail,
    PolyTrail = NomadEffectTemplate.BuoyPolyTrail,

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
        local ok = (targetType ~= 'None' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir')  -- removed water
        if ok then
            local spec = self:GetSpec( targetType, targetEntity )
            self:CreateBuoy( spec, targetType, targetEntity )

            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(1.5, 2.25)
            local life = Random(75, 100)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_005_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
        end
    end,

    GetSpec = function(self, targetType, targetEntity)
        local pos = self:GetPosition()
        pos[2] = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
        local spec = {
            Activated = true,  -- buoy should activate immediately
            AttachTo = nil,    -- unit to attach the buoy to, if any
            Lifetime = 60,     -- how long the buoy lives
            Owner = self:GetLauncher() or self:GetArmy() or self,
            Pos = pos,
            RealArmy = self:GetArmy() or -1, -- using RealArmy iso Army, see remarks in buoy.lua
        }
        return spec
    end,

    CreateBuoy = function(self, spec, targetType, targetEntity)
    end,
}

-- anti air missile flares
Flare1 = Class(SinglePolyTrailProjectile) {

    FxImpactAirUnit = NomadEffectTemplate.FlareHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.FlareHitLand1,
    FxImpactNone = NomadEffectTemplate.FlareHitNone1,
    FxImpactProp = NomadEffectTemplate.FlareHitProp1,
    FxImpactShield = NomadEffectTemplate.FlareHitShield1,
    FxImpactUnit = NomadEffectTemplate.FlareHitUnit1,
    FxImpactWater = NomadEffectTemplate.FlareHitWater1,
    FxImpactProjectile = NomadEffectTemplate.FlareHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.FlareHitUnderWater1,

    FxTrails = NomadEffectTemplate.FlareTrail,
    PolyTrail = NomadEffectTemplate.FlarePolyTrail,

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

Torpedo1 = Class(OnWaterEntryEmitterProjectile) {
    -- Can be dropped from aircraft

    FxImpactAirUnit = NomadEffectTemplate.TorpedoHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.TorpedoHitLand1,
    FxImpactNone = NomadEffectTemplate.TorpedoHitNone1,
    FxImpactProp = NomadEffectTemplate.TorpedoHitProp1,
    FxImpactShield = NomadEffectTemplate.TorpedoHitShield1,
    FxImpactUnit = NomadEffectTemplate.TorpedoHitUnit1,
    FxImpactWater = NomadEffectTemplate.TorpedoHitWater1,
    FxImpactProjectile = NomadEffectTemplate.TorpedoHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.TorpedoHitUnderWater1,

    FxTrails = NomadEffectTemplate.TorpedoTrail,

    FxEnterWater = NomadEffectTemplate.TorpedoEnterWater,

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
            local army = self:GetArmy()
            for k, v in self.FxEnterWater do
                CreateEmitterAtEntity(self,army,v)
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

UnderwaterRailGunProj = Class(RailGunProj) {
    FxImpactAirUnit = NomadEffectTemplate.UnderWaterRailgunHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.UnderWaterRailgunHitLand1,
    FxImpactNone = NomadEffectTemplate.UnderWaterRailgunHitNone1,
    FxImpactProp = NomadEffectTemplate.UnderWaterRailgunHitProp1,
    FxImpactShield = NomadEffectTemplate.UnderWaterRailgunHitShield1,
    FxImpactUnit = NomadEffectTemplate.UnderWaterRailgunHitUnit1,
    FxImpactWater = NomadEffectTemplate.UnderWaterRailgunHitWater1,
    FxImpactProjectile = NomadEffectTemplate.UnderWaterRailgunHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.UnderWaterRailgunHitUnderWater1,

    FxTrails = NomadEffectTemplate.UnderWaterRailgunTrail,
    PolyTrail = NomadEffectTemplate.UnderWaterRailgunPolyTrail,

    CollisionCats = { categories.TORPEDO, }
}

DepthChargeBomb = Class(OnWaterEntryEmitterProjectile) {
    FxImpactTrajectoryAligned = false,

    FxImpactAirUnit = NomadEffectTemplate.DepthChargeBombHitAirUnit1,
    FxImpactLand = NomadEffectTemplate.DepthChargeBombHitLand1,
    FxImpactNone = NomadEffectTemplate.DepthChargeBombHitNone1,
    FxImpactProp = NomadEffectTemplate.DepthChargeBombHitProp1,
    FxImpactSeabed = NomadEffectTemplate.DepthChargeBombHitSeabed1,
    FxImpactShield = NomadEffectTemplate.DepthChargeBombHitShield1,
    FxImpactUnit = NomadEffectTemplate.DepthChargeBombHitUnit1,
    FxImpactWater = NomadEffectTemplate.DepthChargeBombHitWater1,
    FxImpactProjectile = NomadEffectTemplate.DepthChargeBombHitProjectile1,
    FxImpactUnderWater = NomadEffectTemplate.DepthChargeBombHitUnderWater1,

    FxImpactDeepWater = NomadEffectTemplate.DepthChargeBombDeepWaterExplosion,  -- special for this one
    FxDeepWaterScale = 1,

    FxTrails = NomadEffectTemplate.DepthChargeBombTrailWater,
    FxTrailsAir = NomadEffectTemplate.DepthChargeBombTrailAir,
    FxTrailScaleAir = 1,

    FxTransitionAirToWater = NomadEffectTemplate.DepthChargeBombTransitionAirToWater,

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
        local army = self:GetArmy()
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater' and targetType ~= 'Underwater')
        if ok then 
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(3, 5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_010_albedo', '', 'Albedo', size, size, 300, life, self:GetArmy())
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
        local army, emit = self:GetArmy()
        for k, v in self.FxTrailsAir do
            emit = CreateEmitterOnEntity(self, army, v)
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
        local army, emitters, emit = self:GetArmy(), {}
        for k, v in self.FxTransitionAirToWater do
            emit = CreateEmitterAtEntity(self, army, v)
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

                    local army = self:GetArmy()
                    local spec = {
                        Army = army,
                        Position = self:GetPosition(),
                        Scale = self.DamageData.DamageRadius or 1,
                    }
                    ExplEntity = import('/effects/Entities/NomadDepthChargeExplosion01/NomadDepthChargeExplosion01_script.lua').NomadDepthChargeExplosion01(spec)

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

OrbitalEnergyProj = Class(SinglePolyTrailProjectile) {   -- big energy projectile dropped from high above the target

    FxImpactAirUnit = NomadEffectTemplate.EnergyProjHitAirUnit2,
    FxImpactLand = NomadEffectTemplate.EnergyProjHitLand2,
    FxImpactNone = NomadEffectTemplate.EnergyProjHitNone2,
    FxImpactProp = NomadEffectTemplate.EnergyProjHitProp2,
    FxImpactShield = NomadEffectTemplate.EnergyProjHitShield2,
    FxImpactUnit = NomadEffectTemplate.EnergyProjHitUnit2,
    FxImpactWater = NomadEffectTemplate.EnergyProjHitWater2,
    FxImpactProjectile = NomadEffectTemplate.EnergyProjHitProjectile2,
    FxImpactUnderWater = NomadEffectTemplate.EnergyProjHitUnderWater2,

    FxTrails = NomadEffectTemplate.EnergyProjTrail,
    FxTrailScale = 2,
    PolyTrail = NomadEffectTemplate.EnergyProjPolyTrail,

    DoImpactFlash = false,

    OnImpact = function(self, targetType, targetEntity)
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)

        if self.DoImpactFlash then
            CreateLightParticle(self, -1, self:GetArmy(), 25, 9, 'glow_02', 'ramp_red_01')
        end

        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then 
            local rotation = RandomFloat(0, 2*math.pi)
            local size = RandomFloat(14, 16)
            local life = RandomFloat(200, 300)
            CreateDecal(pos, rotation, 'nuke_scorch_001_normals', '', 'Alpha Normals', size, size, 350, life, self:GetArmy())
            CreateDecal(pos, rotation, 'nuke_scorch_002_albedo', '', 'Albedo', size, size, 350, life, self:GetArmy())
        end	 

        SinglePolyTrailProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

--------------------------------------------------------------------------
-- Flamer projectiles
--------------------------------------------------------------------------
-- Nomads is not using these anymore. Left in here for other modders.

Flamer = Class(EmitterProjectile) {

    FxTrails = {
        '/effects/emitters/Plasmaflamethrower/NapalmTrailFX.bp',
        '/effects/emitters/Plasmaflamethrower/NapalmDistort.bp',
    },
    
    FxImpactTrajectoryAligned = false,

    -- Hit Effects
    FxImpactUnit = NomadEffectTemplate.NPlasmaFlameThrowerHitLand01,
    FxImpactProp = NomadEffectTemplate.NPlasmaFlameThrowerHitLand01,
    FxImpactLand = NomadEffectTemplate.NPlasmaFlameThrowerHitLand01,
    FxImpactWater = NomadEffectTemplate.NPlasmaFlameThrowerHitWater01,
    FxImpactUnderWater = {},
}

