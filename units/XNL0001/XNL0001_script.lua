local Buff = import('/lua/sim/Buff.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Utilities = import('/lua/utilities.lua')
local NomadsEffectUtil = import('/lua/nomadseffectutilities.lua')
local NUtils = import('/lua/nomadsutils.lua')
local Utils = import('/lua/utilities.lua')
local NWeapons = import('/lua/nomadsweapons.lua')

local CreateOrbitalUnit = NUtils.CreateOrbitalUnit
local AddRapidRepair = NUtils.AddRapidRepair
local AddRapidRepairToWeapon = NUtils.AddRapidRepairToWeapon
local AddCapacitorAbility = NUtils.AddCapacitorAbility
local AddCapacitorAbilityToWeapon = NUtils.AddCapacitorAbilityToWeapon

local NIFTargetFinderWeapon = NWeapons.NIFTargetFinderWeapon
local APCannon1 = NWeapons.APCannon1
local APCannon1_Overcharge = NWeapons.APCannon1_Overcharge
local DeathNuke = NWeapons.DeathNuke

APCannon1 = AddCapacitorAbilityToWeapon(APCannon1)
APCannon1_Overcharge = AddCapacitorAbilityToWeapon(APCannon1_Overcharge)
ACUUnit = AddCapacitorAbility(AddRapidRepair(import('/lua/defaultunits.lua').ACUUnit))

--- Nomads ACU
---@class XNL0001 : ACUUnit
XNL0001 = Class(ACUUnit) {
    CapFxBones = { 'CapacitorL', 'CapacitorR', },

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
                    CreateAttachedEmitter(self.unit, bone, self.unit.Army, v):ScaleEmitter(self.FxMuzzleFlashScale)
                end
            end,
        },

        OverCharge = Class(AddRapidRepairToWeapon(APCannon1_Overcharge)) {
            PlayFxMuzzleSequence = function(self, muzzle)
                APCannon1_Overcharge.PlayFxMuzzleSequence(self, muzzle)

                -- create extra effect
                local bone = self:GetBlueprint().RackBones[1]['RackBone']
                for k, v in EffectTemplate.TCommanderOverchargeFlash01 do
                    CreateAttachedEmitter(self.unit, bone, self.unit.Army, v):ScaleEmitter(self.FxMuzzleFlashScale)
                end
            end,
        },

        DeathWeapon = Class(DeathNuke) {},
        TargetFinder = Class(NIFTargetFinderWeapon) {},
    },

    ---@param self XNL0001
    __init = function(self)
        ACUUnit.__init(self, 'MainGun')
    end,

    ---@param self XNL0001
    OnCreate = function(self)
        local bp = self.Blueprint

        ACUUnit.OnCreate(self)
        --if the acu is spawned in, find an orbital unit that works.
        self:GetOrbitalUnit()

        self.NukeEntity = 1 --leave a value for the death explosion entity to use later.

        --create capacitor sliders:
        self.CapSliders = {}
        table.insert(self.CapSliders, CreateSlider(self, 'CapacitorL'))
        table.insert(self.CapSliders, CreateSlider(self, 'CapacitorR'))
        for number,slider in self.CapSliders do
            slider:SetGoal(0, -1, 0 )
            slider:SetSpeed(1)
        end


        -- TODO: Remove once related change gets released in the game patch
        self.BuildEffectBones = bp.General.BuildBones.BuildEffectBones

        -- vars
        self.DoubleBarrels = false
        self.DoubleBarrelOvercharge = false
        self.EnhancementBoneEffectsBag = {}
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
        
        self.RapidRepairBonusArmL = 0 --one for each upgrade slot, letting us easily track upgrade changes.
        self.RapidRepairBonusArmR = 0 --one for each upgrade slot, letting us easily track upgrade changes.
        self.RapidRepairBonusBack = 0
        
        self.Sync.Abilities = bp.Abilities
        self.Sync.HasCapacitorAbility = false

        self.MassProduction = bp.Economy.ProductionPerSecondMass
        self.EnergyProduction = bp.Economy.ProductionPerSecondEnergy
        self.RASMassProductionLow = bp.Enhancements.ResourceAllocation.ProductionPerSecondMassLow
        self.RASEnergyProductionLow = bp.Enhancements.ResourceAllocation.ProductionPerSecondEnergyLow
        self.RASMassProductionHigh = bp.Enhancements.ResourceAllocation.ProductionPerSecondMassHigh
        self.RASEnergyProductionHigh = bp.Enhancements.ResourceAllocation.ProductionPerSecondEnergyHigh
        
    end,

    ---@param self XNL0001
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self, builder, layer)
        ACUUnit.OnStopBeingBuilt(self, builder, layer)
        self:SetWeaponEnabledByLabel('MainGun', true)
        self:SetWeaponEnabledByLabel('TargetFinder', false)
        self:ForkThread(self.GiveInitialResources)
        self:ForkThread(self.HeadRotationThread)
        self.AllowHeadRotation = true
    end,

    ---@param self XNL0001
    GetOrbitalUnit = function(self)
        if self.OrbitalUnit then return end

        --if the acu is spawned in, find an orbital unit that works and isnt already assigned to anything
        local units = Utils.GetOwnUnitsInSphere(self:GetPosition(), 500, self.Army, categories.xno0001)
        local availableUnit = false

        for _,unit in units do
            if not unit.AssignedUnit then 
                availableUnit = unit
                break
            end
        end

        if availableUnit then
            self.OrbitalUnit = availableUnit
        else
            self.OrbitalUnit = CreateOrbitalUnit(self)
        end

        --assign ourselves to the orbital unit so that other units dont try to grab it
        self.OrbitalUnit.AssignedUnit = self
    end,

    ---@param self XNL0001
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        self:SetOrbitalBombardEnabled(false)
        self:SetIntelProbe(false)
        if self.OrbitalUnit then self.OrbitalUnit.AssignedUnit = nil end
        ACUUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    ---@param self number
    ---@param unitBeingBuilt number
    ---@param order string # Unused
    CreateBuildEffects = function(self, unitBeingBuilt, order)
        NomadsEffectUtil.CreateNomadsBuildSliceBeams(self, unitBeingBuilt, self.BuildEffectBones, self.BuildEffectsBag)
    end,

    ---@param self XNL0001
    ---@param target Unit
    CreateReclaimEffects = function(self, target)
        NomadsEffectUtil.PlayNomadsReclaimEffects(self, target, self.BuildEffectBones, self.ReclaimEffectsBag)
    end,

    ---@param self XNL0001
    ---@param target Unit
    CreateReclaimEndEffects = function(self, target)
        NomadsEffectUtil.PlayNomadsReclaimEndEffects(self, target, self.ReclaimEffectsBag)
    end,

    ---@param self XNL0001
    ---@param new any
    ---@param old any
    OnMotionHorzEventChange = function( self, new, old )
        if old == 'Stopped' and self.UseRunWalkAnim then
            local bp = self.Blueprint
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
    ---@param self XNL0001
    UpdateCapacitorFraction = function(self)
        ACUUnit.UpdateCapacitorFraction(self)
        for number,slider in self.CapSliders do
            slider:SetGoal(0, self.CapChargeFraction-1, 0 )
            slider:SetSpeed(1)
        end
    end,

    ---@param self XNL0001
    DoMeteorAnim = function(self)  -- part of initial dropship animation
        if not self.OrbitalUnit then
            self.OrbitalUnit = CreateOrbitalUnit(self)
        end

        self.PlayCommanderWarpInEffectFlag = false
        self:HideBone(0, true)
        self:SetWeaponEnabledByLabel('MainGun', false)

        local meteor = self:CreateProjectile('/effects/Entities/NomadsACUDropMeteor/NomadsACUDropMeteor_proj.bp')
        self.Trash:Add(meteor)
        meteor:Start(self:GetPosition(), 2) 

        WaitTicks(23) -- Landing Animation

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
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self, bone, self.Army, v)
            end
        end


        WaitTicks(7)  -- Sync With Other ACUs

        self:SetWeaponEnabledByLabel('MainGun', true)
        self:SetUnSelectable(false)
        self:SetBusy(false)
        self:SetBlockCommandQueue(false)
    end,

    ---@param self XNL0001
    PlayCommanderWarpInEffect = function(self)  -- part of initial dropship animation
        self:SetUnSelectable(true)
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        self.PlayCommanderWarpInEffectFlag = true
        self:ForkThread(self.DoMeteorAnim)
    end,

    ---@param self XNL0001
    HeadRotationThread = function(self)
        -- keeps the head pointed at the current target (position)
        local nav = self:GetNavigator()
        local maxRot = self.Blueprint.Display.MovementEffects.HeadRotationMax or 10
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

    ---@param self XNL0001
    ---@param add any
    ---@param bone string
    AddEnhancementEmitterToBone = function(self, add, bone)

        -- destroy effect, if any
        if self.EnhancementBoneEffectsBag[ bone ] then
            self.EnhancementBoneEffectsBag[ bone ]:Destroy()
        end

        -- add the effect if desired
        if add then
            local emitBp = self:GetBlueprint().Display.EnhancementBoneEmitter
            local emit = CreateAttachedEmitter( self, bone, self.Army, emitBp )
            self.EnhancementBoneEffectsBag[ bone ] = emit
            self.Trash:Add( self.EnhancementBoneEffectsBag[ bone ] )
        end
    end,

    ---@param self XNL0001
    ---@param new any
    ---@param old any
    UpdateMovementEffectsOnMotionEventChange = function( self, new, old )
        self.HeadRotationEnabled = self.AllowHeadRotation
        ACUUnit.UpdateMovementEffectsOnMotionEventChange( self, new, old )
    end,

    ---@param self XNL0001
    ---@param targetPositions number
    OrbitalStrikeTargets = function(self, targetPositions)
        -- TODO:Make the acu actually have ammo. Also check if removing ammo for every shot is sane, or if it should be per function call
        local heavyBombardment = self:HasEnhancement( 'OrbitalBombardmentHeavy' )
        
        if self.OrbitalUnit then
            for _, location in targetPositions do
                if self:GetTacticalSiloAmmoCount() > 0 then
                    self:RemoveTacticalSiloAmmo(1)
                    self.OrbitalUnit:OnGivenNewTarget(location, heavyBombardment)
                else
                    WARN('Nomads: Ordered Orbital Bombardment ability on unit with no ammo in storage - aborting launch.')
                end
            end
        end
    end,

    ---@param self XNL0001
    ---@param condition any
    SetOrbitalBombardEnabled = function(self, condition)
        local brain = self:GetAIBrain()
        brain:SetUnitSpecialAbility(self, 'NomadsAreaBombardment', {Enabled = (true == condition)})
        if condition then
            self.OrbitalUnit:SetMovementTarget(self)
        else
            if not self:HasEnhancement( 'IntelProbe' ) and not self:HasEnhancement( 'IntelProbeAdv' ) then
                self.OrbitalUnit:SetMovementTarget(false)
            end
        end
    end,

    --accepts false or nil to remove, but sending false is preferred, more clear code that way
    ---@param self XNL0001
    ---@param condition any
    SetIntelProbe = function(self, condition)
        local brain = self:GetAIBrain()
        brain:SetUnitSpecialAbility(self, 'NomadsIntelProbeAdvanced', {Enabled = ('IntelProbeAdv' == condition)})
        brain:SetUnitSpecialAbility(self, 'NomadsIntelProbe', {Enabled = ('IntelProbe' == condition)})
        if condition then
            self.OrbitalUnit:SetMovementTarget(self)
        elseif not self:HasEnhancement( 'OrbitalBombardment' ) and not self:HasEnhancement( 'OrbitalBombardmentHeavy' ) then
            self.OrbitalUnit:SetMovementTarget(false)
        end
    end,

    ---@param self XNL0001
    ---@param location number
    ---@param probeType string
    ---@param data any
    RequestProbe = function(self, location, probeType, data)
        if self.OrbitalUnit then
            if not self.IntelProbeEntity or self.IntelProbeEntity:BeenDestroyed() then
                self.IntelProbeEntity = self.OrbitalUnit:LaunchProbe(location, probeType, data)
            else
                WARN('Nomads: tried to create a duplicate intel probe, skipping creation')
            end
            
            self:ForkThread(self.ProbeCooldownThread, data.CoolDownTime)
        else
            WARN('WARN:Nomads: tried to launch intel probe without orbital unit, aborting.')
        end
    end,

    ---@param self XNL0001
    ---@param duration number
    ProbeCooldownThread = function(self, duration)
        self:SetSpecialAbilityAvailability('NomadsIntelProbe', 0)
        self:SetSpecialAbilityAvailability('NomadsIntelProbeAdvanced', 0)
        
        for i = 0,duration,0.1 do
            if self:BeenDestroyed() or self.Dead then break end
            self:SetWorkProgress(i / duration)
            WaitSeconds(0.1)
        end
        
        self:SetSpecialAbilityAvailability('NomadsIntelProbe', 1)
        self:SetSpecialAbilityAvailability('NomadsIntelProbeAdvanced', 1)
    end,

    --- Rapid Repair
    --- The repair has a delay which is reset by taking damage and by firing certain weapons.
    --- This custom timer function allows us to reset or partially delay the timer without killing the thread
    --- - The RR thread ticks down until the timer reaches 0 when the timer reaches 0 the repair starts, which applies the buff.
    --- - The buff is calculated on the fly and applied when rapid repair is interrupted, the timer is reset and the buff is removed.
    ---@param self XNL0001
    StartRapidRepair = function(self)
        local bp = self.Blueprint
        --calculate the total bonus - each upgrade slot can have its own bonus added.
        self.RapidRepairBonus = bp.Defense.RapidRepairBonus + self.RapidRepairBonusArmL + self.RapidRepairBonusArmR + self.RapidRepairBonusBack
        
        self:SetRapidRepairAmount(self.RapidRepairBonus)

        -- start self repair effects
        self.RapidRepairFxBag:Add( ForkThread( NomadsEffectUtil.CreateSelfRepairEffects, self, self.RapidRepairFxBag ) )

        -- wait until full health, or interrupted
        while not self.Dead and self:GetHealth() < self:GetMaxHealth() and self.RapidRepairCooldownTime <= 0 do
            WaitTicks(1)
        end
        self.RapidRepairFxBag:Destroy()
    end,

    --General note: Nomads ACU has capacitor, which uses buffs. So acu upgrades must use buffs so they stack with capacitor correctly.
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
            
            -- add buff
            if not Buffs['NomadsACUIntelProbe'] then
                BuffBlueprint {
                    Name = 'NomadsACUIntelProbe',
                    DisplayName = 'NomadsACUIntelProbe',
                    BuffType = 'PROBEINTEL',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        OmniRadius = {
                            Add = bp.NewOmniRadius or 34,
                        },
                    },
                }
            end

            Buff.ApplyBuff(self, 'NomadsACUIntelProbe')
            self.Sync.HasIntelProbeAbility = true
        end,

        IntelProbeRemove = function(self, bp)
            self:AddEnhancementEmitterToBone( false, 'IntelProbe1' )
            self:SetIntelProbe(false)
            Buff.RemoveBuff( self, 'NomadsACUIntelProbe' )
            self.Sync.HasIntelProbeAbility = false
        end,

        IntelProbeAdv = function(self, bp)
            --self:AddEnhancementEmitterToBone( true, 'IntelProbe1' )
            self:SetIntelProbe( 'IntelProbeAdv' )
            
            
            -- add buff
            if not Buffs['NomadsACUIntelProbeAdv'] then
                BuffBlueprint {
                    Name = 'NomadsACUIntelProbeAdv',
                    DisplayName = 'NomadsACUIntelProbeAdv',
                    BuffType = 'PROBEINTEL',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        OmniRadius = {
                            Add = bp.AdvOmniRadius or 74,
                        },
                    },
                }
            end

            Buff.ApplyBuff(self, 'NomadsACUIntelProbeAdv')
            
            self.Sync.HasIntelProbeAbility = false
            self.Sync.HasIntelProbeAdvancedAbility = true
        end,

        IntelProbeAdvRemove = function(self, bp)
            self:AddEnhancementEmitterToBone( false, 'IntelProbe1' )
            self:SetIntelProbe(false)
            Buff.RemoveBuff( self, 'NomadsACUIntelProbeAdv' )
            self.Sync.HasIntelProbeAdvancedAbility = false
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
            self.Sync.HasCapacitorAbility = true
        end,
        
        CapacitorRemove = function(self, bp)
            self:ResetCapacitor()
            self.Sync.HasCapacitorAbility = false
        end,
        
        ResourceAllocation = function(self, bp)
            self:AddToggleCap('RULEUTC_ProductionToggle')
            self:SetProductionPerSecondEnergy(self.RASEnergyProductionLow)
            self:SetProductionPerSecondMass(self.RASMassProductionHigh)
            self:SetScriptBit('RULEUTC_ProductionToggle', false)
        end,
        
        ResourceAllocationRemove = function(self, bp)
            self:SetScriptBit('RULEUTC_ProductionToggle', true)
            self:RemoveToggleCap('RULEUTC_ProductionToggle')
            self:SetProductionPerSecondEnergy(self.EnergyProduction)
            self:SetProductionPerSecondMass(self.MassProduction)
        end,
        
        RapidRepair = function(self, bp)
            self.RapidRepairBonusBack = bp.BonusRepairRate
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
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
        end,
        
        RapidRepairRemove = function(self, bp)
            self.RapidRepairBonusBack = 0
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
            -- keep in sync with same code in PowerArmorRemove
            if Buff.HasBuff( self, 'NomadsACURapidRepairPermanentHPboost' ) then
                Buff.RemoveBuff( self, 'NomadsACURapidRepairPermanentHPboost' )
            end
        end,
        
        PowerArmor = function(self, bp)
            self.RapidRepairBonusBack = bp.BonusRepairRate
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
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
            self.RapidRepairBonusBack = 0
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
            local ubp = self:GetBlueprint()
            if bp.Mesh then
                self:SetMesh( ubp.Display.MeshBlueprint, true)
            end
            if Buff.HasBuff( self, 'NomadsACUPowerArmor' ) then
                Buff.RemoveBuff( self, 'NomadsACUPowerArmor' )
            end

            if Buff.HasBuff( self, 'NomadsACURapidRepairPermanentHPboost' ) then
                Buff.RemoveBuff( self, 'NomadsACURapidRepairPermanentHPboost' )
            end
        end,
        
        AdvancedEngineering = function(self, bp)
            self.RapidRepairBonusArmL = bp.BonusRepairRate
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
            -- new build FX bone available
            table.insert(self.BuildEffectBones, 'BuildBeam2')

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
            self:UpdateBuildRestrictions()
        end,
        
        AdvancedEngineeringRemove = function(self, bp)
            self.RapidRepairBonusArmL = 0
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
            -- remove extra build bone
            table.removeByValue(self.BuildEffectBones, 'BuildBeam2')

            -- buffs
            if Buff.HasBuff( self, 'NOMADSACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'NOMADSACUT2BuildRate' )
            end

            -- restore build restrictions
            self:RestoreBuildRestrictions()

            self:AddBuildRestriction( categories.NOMADS * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:UpdateBuildRestrictions()
        end,
        
        T3Engineering = function(self, bp)
            self.RapidRepairBonusArmL = bp.BonusRepairRate
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
            -- new build FX bone available
            table.insert(self.BuildEffectBones, 'BuildBeam3')
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
            self:UpdateBuildRestrictions()
        end,
        
        T3EngineeringRemove = function(self, bp)
            self.RapidRepairBonusArmL = 0
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
            -- remove extra build bone
            table.removeByValue(self.BuildEffectBones, 'BuildBeam3')
            table.removeByValue(self.BuildEffectBones, 'BuildBeam2')
            -- remove buff
            if Buff.HasBuff( self, 'NOMADSACUT3BuildRate' ) then
                Buff.RemoveBuff( self, 'NOMADSACUT3BuildRate' )
            end

            -- reset build restrictions
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.NOMADS * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:UpdateBuildRestrictions()
        end,
        
        OrbitalBombardment = function(self, bp)
            self:SetOrbitalBombardEnabled(true)
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddEnhancementEmitterToBone( true, 'Orbital Bombardment' )
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TargetFinder', true)
        end,
        
        OrbitalBombardmentRemove = function(self, bp)
            self:SetOrbitalBombardEnabled(false)
            self:AddEnhancementEmitterToBone( false, 'Orbital Bombardment' )
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TargetFinder', false)
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            self:StopSiloBuild()
        end,
        
        OrbitalBombardmentHeavy = function(self, bp)
            self:SetOrbitalBombardEnabled(true)
            self:AddEnhancementEmitterToBone( true, 'Orbital Bombardment' )
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TargetFinder', true)
            self:GetWeaponByLabel('TargetFinder'):ChangeProjectileBlueprint('/projectiles/NIFOrbitalMissile02/NIFOrbitalMissile02_proj.bp')
        end,
        
        OrbitalBombardmentHeavyRemove = function(self, bp)
            self:SetOrbitalBombardEnabled(false)
            self:AddEnhancementEmitterToBone( false, 'Orbital Bombardment' )
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('TargetFinder', false)
            self:GetWeaponByLabel('TargetFinder'):ChangeProjectileBlueprint('/projectiles/NIFOrbitalMissile01/NIFOrbitalMissile01_proj.bp')
            local amt = self:GetTacticalSiloAmmoCount()
            self:RemoveTacticalSiloAmmo(amt or 0)
            self:StopSiloBuild()
        end,
        
        Generic = function(self, bp)
        end,
    },

    ---@param self XNL0001
    ---@param enh string
    CreateEnhancement = function(self, enh)
        ACUUnit.CreateEnhancement(self, enh)
        local bp = self.Blueprint.Enhancements[enh]
        if not bp then return end

        if self.EnhancementBehaviours[enh] then
            self.EnhancementBehaviours[enh](self, bp)
        else
            WARN('Nomads: Enhancement '..repr(enh)..' has no script support.')
        end
    end,

    ---@param self XNL0001
    ---@param bit number
    OnScriptBitSet = function(self, bit)
        if bit == 4 then -- Production toggle
            self:SetProductionPerSecondMass(self.RASMassProductionLow)
            self:SetProductionPerSecondEnergy(self.RASEnergyProductionHigh)
        else
            ACUUnit.OnScriptBitSet(self, bit)
        end
    end,

    ---@param self XNL0001
    ---@param bit number
    OnScriptBitClear = function(self, bit)
        if bit == 4 then -- Production toggle
            self:SetProductionPerSecondMass(self.RASMassProductionHigh)
            self:SetProductionPerSecondEnergy(self.RASEnergyProductionLow)
        else
            ACUUnit.OnScriptBitClear(self, bit)
        end
    end,
}
TypeClass = XNL0001

--#region Backwards Compatibility
local Entity = import('/lua/sim/Entity.lua').Entity
--ACUUnit = AddCapacitorAbility(import('/lua/defaultunits.lua').ACUUnit)
--#endregion