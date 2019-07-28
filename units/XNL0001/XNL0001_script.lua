-- Nomads ACU

local Entity = import('/lua/sim/Entity.lua').Entity
local Buff = import('/lua/sim/Buff.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Utilities = import('/lua/utilities.lua')
local NomadsEffectUtil = import('/lua/nomadseffectutilities.lua')

local NUtils = import('/lua/nomadsutils.lua')
local Utils = import('/lua/utilities.lua')
local CreateOrbitalUnit = NUtils.CreateOrbitalUnit
local AddRapidRepair = NUtils.AddRapidRepair
local AddRapidRepairToWeapon = NUtils.AddRapidRepairToWeapon
local AddCapacitorAbility = NUtils.AddCapacitorAbility
local AddCapacitorAbilityToWeapon = NUtils.AddCapacitorAbilityToWeapon

local NWeapons = import('/lua/nomadsweapons.lua')
local APCannon1 = NWeapons.APCannon1
local APCannon1_Overcharge = NWeapons.APCannon1_Overcharge
local DeathNuke = NWeapons.DeathNuke
local TacticalMissileWeapon2 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon2

APCannon1 = AddCapacitorAbilityToWeapon(APCannon1)
APCannon1_Overcharge = AddCapacitorAbilityToWeapon(APCannon1_Overcharge)

ACUUnit = AddCapacitorAbility(AddRapidRepair(import('/lua/defaultunits.lua').ACUUnit))

XNL0001 = Class(ACUUnit) {

    Weapons = {
        MainGun = Class(AddRapidRepairToWeapon(APCannon1)) {
            CreateProjectileAtMuzzle = function(self, muzzle)
                if self.unit.DoubleBarrels then
                    APCannon1.CreateProjectileAtMuzzle(self, 'Muzzle2')
                end
                return APCannon1.CreateProjectileAtMuzzle(self, muzzle)
            end,

            CapGetWepAffectingEnhancementBP = function(self)
                if self.unit:HasEnhancement('DoubleGuns') then
                    return self.unit:GetBlueprint().Enhancements['DoubleGuns']
                elseif self.unit:HasEnhancement('GunUpgrade') then
                    return self.unit:GetBlueprint().Enhancements['GunUpgrade']
                else
                    return {}
                end
            end,
        },

        AutoOverCharge = Class(AddRapidRepairToWeapon(APCannon1_Overcharge)) {
            PlayFxMuzzleSequence = function(self, muzzle)
                APCannon1_Overcharge.PlayFxMuzzleSequence(self, muzzle)

                -- create extra effect
                local bone = self:GetBlueprint().RackBones[1]['RackBone']
                for k, v in EffectTemplate.TCommanderOverchargeFlash01 do
                    CreateAttachedEmitter(self.unit, bone, self.unit:GetArmy(), v):ScaleEmitter(self.FxMuzzleFlashScale)
                end
            end,
        },

        OverCharge = Class(AddRapidRepairToWeapon(APCannon1_Overcharge)) {
            PlayFxMuzzleSequence = function(self, muzzle)
                APCannon1_Overcharge.PlayFxMuzzleSequence(self, muzzle)

                -- create extra effect
                local bone = self:GetBlueprint().RackBones[1]['RackBone']
                for k, v in EffectTemplate.TCommanderOverchargeFlash01 do
                    CreateAttachedEmitter(self.unit, bone, self.unit:GetArmy(), v):ScaleEmitter(self.FxMuzzleFlashScale)
                end
            end,
        },

        DeathWeapon = Class(DeathNuke) {},

        --TODO: Refactor this into the shield pointer weapons if possible
        TargetFinder = Class(TacticalMissileWeapon2) {
            FxMuzzleFlash = {},

            CreateProjectileAtMuzzle = function(self, muzzle)
            end,
        },
    },

    __init = function(self)
        ACUUnit.__init(self, 'MainGun')
    end,

    -- =====================================================================================================================
    -- CREATION AND FIRST SECONDS OF GAMEPLAY

    CapFxBones = { 'CapacitorL', 'CapacitorR', },

    OnCreate = function(self)
        ACUUnit.OnCreate(self)
        self.NukeEntity = 1 --leave a value for the death explosion entity to use later.
        
        --create capacitor sliders:
        self.CapSliders = {}
        table.insert(self.CapSliders, CreateSlider(self, 'CapacitorL'))
        table.insert(self.CapSliders, CreateSlider(self, 'CapacitorR'))
        for number,slider in self.CapSliders do
            slider:SetGoal(0, -1, 0 )
            slider:SetSpeed(1)
        end

        self:GetAIBrain().OrbitalBombardmentInitiator = self --TODO: fix this so that orbital bombard supports many units.

        local bp = self:GetBlueprint()

        -- vars
        self.DoubleBarrels = false
        self.DoubleBarrelOvercharge = false
        self.EnhancementBoneEffectsBag = {}
        self.BuildBones = bp.General.BuildBones.BuildEffectBones
        self.HeadRotationEnabled = false -- disable head rotation to prevent initial wrong rotation
        self.AllowHeadRotation = false
        self.UseRunWalkAnim = false

        -- model
        self:HideBone('IntelProbe1', true)
        self:HideBone('IntelProbe2', true)
        self:HideBone('Gun2', true)
        self:HideBone('PowerArmor', true)
        self:HideBone('Locomotion', true)
        self:HideBone('Orbital Bombardment', true)
        self:HideBone('BuildArm2', true)
        self:HideBone('BuildArm3', true)--these need to be updated in the other list as well, maybe add a function for this?

        self.HeadRotManip = CreateRotator(self, 'Head', 'y', nil):SetCurrentAngle(0)
        self.Trash:Add(self.HeadRotManip)

        -- properties
        self:SetCapturable(false)
        self:SetupBuildBones()

        -- enhancements
        self:RemoveToggleCap('RULEUTC_SpecialToggle')
        self:AddBuildRestriction( categories.NOMADS * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:SetRapidRepairParams( 'NomadsACURapidRepair', bp.Enhancements.RapidRepair.RepairDelay, bp.Enhancements.RapidRepair.InterruptRapidRepairByWeaponFired)

        self.Sync.Abilities = self:GetBlueprint().Abilities
        self:HasCapacitorAbility(false)
		
        self.MassProduction = bp.Economy.ProductionPerSecondMass
        self.EnergyProduction = bp.Economy.ProductionPerSecondEnergy
        self.RASMassProduction = bp.Enhancements.ResourceAllocation.ProductionPerSecondMass
        self.RASEnergyProduction = bp.Enhancements.ResourceAllocation.ProductionPerSecondEnergy
    end,



    OnStopBeingBuilt = function(self, builder, layer)
        ACUUnit.OnStopBeingBuilt(self, builder, layer)
        self:SetWeaponEnabledByLabel('MainGun', true)
        self:SetWeaponEnabledByLabel('TargetFinder', false)
        self:ForkThread(self.GiveInitialResources)
        self:ForkThread(self.HeadRotationThread)
        self.AllowHeadRotation = true
        self.PlayCommanderWarpInEffectFlag = nil
        --if the acu is spawned in, find an orbital unit that works.
        if not self.OrbitalUnit then
            local units = Utils.GetOwnUnitsInSphere(self:GetPosition(), 500, self:GetArmy(), categories.xno0001)
            if units[1] then
                self.OrbitalUnit = units[1]
            else
                self.OrbitalUnit = CreateOrbitalUnit(self)
            end
        end
    end,

    -- =====================================================================================================================
    -- UNIT DEATH

    OnKilled = function(self, instigator, type, overkillRatio)
        self:SetOrbitalBombardEnabled(false)
        self:SetIntelProbe(false)
        ACUUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    
    OnStartBuild = function(self, unitBeingBuilt, order)

       local bp = self:GetBlueprint()

        if order ~= 'Upgrade' or bp.Display.ShowBuildEffectsDuringUpgrade then

            -- If we are assisting an upgrading unit, or repairing a unit, play seperate effects
            local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
            if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom ~= 'none' and self:IsUnitState('Guarding')) or (order == 'Repair'  and self:IsUnitState('Guarding') and not unitBeingBuilt:IsBeingBuilt()) then
                self:ForkThread( NomadsEffectUtil.CreateRepairBuildBeams, unitBeingBuilt, self.BuildBones, self.BuildEffectsBag )
            else
                self:ForkThread( NomadsEffectUtil.CreateNomadsBuildSliceBeams, unitBeingBuilt, self.BuildBones, self.BuildEffectsBag )
            end
        end

        self:DoOnStartBuildCallbacks(unitBeingBuilt)
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('Construct')
        self:PlayUnitAmbientSound('ConstructLoop')
        if bp.General.UpgradesTo and unitBeingBuilt:GetUnitId() == bp.General.UpgradesTo and order == 'Upgrade' then
            unitBeingBuilt.DisallowCollisions = true
        end

        if unitBeingBuilt:GetBlueprint().Physics.FlattenSkirt and not unitBeingBuilt:HasTarmac() then
            if self.TarmacBag and self:HasTarmac() then
                unitBeingBuilt:CreateTarmac(true, true, true, self.TarmacBag.Orientation, self.TarmacBag.CurrentBP )
            else
                unitBeingBuilt:CreateTarmac(true, true, true, false, false)
            end
        end

        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
    end,

    --TODO: change this so it works for all relevant nomads units
    -- use our own reclaim animation
    CreateReclaimEffects = function( self, target )
        NomadsEffectUtil.PlayNomadsReclaimEffects( self, target, self:GetBlueprint().General.BuildBones.BuildEffectBones or {0,}, self.ReclaimEffectsBag )
    end,

    -- =====================================================================================================================
    -- GENERIC

    OnMotionHorzEventChange = function( self, new, old )
        if old == 'Stopped' and self.UseRunWalkAnim then
            local bp = self:GetBlueprint()
            if bp.Display.AnimationRun then
                if not self.Animator then
                    self.Animator = CreateAnimator(self, true)
                end
                self.Animator:PlayAnim(bp.Display.AnimationRun, true)
                self.Animator:SetRate(bp.Display.AnimationRunRate or 1)
            else
                ACUUnit.OnMotionHorzEventChange(self, new, old)
            end
        else
            ACUUnit.OnMotionHorzEventChange(self, new, old)
        end
    end,


    -- Adjust position of the capacitor sliders to match the charge.
    UpdateCapacitorFraction = function(self)
        ACUUnit.UpdateCapacitorFraction(self)
        for number,slider in self.CapSliders do
            slider:SetGoal(0, self.CapChargeFraction-1, 0 )
            slider:SetSpeed(1)
        end
    end,
        
    -- =====================================================================================================================
    -- EFFECTS AND ANIMATIONS

    -------- INITIAL ANIM --------

    DoMeteorAnim = function(self)  -- part of initial dropship animation
        if not self.OrbitalUnit then
            self.OrbitalUnit = CreateOrbitalUnit(self)
        end
        
        self.PlayCommanderWarpInEffectFlag = false
        self:HideBone(0, true)
        self:SetWeaponEnabledByLabel('MainGun', false)

        local meteor = self:CreateProjectile('/effects/Entities/NomadsACUDropMeteor/NomadsACUDropMeteor_proj.bp')
        self.Trash:Add(meteor)
        meteor:Start(self:GetPosition(), 3)

        WaitTicks(35) -- time before meteor opens --TODO: make this shorter, the same length as other ACU warp in animations

        self:ShowBone(0, true)
        self:HideBone('IntelProbe1', true)
        self:HideBone('IntelProbe2', true)
        self:HideBone('Gun2', true)
        self:HideBone('PowerArmor', true)
        self:HideBone('Locomotion', true)
        self:HideBone('Orbital Bombardment', true)
        self:HideBone('BuildArm2', true)
        self:HideBone('BuildArm3', true)--these need to be updated in the other list as well, maybe add a function for this?

        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end


        WaitTicks(5)

        -- TODO: play some kind of animation here?

        WaitTicks(12)  -- waiting till tick 50 to enable ACU. Same as other ACU's.

        self:SetWeaponEnabledByLabel('MainGun', true)
        self:SetUnSelectable(false)
        self:SetBusy(false)
        self:SetBlockCommandQueue(false)
    end,

    PlayCommanderWarpInEffect = function(self)  -- part of initial dropship animation
        self:SetUnSelectable(true)
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        self.PlayCommanderWarpInEffectFlag = true
        self:ForkThread(self.DoMeteorAnim)
    end,

    HeadRotationThread = function(self)
        -- keeps the head pointed at the current target (position)
        local nav = self:GetNavigator()
        local maxRot = self:GetBlueprint().Display.MovementEffects.HeadRotationMax or 10
        local wep = self:GetWeaponByLabel('MainGun')
        local GoalAngle = 0
        local target, torsoDir, torsoX, torsoY, torsoZ, MyPos

        while not self.Dead do

            -- don't rotate if we're not allowed to
            while not self.HeadRotationEnabled do
                WaitSeconds(0.2)
            end

            -- get a location of interest. This is the unit we're currently firing on or, alternatively, the position we're moving to
            target = wep:GetCurrentTarget()
            if target and target.GetPosition then
                target = target:GetPosition()
            else
                target = wep:GetCurrentTargetPos() or nav:GetCurrentTargetPos()
            end

            -- calculate the angle for the head rotation. The rotation of the torso is taken into account
            MyPos = self:GetPosition()
            target.y = 0
            target.x = target.x - MyPos.x
            target.z = target.z - MyPos.z
            target = Utilities.NormalizeVector(target)
            torsoX, torsoY, torsoZ = self:GetBoneDirection('Chest')
            torsoDir = Utilities.NormalizeVector( Vector( torsoX, 0, torsoZ) )
            GoalAngle = ( math.atan2( target.x, target.z ) - math.atan2( torsoDir.x, torsoDir.z ) ) * 180 / math.pi

            -- rotation limits, sometimes the angle is more than 180 degrees which causes a bad rotation.
            if GoalAngle > 180 then
                GoalAngle = GoalAngle - 360
            elseif GoalAngle < -180 then
                GoalAngle = GoalAngle + 360
            end
            GoalAngle = math.max( -maxRot, math.min( GoalAngle, maxRot ) )
            self.HeadRotManip:SetSpeed(60):SetGoal(GoalAngle)

            WaitSeconds(0.2)
        end
    end,

    AddEnhancementEmitterToBone = function(self, add, bone)

        -- destroy effect, if any
        if self.EnhancementBoneEffectsBag[ bone ] then
            self.EnhancementBoneEffectsBag[ bone ]:Destroy()
        end

        -- add the effect if desired
        if add then
            local emitBp = self:GetBlueprint().Display.EnhancementBoneEmitter
            local emit = CreateAttachedEmitter( self, bone, self:GetArmy(), emitBp )
            self.EnhancementBoneEffectsBag[ bone ] = emit
            self.Trash:Add( self.EnhancementBoneEffectsBag[ bone ] )
        end
    end,

    UpdateMovementEffectsOnMotionEventChange = function( self, new, old )
        self.HeadRotationEnabled = self.AllowHeadRotation
        ACUUnit.UpdateMovementEffectsOnMotionEventChange( self, new, old )
    end,

    -------- TRANSPORT ANIM --------
    OnStartTransportBeamUp = function(self, transport, bone)
        local slot = transport.slots[bone]
        if slot then
            self:GetAIBrain():OnTransportFull()
            IssueClearCommands({self})
            return
        end
        self:DestroyIdleEffects()
        self:DestroyMovementEffects()
        local army =  self:GetArmy()
        table.insert( self.TransportBeamEffectsBag, AttachBeamEntityToEntity(self, -1, transport, bone, army, EffectTemplate.TTransportBeam01))
        table.insert( self.TransportBeamEffectsBag, AttachBeamEntityToEntity( transport, bone, self, -1, army, EffectTemplate.TTransportBeam02))
        table.insert( self.TransportBeamEffectsBag, CreateEmitterAtBone( transport, bone, army, EffectTemplate.TTransportGlow01) )
        self:TransportAnimation(2)
    end,
    
    OnDetachedFromTransport = function(self, transport, bone)
        self:TransportAnimation(-0.95)
        self:MarkWeaponsOnTransport(false)
        self:EnableShield()
        self:EnableDefaultToggleCaps()
        self:DoUnitCallbacks( 'OnDetachedFromTransport', transport, bone)
    end,
    -- =====================================================================================================================
    -- ORBITAL ENHANCEMENTS

    SetOrbitalBombardEnabled = function(self, enable)
        local brain = self:GetAIBrain()
        brain:SetUnitSpecialAbility(self, 'NomadsAreaBombardment', {Enabled = (enable == true)})
        if enable then
            --self.OrbitalUnit:ReturnToStartLocation()
            self.OrbitalUnit:SetMovementTarget(self)
        else
            if not self:HasEnhancement( 'IntelProbe' ) and not self:HasEnhancement( 'IntelProbeAdv' ) then
                --self.OrbitalUnit:MoveAway()
                self.OrbitalUnit:SetMovementTarget(false)
            end
        end
    end,
    
    OrbitalStrikeTargets = function(self, targetPositions)
        -- TODO:Make the acu actually have ammo. Also check if removing ammo for every shot is sane, or if it should be per function call
        if self.OrbitalUnit then
            for _, location in targetPositions do
                if self:GetTacticalSiloAmmoCount() > 0 then
                    self:RemoveTacticalSiloAmmo(1)
                    self.OrbitalUnit:OnGivenNewTarget(location)
                else
                    WARN('Nomads: Ordered Orbital Bombardment ability on unit with no ammo in storage - aborting launch.')
                end
            end
        end
    end,
    
    --accepts false or nil to remove, but sending false is preferred, more clear code that way
    SetIntelProbe = function(self, condition)
        local brain = self:GetAIBrain()
        brain:SetUnitSpecialAbility(self, 'NomadsIntelProbeAdvanced', {Enabled = ('IntelProbeAdv' == condition)})
        brain:SetUnitSpecialAbility(self, 'NomadsIntelProbe', {Enabled = ('IntelProbe' == condition)})
        if condition then
            --self.OrbitalUnit:ReturnToStartLocation()
            self.OrbitalUnit:SetMovementTarget(self)
        elseif not self:HasEnhancement( 'OrbitalBombardment' ) then
            --self.OrbitalUnit:MoveAway()
            self.OrbitalUnit:SetMovementTarget(false)
        end
    end,
    
    RequestProbe = function(self, location, projBp, data)
        if self.OrbitalUnit then
            self.OrbitalUnit:LaunchProbe(location, projBp, data)
        else
            WARN('WARN:tried to launch probe without orbital unit, aborting.')
        end
    end,

    -- =====================================================================================================================
    -- ENHANCEMENTS

    --a much more sensible way of doing enhancements, and more moddable too!
    --change the behaviours here and dont touch the CreateEnhancement table.
    --call with: self.EnhancementBehaviours[enh](self, bp)
    -- EnhancementTable = {
        -- IntelProbe = function(self, bp)
            -- self:AddEnhancementEmitterToBone( true, 'IntelProbe1' )
            -- self:SetIntelProbe( 'IntelProbe' )
        -- end,
    -- },
    EnhancementBehaviours = {
        IntelProbe = function(self, bp)
            self:AddEnhancementEmitterToBone( true, 'IntelProbe1' )
            self:SetIntelProbe( 'IntelProbe' )
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 60)
        end,
        
        IntelProbeRemove = function(self, bp)
            self:AddEnhancementEmitterToBone( false, 'IntelProbe1' )
            self:SetIntelProbe(false)
            self:SetIntelRadius('Omni', bp.OmniRadius or 26)
        end,
        
        IntelProbeAdv = function(self, bp)
--            self:AddEnhancementEmitterToBone( true, 'IntelProbe1' )
            self:SetIntelProbe( 'IntelProbeAdv' )
            self:SetIntelRadius('Omni', bp.AdvOmniRadius or 100)
        end,
        
        IntelProbeAdvRemove = function(self, bp)
            self:AddEnhancementEmitterToBone( false, 'IntelProbe1' )
            self:SetIntelProbe(false)
            self:SetIntelRadius('Omni', bp.OmniRadius or 26)
        end,
        
        GunUpgrade = function(self, bp)
            local wep = self:GetWeaponByLabel('MainGun')
            local wbp = wep:GetBlueprint()
            
            -- adjust main gun
            wep:AddDamageRadiusMod(bp.NewDamageRadius or 3)
            wep:ChangeMaxRadius(bp.NewMaxRadius or wbp.MaxRadius)

            -- adjust overcharge gun
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius( bp.NewMaxRadius or wbp.MaxRadius )
            local oca = self:GetWeaponByLabel('AutoOverCharge')
            oca:ChangeMaxRadius( bp.NewMaxRadius or wbp.MaxRadius )
        end,
        
        GunUpgradeRemove = function(self, bp)
            -- adjust main gun
            local ubp = self:GetBlueprint()
            local wep = self:GetWeaponByLabel('MainGun')
            local wbp = wep:GetBlueprint()
            wep:AddDamageRadiusMod(-ubp.Enhancements['GunUpgrade'].NewDamageRadius)
            wep:ChangeMaxRadius(wbp.MaxRadius)

            -- adjust overcharge gun
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius( wbp.MaxRadius )
            local oca = self:GetWeaponByLabel('AutoOverCharge')
            oca:ChangeMaxRadius( bp.NewMaxRadius or wbp.MaxRadius )
        end,
        
        DoubleGuns = function(self, bp)
            -- this one should not change weapon damage, range, etc. The weapon script can't cope with that.
            self.DoubleBarrels = true
            self.DoubleBarrelOvercharge = bp.OverchargeIncluded
        end,
        
        DoubleGunsRemove = function(self, bp)
            self.DoubleBarrels = false
            self.DoubleBarrelOvercharge = false

            -- adjust main gun
            local ubp = self:GetBlueprint()
            local wep = self:GetWeaponByLabel('MainGun')
            local wbp = wep:GetBlueprint()
            wep:AddDamageRadiusMod(-ubp.Enhancements['GunUpgrade'].NewDamageRadius)
            wep:ChangeMaxRadius(wbp.MaxRadius)

            -- adjust overcharge gun
            local oc = self:GetWeaponByLabel('OverCharge')
            oc:ChangeMaxRadius( wbp.MaxRadius )
            local oca = self:GetWeaponByLabel('AutoOverCharge')
            oca:ChangeMaxRadius( bp.NewMaxRadius or wbp.MaxRadius )
        end,
        
        MovementSpeedIncrease = function(self, bp)
            self:SetSpeedMult( bp.SpeedMulti or 1.1 )
            self.UseRunWalkAnim = true
        end,
        
        MovementSpeedIncreaseRemove = function(self, bp)
            self:SetSpeedMult( 1 )
            self.UseRunWalkAnim = false
        end,
        
        Capacitor = function(self, bp)
            self:HasCapacitorAbility(true)
        end,
        
        CapacitorRemove = function(self, bp)
            self:ResetCapacitor()
            self:HasCapacitorAbility(false)
        end,
        
        ResourceAllocation = function(self, bp)
            self:AddToggleCap('RULEUTC_ProductionToggle')
            self:SetProductionPerSecondEnergy(self.RASEnergyProduction)
            self:SetScriptBit('RULEUTC_ProductionToggle', false)
        end,
        
        ResourceAllocationRemove = function(self, bp)
            self:SetScriptBit('RULEUTC_ProductionToggle', true)
            self:RemoveToggleCap('RULEUTC_ProductionToggle')
            self:SetProductionPerSecondEnergy(20)
            self:SetProductionPerSecondMass(1)
        end,
        
        RapidRepair = function(self, bp)
            if not Buffs['NomadsACURapidRepair'] then
                BuffBlueprint {
                    Name = 'NomadsACURapidRepair',
                    DisplayName = 'NomadsACURapidRepair',
                    BuffType = 'NOMADSACURAPIDREPAIRREGEN',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = bp.RepairRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            if not Buffs['NomadsACURapidRepairPermanentHPboost'] and bp.AddHealth > 0 then
                BuffBlueprint {
                    Name = 'NomadsACURapidRepairPermanentHPboost',
                    DisplayName = 'NomadsACURapidRepairPermanentHPboost',
                    BuffType = 'NOMADSACURAPIDREPAIRREGENPERMHPBOOST',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                           Add = bp.AddHealth,
                           Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.AddRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            if bp.AddHealth > 0 then
                Buff.ApplyBuff(self, 'NomadsACURapidRepairPermanentHPboost')
            end
            self:EnableRapidRepair(true)
        end,
        
        RapidRepairRemove = function(self, bp)
            -- keep in sync with same code in PowerArmorRemove
            self:EnableRapidRepair(false)
            if Buff.HasBuff( self, 'NomadsACURapidRepairPermanentHPboost' ) then
                Buff.RemoveBuff( self, 'NomadsACURapidRepair' )
                Buff.RemoveBuff( self, 'NomadsACURapidRepairPermanentHPboost' )
            end
        end,
        
        PowerArmor = function(self, bp)
            if not Buffs['NomadsACUPowerArmor'] then
               BuffBlueprint {
                    Name = 'NomadsACUPowerArmor',
                    DisplayName = 'NomadsACUPowerArmor',
                    BuffType = 'NACUUPGRADEHP',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.AddHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.AddRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            if Buff.HasBuff( self, 'NomadsACUPowerArmor' ) then
                Buff.RemoveBuff( self, 'NomadsACUPowerArmor' )
            end
            Buff.ApplyBuff(self, 'NomadsACUPowerArmor')

            if bp.Mesh then
                self:SetMesh( bp.Mesh, true)
            end
        end,
        
        PowerArmorRemove = function(self, bp)
            local ubp = self:GetBlueprint()
            if bp.Mesh then
                self:SetMesh( ubp.Display.MeshBlueprint, true)
            end
            if Buff.HasBuff( self, 'NomadsACUPowerArmor' ) then
                Buff.RemoveBuff( self, 'NomadsACUPowerArmor' )
            end

            -- keep in sync with same code above
            self:EnableRapidRepair(false)
            if Buff.HasBuff( self, 'NomadsACURapidRepairPermanentHPboost' ) then
                Buff.RemoveBuff( self, 'NomadsACURapidRepair' )
                Buff.RemoveBuff( self, 'NomadsACURapidRepairPermanentHPboost' )
            end
        end,
        
        AdvancedEngineering = function(self, bp)
            -- new build FX bone available
            table.insert( self.BuildBones, 'BuildBeam2' )

            -- make new structures available
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)

            -- add buff
            if not Buffs['NOMADSACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'NOMADSACUT2BuildRate',
                    DisplayName = 'NOMADSACUT2BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
                            Mult = 1,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end

            Buff.ApplyBuff(self, 'NOMADSACUT2BuildRate')
            self:updateBuildRestrictions()
        end,
        
        AdvancedEngineeringRemove = function(self, bp)
            -- remove extra build bone
            table.removeByValue( self.BuildBones, 'BuildBeam2' )

            -- buffs
            if Buff.HasBuff( self, 'NOMADSACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'NOMADSACUT2BuildRate' )
            end

            -- restore build restrictions
            self:RestoreBuildRestrictions()

            self:AddBuildRestriction( categories.NOMADS * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:updateBuildRestrictions()
        end,
        
        T3Engineering = function(self, bp)
            -- new build FX bone available
            table.insert( self.BuildBones, 'BuildBeam3' )
            -- make new structures available
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)

            -- add buff
            if not Buffs['NOMADSACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'NOMADSACUT3BuildRate',
                    DisplayName = 'NOMADSCUT3BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
                            Mult = 1,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'NOMADSACUT3BuildRate')
            self:updateBuildRestrictions()
        end,
        
        T3EngineeringRemove = function(self, bp)
            -- remove extra build bone
            table.removeByValue( self.BuildBones, 'BuildBeam3' )
            table.removeByValue( self.BuildBones, 'BuildBeam2' )
            -- remove buff
            if Buff.HasBuff( self, 'NOMADSACUT3BuildRate' ) then
                Buff.RemoveBuff( self, 'NOMADSACUT3BuildRate' )
            end

            -- reset build restrictions
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.NOMADS * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:updateBuildRestrictions()
        end,
        
        OrbitalBombardment = function(self, bp)
            self:SetOrbitalBombardEnabled(true)
            --self:AddCommandCap('RULEUCC_Tactical')
            self:AddEnhancementEmitterToBone( true, 'Orbital Bombardment' )
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TargetFinder', true)
        end,
        
        OrbitalBombardmentRemove = function(self, bp)
            self:SetOrbitalBombardEnabled(false)
            self:AddEnhancementEmitterToBone( false, 'Orbital Bombardment' )
            --self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TargetFinder', false)
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            self:StopSiloBuild()
        end,
        
        Generic = function(self, bp)
        end,
    },
    
    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

        if self.EnhancementBehaviours[enh] then
            self.EnhancementBehaviours[enh](self, bp)
        else
            WARN('Nomads: Enhancement '..repr(enh)..' has no script support.')
        end
    end,
    
    OnScriptBitSet = function(self, bit)
        if bit == 4 then -- Production toggle
            self:SetProductionPerSecondMass(self.RASMassProduction)
            self:SetProductionPerSecondEnergy(self.EnergyProduction)
        else
            ACUUnit.OnScriptBitSet(self, bit)
        end
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 4 then -- Production toggle
            self:SetProductionPerSecondMass(self.MassProduction)
            self:SetProductionPerSecondEnergy(self.RASEnergyProduction)
        else
            ACUUnit.OnScriptBitClear(self, bit)
        end
    end,

}

TypeClass = XNL0001
