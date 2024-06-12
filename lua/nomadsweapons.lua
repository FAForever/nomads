local NomadsCollisionBeamFile = import('/lua/nomadscollisionbeams.lua')
local WeaponFile = import('/lua/sim/DefaultWeapons.lua')
local BareBonesWeapon = WeaponFile.BareBonesWeapon
local DefaultProjectileWeapon = WeaponFile.DefaultProjectileWeapon
local DefaultBeamWeapon = WeaponFile.DefaultBeamWeapon
local OverchargeWeapon = WeaponFile.OverchargeWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NukeDamage = import('/lua/sim/NukeDamage.lua').NukeAOE

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat


--When adding weapon classes, follow the FAF naming conventions - NIFOrbitalBombardmentWeapon

--------------------------------------------------------------------------
-- Projectile Weapons
--------------------------------------------------------------------------

--- # Autocannons
---@class NDFRotatingAutocannonWeapon :DefaultProjectileWeapon
NDFRotatingAutocannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/machinegun_muzzle_fire_01_emit.bp',
        '/effects/emitters/machinegun_muzzle_fire_02_emit.bp',
    },

    --add some effects when the weapon has a target
    IdleState = State(DefaultProjectileWeapon.IdleState) {
        Main = function(self)
            DefaultProjectileWeapon.IdleState.Main(self)
            if self.SpinManip then
                self.SpinManip:SetTargetSpeed(0)
                self:StopWeaponAmbientSound('SpinningLoop')
                self:PlayWeaponSound('SpinningStop')
            end
        end,

        OnGotTarget = function(self)
            DefaultProjectileWeapon.OnGotTarget(self)
            if not self.SpinManip then 
                self.SpinManip = CreateRotator(self.unit, 'Rotator', 'z', nil, 270, 180, 60)
                self.unit.Trash:Add(self.SpinManip)
            end

            if self.SpinManip then
                self.SpinManip:SetTargetSpeed(self:GetBlueprint().GattlingBarrelRotationSpeed or 500)
                self:PlayWeaponSound('SpinningStart')
                self:PlayWeaponAmbientSound('SpinningLoop')  -- can use BarrelLoop as with other gatlings. See original OnStartTracking fn.
            end
        end,
    },
}

--------------------------------------------------------------------------
-- Orbital weapons
--------------------------------------------------------------------------

--Used for orbital bombardment by the orbital frigate. This weapon is with a script, where the fire command is read from a queue.
---@class NIFOrbitalBomardmentWeapon : DefaultProjectileWeapon
NIFOrbitalBombardmentWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/cannon_muzzle_flash_04_emit.bp',
        '/effects/emitters/cannon_muzzle_smoke_11_emit.bp',
    },

    --Remove queue item after firing weapon.
    RackSalvoFiringState = State(DefaultProjectileWeapon.RackSalvoFiringState) {
        Main = function(self)
            DefaultProjectileWeapon.RackSalvoFiringState.Main(self)
            table.remove(self.unit.OrbitalBombardmentQueue,1)
        end,
    },

    --allow setting the launcher to a unit other than the weapons owner, so any veterancy is passed to it instead.
    ---@param self NIFOrbitalBomardmentWeapon
    ---@param bone any
    CreateProjectileForWeapon = function(self, bone)
        local proj = DefaultProjectileWeapon.CreateProjectileForWeapon(self, bone)
        proj.Launcher = self.unit.AssignedUnit or proj.Launcher
    end,
}

---@class NIFTargetFinderWeapon : DefaultProjectileWeapon
NIFTargetFinderWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {},

    ---@param self NIFTargetFinderWeapon
    ---@param muzzle any # Unused
    CreateProjectileAtMuzzle = function(self, muzzle)
        local target = self:GetCurrentTargetPos()
        self.unit:OrbitalStrikeTargets({target})
    end,
}

-- -----------------------------------------------------------------------------------------------------
-- Beam Weapons
-- -----------------------------------------------------------------------------------------------------
---@class NDFPlasmaBeamWeapon : DefaultBeamWeapon
NDFPlasmaBeamWeapon = Class(DefaultBeamWeapon) {
    BeamType = NomadsCollisionBeamFile.NomadsPhaseRay,
    FxChargeMuzzleFlash = NomadsEffectTemplate.PhaseRayMuzzle,

    ---TODO:refactor this away, we shouldnt need to scale effects every tick like that
    ---@param self NDFPlasmaBeamWeapon
    DoChargeUpEffects = function(self)
        -- this plays when the unit packs and unpacks, so both directions
        local fn = function(self)
            local frac, oldfrac = 0, -1
            if self.UnpackAnimator then frac = self.UnpackAnimator:GetAnimationFraction() end
            self.unit:PlayBeamChargeUpSequence()
            self.unit.BeamChargeupEffectScale = frac
            while self and self.unit and not self.unit.Dead do
                if self.UnpackAnimator then
                    frac = self.UnpackAnimator:GetAnimationFraction()
                    self.unit.BeamChargeupEffectScale = math.min(frac, 1)
                    if (frac >= 1 and oldfrac < frac) or (frac <= 0 and oldfrac > frac) then break end
                    oldfrac = frac
                end
                WaitTicks(1)
            end
            if frac < 1 then  -- leaving the effects cleaned up by another process if we're charging up
                self.unit.BeamChargeUpFxBag:Destroy()
            end
        end
        self.unit.BeamHelperFxBag:Add( self:ForkThread( fn ) )
    end,

    ---@param self NDFPlasmaBeamWeapon
    PlayFxWeaponUnpackSequence = function(self)
        self:DoChargeUpEffects()
        self.CurrentlyUnpacking = true
        DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        self.CurrentlyUnpacking = false
    end,

    ---@param self NDFPlasmaBeamWeapon
    PlayFxWeaponPackSequence = function(self)
        if self.CurrentlyUnpacking then
            WARN('Nomads beamer: trying to pack weapon while already unpacking, skipping the pack call for now')
        else
            DefaultBeamWeapon.PlayFxWeaponPackSequence(self)
        end
    end,

    -- we swap the unpack animation when we are loaded into the transport
    ---@param self NDFPlasmaBeamWeapon
    ---@param transportstate boolean
    SetOnTransport = function(self, transportstate)--true when on transport
        DefaultBeamWeapon.SetOnTransport(self, transportstate)
        self:SetWeaponEnabled(false)
        self:ForkThread( self.TransportAnimationThread, transportstate)
    end,

    ---@param self NDFPlasmaBeamWeapon
    ---@param transportstate boolean
    TransportAnimationThread = function(self, transportstate)--true when on transport
        local bp = self.Blueprint
        if not self.UnpackAnimator then
            self.UnpackAnimator = CreateAnimator(self.unit)
        end
        if self.UnpackAnimator:GetAnimationFraction() > 0 then
            self.UnpackAnimator:SetRate(-bp.WeaponUnpackAnimationRate)
            WaitFor(self.UnpackAnimator)
        end
        if transportstate then
            self.UnpackAnimator:PlayAnim(bp.WeaponUnpackAnimationTransported):SetRate(0)
        else
            self.UnpackAnimator:PlayAnim(bp.WeaponUnpackAnimation):SetRate(0)
        end
        self:SetWeaponEnabled(true)
        self:ResetTarget()
    end,

    ---@param self NDFPlasmaBeamWeapon
    ---@param beam any
    PlayFxBeamEnd = function(self, beam)
        DefaultBeamWeapon.PlayFxBeamEnd(self, beam)
        self.ContBeamOn = false --switch the beam to off, fixing a bug where beam weapons cant cancel their packing sequence midway
    end,
}

--High velocity flak for use as TMD
---@class NAMFlakWeapon : DefaultProjectileWeapon
NAMFlakWeapon = Class(DefaultProjectileWeapon) {
--This has an amount of ammo stored. When its depleted, the weapon goes into a reload cycle.
--When the weapon has no targets, it will also go into a reload cycle. Otherwise it will fire off its unfilled rack.
    FxMuzzleFlash = {
        '/effects/emitters/cannon_muzzle_fire_01_emit.bp',
        --'/effects/emitters/cannon_muzzle_smoke_03_emit.bp',
        '/effects/emitters/cannon_muzzle_smoke_04_emit.bp',
        '/effects/emitters/cannon_muzzle_water_shock_01_emit.bp',
        '/effects/emitters/cannon_muzzle_flash_09_emit.bp',
        '/effects/emitters/cannon_muzzle_flash_08_emit.bp',
    },

    TMDEffectBones = {}, --Change these in the weapon script when hooking to the correct bones for that unit.
    MaxSalvoSize = 4, --Change this to the correct amount for the weapon.
    SalvoReloadTime = 1, --Change this to the correct amount for the weapon.

    -- This entirely overrides the default, since we need to ensure that the tmd never misses.
    ---@param self NAMFlakWeapon
    ---@param muzzle any # Unused
    CreateProjectileAtMuzzle = function(self, muzzle)
        local targetEntity = self:GetCurrentTarget()
        if not targetEntity.GetPosition then return end --if the target is already dead then act as if we havent fired
        
        local bp = self.Blueprint
        
        Damage(self.unit, targetEntity:GetPosition(), targetEntity, bp.Damage, bp.DamageType)
        
        --reduce the projectile count in the clip after dealing damage
        self.ReloadLimitCounter = self.ReloadLimitCounter - 1
        self.LastTimeFired = GetGameTick()
        
        --add a custom effect at the target location
        for k, emitBP in NomadsEffectTemplate.MissileHitNone1 do
            local fx = CreateEmitterOnEntity(targetEntity, self.Army, emitBP):ScaleEmitter(1)
            self.Trash:Add(fx)
        end
        
        --audio
        if self.unit:GetCurrentLayer() == 'Water' and bp.Audio.FireUnderWater then
            self:PlaySound(bp.Audio.FireUnderWater)
        elseif bp.Audio.Fire then
            self:PlaySound(bp.Audio.Fire)
        end
    end,

    ---@param self NAMFlakWeapon
    OnCreate = function(self)
        DefaultProjectileWeapon.OnCreate(self)
        self.TAEffectsBag = TrashBag()
        self.Trash = TrashBag()
        self.PlayingTAEffects = false
        self.ReloadLimitCounter = self.MaxSalvoSize
        self.LastTimeFired = GetGameTick()
    end,

    ---@param self NAMFlakWeapon
    OnDestroy = function(self)
        self:DestroyTAEffects()
        if self.Trash then
            self.Trash:Destroy()
        end
        DefaultProjectileWeapon.OnDestroy(self)
    end,

    --track the last time the weapon fired. If its too soon and its out of ammo, make it reload.
    RackSalvoFireReadyState = State(DefaultProjectileWeapon.RackSalvoFireReadyState ) {
        Main = function(self)
            local ReloadTimeElapsed = GetGameTick() - self.LastTimeFired

            if ReloadTimeElapsed >= self.SalvoReloadTime*10 then
                self.ReloadLimitCounter = self.MaxSalvoSize
            elseif self.ReloadLimitCounter <= 0 then
                self.WeaponCanFire = false
                WaitTicks(self.SalvoReloadTime*10 - ReloadTimeElapsed)
                self.WeaponCanFire = true
                self.ReloadLimitCounter = self.MaxSalvoSize
            end

            DefaultProjectileWeapon.RackSalvoFireReadyState.Main(self)
        end,
    },

    --add some effects when the weapon has a target
    IdleState = State(DefaultProjectileWeapon.IdleState) {
        Main = function(self)
            DefaultProjectileWeapon.IdleState.Main(self)
            self:DestroyTAEffects()
        end,

        OnGotTarget = function(self)
            DefaultProjectileWeapon.OnGotTarget(self)
            self:PlayTAEffects()
        end,
    },

    ---@param self NAMFlakWeapon
    ---@param TMD any # Unused
    PlayTAEffects = function(self, TMD)
        if not self.PlayingTAEffects then
            local emit
            for _, bone in self.TMDEffectBones do
                for k, v in NomadsEffectTemplate.T2MobileTacticalMissileDefenseTargetAcquired do
                    emit = CreateAttachedEmitter(self.unit, bone, self.unit.Army, v)
                    self.TAEffectsBag:Add(emit)
                end
            end
            self.PlayingTAEffects = true
        end
    end,

    ---@param self NAMFlakWeapon
    DestroyTAEffects = function(self)
        self.TAEffectsBag:Destroy()
        self.PlayingTAEffects = false
    end,
}


-- -----------------------------------------------------------------------------------------------------
-- LEGACY WEAPONS - These are used by older versions of nomads, and as such have an older organisation structure.
-- Where possible, create new projectiles and tie them into the new structure instead, so that the old ones eventually dont need to be used.
-- -----------------------------------------------------------------------------------------------------

---@class KineticCannon1 : DefaultProjectileWeapon
KineticCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.KineticCannonMuzzleFlash,
}

---@class APCannon1 : DefaultProjectileWeapon
APCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.APCannonMuzzleFlash,
}

---@class APCannon1_Overcharge : OverchargeWeapon
APCannon1_Overcharge = Class(OverchargeWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.APCannonMuzzleFlash,
    DesiredWeaponLabel = 'MainGun'
}

---@class ArtilleryWeapon : DefaultProjectileWeapon
ArtilleryWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.ArtilleryMuzzleFx,

    ---@param self ArtilleryWeapon
    ---@return table
    GetDamageTable = function(self)
        local damageTable = DefaultProjectileWeapon.GetDamageTable(self)
        local weaponBlueprint = self:GetBlueprint()
        damageTable.NumFragments = weaponBlueprint.NumFragments or 0
        damageTable.FragmentDispersalRadius = weaponBlueprint.FragmentDispersalRadius or 0
        return damageTable
    end,
}

---@class DarkMatterWeapon1 : DefaultProjectileWeapon
DarkMatterWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.DarkMatterAirWeaponMuzzleFlash,
}

---@class EMPGun : DefaultProjectileWeapon
EMPGun = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.EMPGunMuzzleFlash,
}

---@class RailgunWeapon1 : DefaultProjectileWeapon
RailgunWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.RailgunMuzzleFx,
}

---@class UnderwaterRailgunWeapon1 : RailgunWeapon1
UnderwaterRailgunWeapon1 = Class(RailgunWeapon1) {
    FxMuzzleFlash = NomadsEffectTemplate.UnderWaterRailgunMuzzleFx,
}

---@class StingrayCannon1 : DefaultProjectileWeapon
StingrayCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.StingrayMuzzleFx,
}

---@class ParticleBlaster1 : DefaultProjectileWeapon
ParticleBlaster1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.ParticleBlastMuzzleFlash,
}

---@class PlasmaCannon : DefaultProjectileWeapon
PlasmaCannon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.PlasmaBoltMuzzleFlash,
}

---@class AnnihilatorCannon1 : DefaultProjectileWeapon
AnnihilatorCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.AnnihilatorMuzzleFlash,
}

---@class EnergyCannon1 : DefaultProjectileWeapon
EnergyCannon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.EnergyProjMuzzleFlash,

    ---@param self EnergyCannon1
    OnCreate = function(self)
        DefaultProjectileWeapon.OnCreate(self)
        local bp = self:GetBlueprint()
        if not bp.DoTPulses or not bp.DoTTime then
            WARN('EnergyCannon1: unit '..repr(self.unit.UnitId)..' does not have correct DoT values in blueprint!')
        end
    end,
}

---@class GattlingWeapon1 : DefaultProjectileWeapon
GattlingWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/machinegun_muzzle_fire_01_emit.bp',
        '/effects/emitters/machinegun_muzzle_fire_02_emit.bp',
    },

    Rotates = true,

    ---@param self GattlingWeapon1
    OnCreate = function(self)
        DefaultProjectileWeapon.OnCreate(self)

        local bp = self:GetBlueprint()
        self.Rotates = (bp.GattlingBarrelBone ~= nil)
        if self.Rotates then
            if not bp.GattlingBarrelBone then
                WARN('GattlingWeapon: no barrel bone defined in weapon blueprint for unit '..repr(self.unit.UnitId))
                self.Rotates = false
            elseif not bp.WeaponUnpacks then
                WARN('GattlingWeapon: weapon need to unpack spinning barrels, on  unit '..repr(self.unit.UnitId))
                self.Rotates = false
            else
                local bone = bp.GattlingBarrelBone
                self.SpinManip = CreateRotator(self.unit, bone, 'z', nil, 0, 200, 0)
                self.unit.Trash:Add(self.SpinManip)
            end
            self.IsRotating = false
        end
    end,

    ---@param self GattlingWeapon1
    ---@param enabled boolean
    SetBarrelRotating = function(self, enabled)
        -- makes gattling weapon barrel spinning or still
        if self.Rotates then
            local speed = 0
            if enabled then
                speed = self:GetBlueprint().GattlingBarrelRotationSpeed or (self.RateOfFire * 100)
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

    ---@param self GattlingWeapon1
    PlayFxWeaponUnpackSequence = function(self)
        DefaultProjectileWeapon.PlayFxWeaponPackSequence(self)
        -- we started unpacking the weapon, begin spinning barrel
        self:SetBarrelRotating( true )
    end,

    ---@param self GattlingWeapon1
    PlayFxWeaponPackSequence = function(self)
        -- we stopped firing, stop rotating barrel
        self:SetBarrelRotating( false )
        DefaultProjectileWeapon.PlayFxWeaponPackSequence(self)
    end,
}

---@class AAGun : DefaultProjectileWeapon
AAGun = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/machinegun_muzzle_fire_01_emit.bp',
        '/effects/emitters/machinegun_muzzle_fire_02_emit.bp',
    },
}

---@class MissileWeapon1 : DefaultProjectileWeapon
MissileWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.MissileMuzzleFx,
}

---@class RocketWeapon1 : DefaultProjectileWeapon
RocketWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.RocketMuzzleFx,
}

---@class RocketWeapon1Bomber : DefaultProjectileWeapon
RocketWeapon1Bomber = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.BomberRocketMuzzleFx,
}

---@class RocketWeapon4 : DefaultProjectileWeapon
RocketWeapon4 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.RocketMuzzleFx,
}

---@class PhaseRayGun : DefaultBeamWeapon
PhaseRayGun = Class(DefaultBeamWeapon) {
    BeamType = NomadsCollisionBeamFile.NomadsPhaseRay,
    FxChargeMuzzleFlash = NomadsEffectTemplate.PhaseRayMuzzle,
}

---@class FusionMissileWeapon : DefaultProjectileWeapon
FusionMissileWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.FusionMissileMuzzleFx,
}

---@class EMPMissileWeapon : DefaultProjectileWeapon
EMPMissileWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.EMPMissileMuzzleFx,
}

---@class TacticalMissileWeapon1 : DefaultProjectileWeapon
TacticalMissileWeapon1 = Class(DefaultProjectileWeapon) {
-- Use NumChildProjectiles in the BP to tell the weapon to split up in this many child projectiles when close to the target.
    FxMuzzleFlash = NomadsEffectTemplate.TacticalMissileMuzzleFx,

    ---@param self TacticalMissileWeapon1
    ---@param muzzle any # Unused
    CreateProjectileAtMuzzle = function(self, muzzle)
        local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

        local bp = self:GetBlueprint()
        local data = {}
        if bp.TrackTargetDelay then data.TrackTargetDelay = bp.TrackTargetDelay end
        if bp.TrackTargetProjectileVelocity then data.TrackTargetProjectileVelocity = bp.TrackTargetProjectileVelocity end
        proj:PassData( data )
    end,

    ---@param self TacticalMissileWeapon1
    ---@return table
    GetDamageTable = function(self)
        local table = DefaultProjectileWeapon.GetDamageTable(self)
        table.NumChildProjectiles = self:GetBlueprint().NumChildProjectiles or 0
        return table
    end,
}

---@class TacticalMissileWeapon2 : DefaultProjectileWeapon
TacticalMissileWeapon2 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.TacticalMissileMuzzleFx,
}

---@class DroppedMissileWeapon : DefaultProjectileWeapon
DroppedMissileWeapon =  Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {'/effects/emitters/antiair_muzzle_fire_02_emit.bp', },
}

---@class BombWeapon1 : DefaultProjectileWeapon
BombWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = nil,
}

---@class DepthChargeBombWeapon1 : DefaultProjectileWeapon
DepthChargeBombWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.DepthChargeBombMuzzleFx,

    ---@param self DepthChargeBombWeapon1
    ---@param muzzle any # Unused
    ---@return table
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

---@class ConcussionBombWeapon : DefaultProjectileWeapon
ConcussionBombWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.ConcussionBombMuzzleFx,

    ---@param self ConcussionBombWeapon
    ---@return table
    GetDamageTable = function(self)
        local damageTable = DefaultProjectileWeapon.GetDamageTable(self)
        damageTable.NumFragments = self:GetBlueprint().NumFragments or 1
        damageTable.FragmentSpread = self:GetBlueprint().FragmentSpread or 1
        return damageTable
    end,
}

---@class EnergyBombWeapon : DefaultProjectileWeapon
EnergyBombWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.EnergyProjMuzzleFlash,

    ---@param self EnergyBombWeapon
    OnCreate = function(self)
        DefaultProjectileWeapon.OnCreate(self)
        local bp = self:GetBlueprint()
        if not bp.DoTPulses or not bp.DoTTime then
            WARN('EnergyCannon1: unit '..repr(self.unit.UnitId)..' does not have correct DoT values in blueprint!')
        end
    end,
}

---@class TorpedoWeapon1 : DefaultProjectileWeapon
TorpedoWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
        '/effects/emitters/torpedo_underwater_launch_01_emit.bp',
    },
}

---@class AntiTorpedoWeapon1 : DefaultProjectileWeapon
AntiTorpedoWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
        '/effects/emitters/torpedo_underwater_launch_01_emit.bp',
    },
}

---@class DroppedTorpedoWeapon1 : DefaultProjectileWeapon
DroppedTorpedoWeapon1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {'/effects/emitters/antiair_muzzle_fire_02_emit.bp',},
}

---@class AirToAirGun1 : DefaultProjectileWeapon
AirToAirGun1 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.DarkMatterAirWeaponMuzzleFlash,
}

---@class OrbitalStrikeBuoy : DefaultProjectileWeapon
OrbitalStrikeBuoy = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = NomadsEffectTemplate.TacticalMissileMuzzleFx,
}

---@class StrategicMissileWeapon : DefaultProjectileWeapon
StrategicMissileWeapon = Class(DefaultProjectileWeapon) {

    ---@param self StrategicMissileWeapon
    ---@param bone any 
    ---@return Projectile
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

---@class StrategicMissileDefenseWeapon : DefaultProjectileWeapon
StrategicMissileDefenseWeapon = Class(DefaultProjectileWeapon) {}

---@class DeathNuke : BareBonesWeapon
DeathNuke = Class(BareBonesWeapon) {

    ---@param self DeathNuke
    OnFire = function(self)
    end,

    ---@param self DeathNuke
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
        local brain = launcher:GetAIBrain()
        local damageType = bp.DamageType
        self.proj.InnerRing:DoNukeDamage(launcher, pos, brain, launcher.Army, damageType)
        self.proj.OuterRing:DoNukeDamage(launcher, pos, brain, launcher.Army, damageType)
    end,
}

---@class DeathEnergyBombWeapon : BareBonesWeapon
DeathEnergyBombWeapon = Class(BareBonesWeapon) {
    FiringMuzzleBones = {0}, -- just fire from the base bone of the unit

    ---@param self DeathEnergyBombWeapon
    OnCreate = function(self)
        BareBonesWeapon.OnCreate(self)
        local bp = self:GetBlueprint()
        self.Data = {
            EnergyBombFxScale = bp.EnergyBombFxScale or 1,
        }
        self:SetWeaponEnabled(false)
    end,

    ---@param self DeathEnergyBombWeapon
    OnFire = function(self)
    end,

    ---@param self DeathEnergyBombWeapon
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

---@class OrbitalGun : DefaultProjectileWeapon
OrbitalGun = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TIFArtilleryMuzzleFlash,
}