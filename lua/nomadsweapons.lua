local NomadsCollisionBeamFile = import('/lua/nomadscollisionbeams.lua')
local WeaponFile = import('/lua/sim/DefaultWeapons.lua')
local BareBonesWeapon = WeaponFile.BareBonesWeapon
local DefaultProjectileWeapon = WeaponFile.DefaultProjectileWeapon
local DefaultBeamWeapon = WeaponFile.DefaultBeamWeapon
local OverchargeWeapon = WeaponFile.OverchargeWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat


-- ====================================================================================================

AcuUpgradedWeapon = Class(DefaultProjectileWeapon) {
-- TODO: used?
    FxMuzzleFlash = EffectTemplate.TLaserMuzzleFlash,
}

KineticCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.KineticCannonMuzzleFlash,
}

KineticCannon1_Overcharge = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.KineticCannonMuzzleFlash,
}

APCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.APCannonMuzzleFlash,
}

APCannon1_Overcharge = Class(OverchargeWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.APCannonMuzzleFlash,
    DesiredWeaponLabel = 'MainGun'
}

ArtilleryWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.ArtilleryMuzzleFx,

    GetDamageTable = function(self)
        local damageTable = DefaultProjectileWeapon.GetDamageTable(self)
        local weaponBlueprint = self:GetBlueprint()
        damageTable.NumFragments = weaponBlueprint.NumFragments or 0
        damageTable.FragmentDispersalRadius = weaponBlueprint.FragmentDispersalRadius or 0
        return damageTable
    end,
}

DarkMatterWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.DarkMatterAirWeaponMuzzleFlash,
}

EMPGun = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.EMPGunMuzzleFlash,
}

RailgunWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.RailgunMuzzleFx,
}

UnderwaterRailgunWeapon1 = Class(RailgunWeapon1) {
    FxMuzzleFlash = NomadsEffectTemplate.UnderWaterRailgunMuzzleFx,
}

StingrayCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.StingrayMuzzleFx,
}

ParticleBlaster1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.ParticleBlastMuzzleFlash,
}

PlasmaCannon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.PlasmaBoltMuzzleFlash,
}

AnnihilatorCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.AnnihilatorMuzzleFlash,
}

EnergyCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.EnergyProjMuzzleFlash,

    OnCreate = function(self)
        DefaultProjectileWeapon.OnCreate(self)
        local bp = self:GetBlueprint()
        if not bp.DoTPulses or not bp.DoTTime then
            WARN('EnergyCannon1: unit '..repr(self.unit:GetUnitId())..' does not have correct DoT values in blueprint!')
        end
    end,
}

GattlingWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/machinegun_muzzle_fire_01_emit.bp',
        '/effects/emitters/machinegun_muzzle_fire_02_emit.bp',
    },

    Rotates = true,

    OnCreate = function(self)
        DefaultProjectileWeapon.OnCreate(self)

        local bp = self:GetBlueprint()
        self.Rotates = (bp.GattlingBarrelBone ~= nil)
        if self.Rotates then
            if not bp.GattlingBarrelBone then
                WARN('GattlingWeapon: no barrel bone defined in weapon blueprint for unit '..repr(self.unit:GetUnitId()))
                self.Rotates = false
            elseif not bp.WeaponUnpacks then
                WARN('GattlingWeapon: weapon need to unpack spinning barrels, on  unit '..repr(self.unit:GetUnitId()))
                self.Rotates = false
            else
                local bone = bp.GattlingBarrelBone
                self.SpinManip = CreateRotator(self.unit, bone, 'z', nil, 0, 200, 0)
                self.unit.Trash:Add(self.SpinManip)
            end
            self.IsRotating = false
        end
    end,

    SetBarrelRotating = function(self, enabled)
        -- makes gattling weapon barrel spinning or still
        if self.Rotates then
            local speed = 0
            if enabled then
                speed = self:GetBlueprint().GattlingBarrelRotationSpeed or (self:GetRateOfFire() * 100)
                self:PlayWeaponSound('SpinningStart')
                self:PlayWeaponAmbientSound('SpinningLoop')  -- can use BarrelLoop as with other gatlings. See original OnStartTracking fn.
            else
                if self.IsRotating then
                    self:StopWeaponAmbientSound('SpinningLoop')
                    self:PlayWeaponSound('SpinningStop')
                end
            end
            self.SpinManip:SetTargetSpeed( speed )
            self.IsRotating = (speed > 0)
        end
    end,

    PlayFxWeaponUnpackSequence = function(self)
        DefaultProjectileWeapon.PlayFxWeaponPackSequence(self)
        -- we started unpacking the weapon, begin spinning barrel
        self:SetBarrelRotating( true )
    end,

    PlayFxWeaponPackSequence = function(self)
        -- we stopped firing, stop rotating barrel
        self:SetBarrelRotating( false )
        DefaultProjectileWeapon.PlayFxWeaponPackSequence(self)
    end,
}

AAGun = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/machinegun_muzzle_fire_01_emit.bp',
        '/effects/emitters/machinegun_muzzle_fire_02_emit.bp',
    },
}

HVFlakWeapon = Class(DefaultBeamWeapon) {
--high velocity flak for use as tmd
    BeamType = NomadsCollisionBeamFile.HVFlakCollisionBeam,
    FxMuzzleFlash = {
        '/effects/emitters/cannon_muzzle_fire_01_emit.bp',
        --'/effects/emitters/cannon_muzzle_smoke_03_emit.bp',
        '/effects/emitters/cannon_muzzle_smoke_04_emit.bp',
        '/effects/emitters/cannon_muzzle_water_shock_01_emit.bp',
        '/effects/emitters/cannon_muzzle_flash_09_emit.bp',
        '/effects/emitters/cannon_muzzle_flash_08_emit.bp',
    },

    OnCreate = function(self)
        DefaultBeamWeapon.OnCreate(self)


    end,

    IdleState = State (DefaultBeamWeapon.IdleState) {
        Main = function(self)
            DefaultBeamWeapon.IdleState.Main(self)
        end,

        OnGotTarget = function(self)
            DefaultBeamWeapon.IdleState.OnGotTarget(self)
        end,
    },

    OnLostTarget = function(self)
        DefaultBeamWeapon.OnLostTarget(self)
    end,
}

MissileWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.MissileMuzzleFx,
}

RocketWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.RocketMuzzleFx,
}

RocketWeapon1Bomber = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.BomberRocketMuzzleFx,
}

RocketWeapon4 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.RocketMuzzleFx,
}

PhaseRayGun = Class(DefaultBeamWeapon) {
    BeamType = NomadsCollisionBeamFile.NomadsPhaseRay,
    FxChargeMuzzleFlash = NomadsEffectTemplate.PhaseRayMuzzle,
}

FusionMissileWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.FusionMissileMuzzleFx,
}

EMPMissileWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.EMPMissileMuzzleFx,
}

TacticalMissileWeapon1 = Class(DefaultProjectileWeapon) {
-- Use NumChildProjectiles in the BP to tell the weapon to split up in this many child projectiles when close to the target.
    FxMuzzleFlash = NomadsEffectTemplate.TacticalMissileMuzzleFx,

    CreateProjectileAtMuzzle = function(self, muzzle)
        local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

        local bp = self:GetBlueprint()
        local data = {}
        if bp.TrackTargetDelay then data.TrackTargetDelay = bp.TrackTargetDelay end
        if bp.TrackTargetProjectileVelocity then data.TrackTargetProjectileVelocity = bp.TrackTargetProjectileVelocity end
        proj:PassData( data )
    end,

    GetDamageTable = function(self)
        local table = DefaultProjectileWeapon.GetDamageTable(self)
        table.NumChildProjectiles = self:GetBlueprint().NumChildProjectiles or 0
        return table
    end,
}

TacticalMissileWeapon2 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.TacticalMissileMuzzleFx,
}

DroppedMissileWeapon =  Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {'/effects/emitters/antiair_muzzle_fire_02_emit.bp', },
}

BombWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = nil,
}

DepthChargeBombWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.DepthChargeBombMuzzleFx,

    CreateProjectileAtMuzzle = function(self, muzzle)
        local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

        if proj and not proj:BeenDestroyed()then

            local data = {}
            local bp = self:GetBlueprint()

            if bp.DetonatesAtTargetDepth then

                data['DetonateBelowDepth'] = 0
                data['MinDetonationDepth'] = bp.MinDetonationDepth

                local pos = self:GetCurrentTargetPos()
                if pos then
                    local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
                    if self:GetCurrentTarget() then
                        data['DetonateBelowDepth'] = surface - pos[2]
                    else
                        data['DetonateBelowDepth'] = (surface - GetTerrainHeight(pos[1], pos[3])) + 0.25
                    end
                end

            end

            proj:PassData(data)
        end

        return proj
    end,
}

ConcussionBombWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.ConcussionBombMuzzleFx,

    GetDamageTable = function(self)
        local damageTable = DefaultProjectileWeapon.GetDamageTable(self)
        damageTable.NumFragments = self:GetBlueprint().NumFragments or 1
        damageTable.FragmentSpread = self:GetBlueprint().FragmentSpread or 1
        return damageTable
    end,
}

EnergyBombWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.EnergyProjMuzzleFlash,

    OnCreate = function(self)
        DefaultProjectileWeapon.OnCreate(self)
        local bp = self:GetBlueprint()
        if not bp.DoTPulses or not bp.DoTTime then
            WARN('EnergyCannon1: unit '..repr(self.unit:GetUnitId())..' does not have correct DoT values in blueprint!')
        end
    end,
}

TorpedoWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
        '/effects/emitters/torpedo_underwater_launch_01_emit.bp',
    },
}

AntiTorpedoWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
        '/effects/emitters/torpedo_underwater_launch_01_emit.bp',
    },
}

DroppedTorpedoWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {'/effects/emitters/antiair_muzzle_fire_02_emit.bp',},
}

AirToAirGun1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.DarkMatterAirWeaponMuzzleFlash,
}

OrbitalStrikeBuoy = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.TacticalMissileMuzzleFx,
}

StrategicMissileWeapon = Class(DefaultProjectileWeapon) {

    CreateProjectileForWeapon = function(self, bone)
        local proj = DefaultProjectileWeapon.CreateProjectileForWeapon(self, bone)
        if proj and not proj:BeenDestroyed() then
            local bp = self:GetBlueprint()
            if bp.NukeOuterRingDamage and bp.NukeOuterRingRadius and bp.NukeOuterRingTicks and bp.NukeOuterRingTotalTime and
                                bp.NukeInnerRingDamage and bp.NukeInnerRingRadius and bp.NukeInnerRingTicks and bp.NukeInnerRingTotalTime then
                local data = {
                    DamageType = bp.DamageType or 'Normal',

                    NukeOuterRingDamage = bp.NukeOuterRingDamage or 10,
                    NukeOuterRingRadius = bp.NukeOuterRingRadius or 40,
                    NukeOuterRingTicks = bp.NukeOuterRingTicks or 20,
                    NukeOuterRingTotalTime = bp.NukeOuterRingTotalTime or 10,

                    NukeInnerRingDamage = bp.NukeInnerRingDamage or 2000,
                    NukeInnerRingRadius = bp.NukeInnerRingRadius or 30,
                    NukeInnerRingTicks = bp.NukeInnerRingTicks or 24,
                    NukeInnerRingTotalTime = bp.NukeInnerRingTotalTime or 24,

                    NukeBlackHoleMinDuration = bp.NukeBlackHoleMinDuration or 10,
                    NukeBlackHoleFxScale = bp.NukeBlackHoleFxScale or 1,
                    NukeBlackHoleFxLogo = bp.NukeBlackHoleFxLogo or false,

                    NukeBlackHoleFireballDamage = bp.NukeBlackHoleFireballDamage or 0,
                    NukeBlackHoleFireballRadius = bp.NukeBlackHoleFireballRadius or 0,
                    NukeBlackHoleFireballDamageType = bp.NukeBlackHoleFireballDamageType or 'Normal',
                }
                proj:PassData(data)
            end
        end
        return proj
    end,
}

StrategicMissileDefenseWeapon = Class(DefaultProjectileWeapon) {}

local NukeDamage = import('/lua/sim/NukeDamage.lua').NukeAOE
DeathNuke = Class(BareBonesWeapon) {
    OnFire = function(self)
    end,

    Fire = function(self)
        local bp = self:GetBlueprint()
        self.proj = self.unit:CreateProjectileAtBone(bp.ProjectileId, 0):SetCollision(false)
        self.proj.Launcher = self.unit --ensure that the projectile knows its parent unit
        
        --the projectile disappears without OnImpact so we call the explosion directly instead
        self.proj:CreateSingularity(self.unit)
        
        --This also means we create the damage manually just like the other ACUs do
        self.proj.InnerRing = NukeDamage()
        self.proj.InnerRing:OnCreate(bp.NukeInnerRingDamage, bp.NukeInnerRingRadius, bp.NukeInnerRingTicks, bp.NukeInnerRingTotalTime)
        self.proj.OuterRing = NukeDamage()
        self.proj.OuterRing:OnCreate(bp.NukeOuterRingDamage, bp.NukeOuterRingRadius, bp.NukeOuterRingTicks, bp.NukeOuterRingTotalTime)

        local launcher = self.unit
        local pos = self.proj:GetPosition()
        local army = launcher:GetArmy()
        local brain = launcher:GetAIBrain()
        local damageType = bp.DamageType
        self.proj.InnerRing:DoNukeDamage(launcher, pos, brain, army, damageType)
        self.proj.OuterRing:DoNukeDamage(launcher, pos, brain, army, damageType)
    end,
}

DeathEnergyBombWeapon = Class(BareBonesWeapon) {
    FiringMuzzleBones = {0}, -- just fire from the base bone of the unit

    OnCreate = function(self)
        BareBonesWeapon.OnCreate(self)
        local bp = self:GetBlueprint()
        self.Data = {
            EnergyBombFxScale = bp.EnergyBombFxScale or 1,
        }
        self:SetWeaponEnabled(false)
    end,

    OnFire = function(self)
    end,

    Fire = function(self)
        local myBlueprint = self:GetBlueprint()
        local myProjectile = self.unit:CreateProjectile( myBlueprint.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)
        if self.Data then
            myProjectile:PassData(self.Data)
        end
        myProjectile:PassDamageData(self:GetDamageTable())
    end,
}

--------------------------------------------------------------------------
-- Orbital weapons
--------------------------------------------------------------------------

OrbitalMissileWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/cannon_muzzle_flash_04_emit.bp',
        '/effects/emitters/cannon_muzzle_smoke_11_emit.bp',
    },
}

OrbitalGun = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TIFArtilleryMuzzleFlash,
}

OrbitalEnergyCannon = Class(DefaultProjectileWeapon) {
    FxRackChargeMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxMuzzleFlash = {},

    IfTargetPosUnknownUseLastKnown = true,  -- enable to try to prevent not firing projectiles cause no target location is known

    CreateProjectileAtMuzzle = function(self, muzzle)
        -- creates a projectile in the sky that falls down on the target destination.

        local pos, proj, maxOffset, angle, velocity, bp

        -- determine impact position. This is the targets position
        if self:GetCurrentTargetPos() then
            pos = self:GetCurrentTargetPos()

        elseif self:GetCurrentTarget() then
            pos = self:GetCurrentTarget():GetPosition()

        elseif self.unit:GetTargetEntity() then
            pos = self.unit:GetTargetEntity():GetPosition()

        end

        if (not pos or not pos[1]) and self.IfTargetPosUnknownUseLastKnown then
            pos = self.LastKnownTargetPos
        end
        if not pos or not pos[1] then
            WARN('OrbitalEnergyCannon: cant create projectile cause there is no target position')
            return
        end

        self.LastKnownTargetPos = pos
        bp = self:GetBlueprint()

        -- create projectile and position it above the target location. keep firing randomness in mind
        proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
        maxOffset = bp.FiringRandomness or 1
        velocity = bp.MuzzleVelocity or 100
        angle = Random(1, 360)

        pos[1] = pos[1] + ( math.cos(angle) * RandomFloat(0, maxOffset) )
        pos[2] = pos[2] + 500
        pos[3] = pos[3] + ( math.sin(angle) * RandomFloat(0, maxOffset) )
        proj:SetPosition(pos, true)
        proj:SetBallisticAcceleration(0)
        proj:SetVelocity( 0, -velocity, 0 )

        return proj
    end,
}

--------------------------------------------------------------------------
-- Flame weapons
--------------------------------------------------------------------------
-- Nomads is not using these anymore. Have 1 - 3 units with this weapon fire at the same time and you'll notice why...
-- Also the emitter limit is reached pretty quickly. Left in here for other modders to use.

Flamer = Class(DefaultProjectileWeapon) {

    FxMuzzleFlash = {},
    FxFlame = { '/effects/emitters/Plasmaflamethrower/plasmaflame_perm_emit.bp', },
    FxFlameAtMuzzle = { '/effects/Emitters/op_ambient_fire_01_emit.bp', },
    FlameScale = 1,
    FlameEmitters = {},
    FlameAtMuzzleEmitters = {},
    FlameTimer = 0,
    FlameTimerThreadHandle = nil,

    OnCreate = function(self)
        DefaultProjectileWeapon.OnCreate(self)
        self:CalcScale()
    end,

    CalcScale = function(self)
        -- set the effect scale, works properly for the default flamer effect only
        local maxRadius = self:GetBlueprint().MaxRadius or 12
        self.FlameScale = maxRadius / 12
    end,

    CreateProjectileForWeapon = function(self, bone)
        -- when firing a first projectile add the flamer effect to the muzzle. Don't take it off until we're done shooting.

        DefaultProjectileWeapon.CreateProjectileForWeapon(self, bone)

        self.FlameTimer = 0

        -- attaches the flame effect to the weapon muzzle if not done yet
        if self.FlameTimer <= 0 then

            local army = self.unit:GetArmy()
            for k, v in self.FxFlame do
                local emit = CreateAttachedEmitter( self.unit, bone, army, v ):ScaleEmitter(self.FlameScale)
                table.insert( self.FlameEmitters, emit )
                self.unit.Trash:Add( emit )
            end

            -- start the effect removal timer
            self.FlameTimerThreadHandle = self:ForkThread( self.FlameTimerThread )
        end
    end,

    FlameTimerThread = function(self)
        -- decreases the counter value, when it reaches max the flame effect is removed.
        local max = 20 / (self:GetBlueprint().RateOfFire or 1)
        while self and self.unit and not self.unit:BeenDestroyed() and not self.unit.Dead and self.FlameTimer <= max do
            WaitTicks(1)
            self.FlameTimer = self.FlameTimer + 1
        end
        for k, v in self.FlameEmitters do
            v:Destroy()
        end
    end,

    SetWeaponEnabled = function(self, enable)
        -- Create a flame FX or remove it
        DefaultProjectileWeapon.SetWeaponEnabled(self, enable)

        if enable then
            local army = self.unit:GetArmy()
            local bone = self:GetBlueprint().RackBones[1]['MuzzleBones'][1]
            for k, v in self.FxFlameAtMuzzle do
                local emit = CreateAttachedEmitter( self.unit, bone, army, v ):ScaleEmitter(0.5)
                table.insert( self.FlameAtMuzzleEmitters, emit )
                self.unit.Trash:Add( emit )
            end
        else
            for k, v in self.FlameAtMuzzleEmitters do
                v:Destroy()
            end
        end
    end,
}

