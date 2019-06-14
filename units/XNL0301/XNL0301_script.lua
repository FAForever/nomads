-- Nomads SACU

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NomadsEffectUtil = import('/lua/nomadseffectutilities.lua')
local Utilities = import('/lua/utilities.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair
local AddRapidRepairToWeapon = import('/lua/nomadsutils.lua').AddRapidRepairToWeapon
local AddCapacitorAbility = import('/lua/nomadsutils.lua').AddCapacitorAbility
local AddCapacitorAbilityToWeapon = import('/lua/nomadsutils.lua').AddCapacitorAbilityToWeapon
local AddAkimbo = import('/lua/nomadsutils.lua').AddAkimbo

local NWalkingLandUnit = import('/lua/nomadsunits.lua').NWalkingLandUnit

local APCannon1 = import('/lua/nomadsweapons.lua').APCannon1
local GattlingWeapon1 = import('/lua/nomadsweapons.lua').GattlingWeapon1
local UnderwaterRailgunWeapon1 = import('/lua/nomadsweapons.lua').UnderwaterRailgunWeapon1
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon4
local DeathEnergyBombWeapon = import('/lua/nomadsweapons.lua').DeathEnergyBombWeapon

NWalkingLandUnit = AddAkimbo(AddCapacitorAbility(AddRapidRepair(NWalkingLandUnit)))
APCannon1 = AddCapacitorAbilityToWeapon(APCannon1)
GattlingWeapon1 = AddCapacitorAbilityToWeapon(GattlingWeapon1)
UnderwaterRailgunWeapon1 = AddCapacitorAbilityToWeapon(UnderwaterRailgunWeapon1)
RocketWeapon1 = AddCapacitorAbilityToWeapon(RocketWeapon1)


XNL0301 = Class(NWalkingLandUnit) {

    Weapons = {
        GunLeft = Class(AddRapidRepairToWeapon(APCannon1)) {

            OnCreate = function(self)
                APCannon1.OnCreate(self)
                self.MuzzleOverride_1B = false
            end,

            SetMuzzleOverride = function(self, ForceOneBarrel)
                if ForceOneBarrel ~= nil then
                    self.MuzzleOverride_1B = (ForceOneBarrel == true)
                end
            end,

            -- 2 functions below: a quick way (hack) to fire from the correct weapons/bones, but not the best way...
            CreateProjectileAtMuzzle = function(self, muzzle)
                if self.MuzzleOverride_1B then
                    muzzle = 'MGun_Recoil'
                end
                APCannon1.CreateProjectileAtMuzzle(self, muzzle)
            end,

            PlayRackRecoil = function(self, rackList)
                if self.MuzzleOverride_1B then
                    local bp = self:GetBlueprint()
                    rackList = { bp.RackBones[1], }
                end
                APCannon1.PlayRackRecoil(self, rackList)
            end,

            CapGetWepAffectingEnhancementBP = function(self)
                if self.unit:HasEnhancement('GunLeftUpgrade') then
                    return self.unit:GetBlueprint().Enhancements['GunLeftUpgrade']
                else
                    return {}
                end
            end,

            SetEnabled = function(self, enable)
                -- disabling the main gun also disables the gattling, this works better
                self._IsEnabled = (enable == true)
                self:AimManipulatorSetEnabled(self._IsEnabled)
                self:UpdateMaxRadius()
            end,

            UpdateMaxRadius = function(self)
                -- the max radius when disabled should be that of the longest range weapon. Otherwise the unit
                -- will walk up to the target and not attack from range, exposing it unnecessarily. This is an
                -- issue with rocket and railgun enhancements
                if self:IsEnabled() then
                    self:ChangeMaxRadius(self:GetMaxRadius(), true)
                else
                    self:ChangeMaxRadius(self.unit:GetAllWeaponMaxRadius(), true)
                end
            end,

            ChangeMaxRadius = function(self, val, ignore)
                -- added ignore flag to not update the internally used MaxRadius value, we'll need this when
                -- changing range while disabled (see above).
                if ignore then
                    local before = self._MaxRadius
                    APCannon1.ChangeMaxRadius(self, val)
                    self._MaxRadius = before
                else
                    APCannon1.ChangeMaxRadius(self, val)
                end
            end,
        },
        GunRight = Class(AddRapidRepairToWeapon(GattlingWeapon1)) {

            CapGetWepAffectingEnhancementBP = function(self)
                if self.unit:HasEnhancement('GunRightUpgrade') then
                    return self.unit:GetBlueprint().Enhancements['GunRightUpgrade']
                else
                    return {}
                end
            end,
        },
        RocketRight = Class(AddRapidRepairToWeapon(RocketWeapon1)) {},
        RocketLeft = Class(AddRapidRepairToWeapon(RocketWeapon1)) {},
        RailGun = Class(AddRapidRepairToWeapon(UnderwaterRailgunWeapon1)) {},
        RASDeathWeapon = Class(DeathEnergyBombWeapon) {},
    },

    CapFxBones = { [1] = 'Torso', [2] = 'Torso', },
    CapFxBonesOffsets = { [1] = { 0.14, 0.52, 0, }, [2] = { -0.14, 0.52, 0, }, },
    DestructionPartsLowToss = { 'Torso', 'Head', },

    OnCreate = function(self)
        NWalkingLandUnit.OnCreate(self)

        local bp = self:GetBlueprint()

        self.HeadRotationEnabled = false -- initially disable head rotation to prevent initial wrong rotation

        self:SetCapturable(false)
        self:SetupBuildBones()

        -- enhancement related
        self:RemoveToggleCap('RULEUTC_SpecialToggle')
        self:SetWeaponEnabledByLabel( 'RocketRight', false )
        self:SetWeaponEnabledByLabel( 'RocketLeft', false )
        self:SetWeaponEnabledByLabel( 'RailGun', false )
        self:SetWeaponEnabledByLabel( 'GunRight', false )
        self:SetWeaponEnabledByLabel( 'GunLeft', false )
        self:GetWeaponByLabel('GunLeft'):SetMuzzleOverride(true)
        self:RemoveCommandCap('RULEUCC_Attack')
        self:RemoveCommandCap('RULEUCC_RetaliateToggle')
        self.HasLeftArm = false
        self.HasRightArm = false
        self:SetRapidRepairParams( 'NomadsSCURapidRepair', bp.Enhancements.RapidRepair.RepairDelay, bp.Enhancements.RapidRepair.InterruptRapidRepairByWeaponFired)
    
        self.Sync.Abilities = self:GetBlueprint().Abilities
        self:HasCapacitorAbility(false)
    end,

    OnStartBeingBuilt = function(self, builder, layer)
        NWalkingLandUnit.OnStartBeingBuilt(self, builder, layer)

        local bp = self:GetBlueprint()
        if bp.Display.AnimationAlert then
            self.AlertAnimManip = CreateAnimator(self):PlayAnim(bp.Display.AnimationAlert):SetRate(0)
            self.AlertAnimManip:SetAnimationFraction(0)
            self.Trash:Add( self.AlertAnimManip )
        end
    end,

    StopBeingBuiltEffects = function(self, builder, layer)
        NWalkingLandUnit.StopBeingBuiltEffects(self, builder, layer)

        if self:HasEnhancement('PowerArmor') then
            local bp = self:GetBlueprint().Enhancements['PowerArmor']
            self:SetMesh( bp.Mesh, true)
        end
        if self.AlertAnimManip then
            self.AlertAnimManip:SetRate(1)
            WaitFor(self.AlertAnimManip)
        end
    end,

    SetWeaponEnabledByLabel = function(self, label, bool)
        NWalkingLandUnit.SetWeaponEnabledByLabel(self, label, bool)
        if label ~= 'GunLeft' then
            self:GetWeaponByLabel('GunLeft'):UpdateMaxRadius()  -- keep primary weapon range correct
        end
    end,

    GetAllWeaponMaxRadius = function(self)
        -- returns the biggest max radius of any weapon that's currently enabled
        local wep, rad
        local maxRad = 1
        local n = self:GetWeaponCount()
        for i=1, n do
            wep = self:GetWeapon(i)
            if wep and wep:IsEnabled() then
                rad = wep:GetMaxRadius()
                if rad > maxRad then
                    maxRad = rad
                end
            end
        end
        return maxRad
    end,

    -- =====================================================================================================================
    -- UNIT DEATH

    OnKilled = function(self, instigator, type, overkillRatio)
        local brain = self:GetAIBrain()
        brain:RemoveSpecialAbilityUnit(self, 'NomadsAreaBombardment')
        NWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnDestroy = function(self)
        local brain = self:GetAIBrain()
        brain:RemoveSpecialAbilityUnit(self, 'NomadsAreaBombardment')
        NWalkingLandUnit.OnDestroy(self)
    end,

    DoDeathWeapon = function(self)
        if self:IsBeingBuilt() then return end

        local DeathWep = self:GetDeathWeaponBP()
        if DeathWep.FireOnDeath == true then
            self:SetWeaponEnabledByLabel(DeathWep.Label, true)
            self:GetWeaponByLabel(DeathWep.Label):Fire()
        else
            self:ForkThread(self.DeathWeaponDamageThread, DeathWep.DamageRadius, DeathWep.Damage, DeathWep.DamageType, DeathWep.DamageFriendly)
        end
    end,

    CreateWreckage = function(self, overkillRatio)
        -- only create wreckage if death weapon allows it
        local DeathWep = self:GetDeathWeaponBP()
        if not DeathWep.NoWreckage then
            NWalkingLandUnit.CreateWreckage(self, overkillRatio)
        end
    end,

    GetDeathWeaponBP = function(self)
        -- different death weapon depending on enhancements
        local WantLabel = 'DeathWeapon'
        local bp = self:GetBlueprint()

        if self:HasEnhancement('ResourceAllocation') then
            WantLabel = bp.Enhancements.ResourceAllocation.NewDeathWeapon or WantLabel
        end

        for k, v in bp.Weapon do
            if v.Label == WantLabel then
                return table.deepcopy(v)
            end
        end
    end,

-- =================================================================================================================

    OnPrepareArmToBuild = function(self)
        NWalkingLandUnit.OnPrepareArmToBuild(self)
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:ForBuildEnableWeapons(false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('GunLeft'):GetHeadingPitch() )
    end,

    OnStopCapture = function(self, target)
        NWalkingLandUnit.OnStopCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:ForBuildEnableWeapons(true)
        self:GetWeaponManipulatorByLabel('GunLeft'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        NWalkingLandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:ForBuildEnableWeapons(true)
        self:GetWeaponManipulatorByLabel('GunLeft'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
        NWalkingLandUnit.OnStopReclaim(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:ForBuildEnableWeapons(true)
        self:GetWeaponManipulatorByLabel('GunLeft'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
        NWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        NWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
        self:ForBuildEnableWeapons(true)
        self:GetWeaponManipulatorByLabel('GunLeft'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedToBuild = function(self)
        NWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:ForBuildEnableWeapons(true)
        self:GetWeaponManipulatorByLabel('GunLeft'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        local bones = self:GetBuildBones() or {0}
        -- If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom ~= 'none' and self:IsUnitState('Guarding'))then
            NomadsEffectUtil.CreateRepairBuildBeams( self, unitBeingBuilt, bones, self.BuildEffectsBag )
        else
            NomadsEffectUtil.CreateNomadsBuildSliceBeams( self, unitBeingBuilt, bones, self.BuildEffectsBag )
        end
    end,

    CreateReclaimEffects = function( self, target )
        NomadsEffectUtil.PlayNomadsReclaimEffects( self, target, self:GetBlueprint().General.BuildBones.BuildEffectBones or {0,}, self.ReclaimEffectsBag )
    end,

    CreateReclaimEndEffects = function( self, target )
        NomadsEffectUtil.PlayNomadsReclaimEndEffects( self, target, self.ReclaimEffectsBag )
    end,

    CreateCaptureEffects = function( self, target )
        EffectUtil.PlayCaptureEffects( self, target, self:GetBuildBones() or {0,}, self.CaptureEffectsBag )
    end,

    OnPaused = function(self)
        NWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            NWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end
    end,

    OnUnpaused = function(self)
        if self.BuildingUnit then
            NWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        NWalkingLandUnit.OnUnpaused(self)
    end,

    ForBuildEnableWeapons = function(self, enable)
        self:SetWeaponEnabledByLabel('GunLeft', (enable and (self:HasEnhancement('GunLeft') or self:HasEnhancement('GunLeftUpgrade'))) )
        self:SetWeaponEnabledByLabel('GunRight', (enable and self:HasEnhancement('GunRight')) )
    end,

    GetBuildBones = function(self)
        -- a known engine limitation or bug where a single variable is used for all units of the same type is causing problems with the build bones.
        -- to remedy this I'm dynamically determining what bones to use by checking what enhancements are available.
        local bones = table.deepcopy( self:GetBlueprint().General.BuildBones.BuildEffectBones )
        if self:HasEnhancement('EngineeringRight') then
            table.insert( bones, 'Engi_R_Muzzle')
            table.insert( bones, 'Engi_R_Muzzle.001')
            table.insert( bones, 'Engi_R_Muzzle.002')
         end
        if self:HasEnhancement('EngineeringLeft') then
            table.insert( bones, 'Engi_L_Muzzle')
            table.insert( bones, 'Engi_L_Muzzle.001')
            table.insert( bones, 'Engi_L_Muzzle.002')
        end
        return bones
    end,

-- =================================================================================================================

    OnAttachedToTransport = function(self, transport, transportBone)
        -- disable head rotation. Coming of the transport, the head gets a weird rotation
        self.HeadRotationEnabled = false
        NWalkingLandUnit.OnAttachedToTransport(self, transport, transportBone)
    end,

    OnDetachedFromTransport = function(self, transport, transportBone)
        -- disable head rotation. Coming of the transport, the head gets a weird rotation
        self.HeadRotationEnabled = false
        NWalkingLandUnit.OnDetachedFromTransport(self, transport, transportBone)
    end,

    UpdateMovementEffectsOnMotionEventChange = function( self, new, old )
        self.HeadRotationEnabled = true
        NWalkingLandUnit.UpdateMovementEffectsOnMotionEventChange( self, new, old )
    end,

-- =================================================================================================================

    CanBeStunned = function(self)
        if self:HasEnhancement('PowerArmor') then
            return false
        end
        return NWalkingLandUnit.CanBeStunned(self)
    end,


    -- =====================================================================================================================
    -- ENHANCEMENTS


    --a much more sensible way of doing enhancements, and more moddable too!
    --change the behaviours here and dont touch the CreateEnhancement table.
    -- EnhancementTable = {
        -- IntelProbe = function(self, bp)
            -- self:AddEnhancementEmitterToBone( true, 'IntelProbe1' )
            -- self:SetIntelProbeEnabled( false, true )
        -- end,
    -- },
    EnhancementBehaviours = {
        GunLeft = function(self, bp)
            self:GetWeaponByLabel('GunLeft'):SetMuzzleOverride(true)
            if bp.EnableWeapon then
                self:SetWeaponEnabledByLabel( bp.EnableWeapon, true )
                self:AddCommandCap('RULEUCC_Attack')
                self:AddCommandCap('RULEUCC_RetaliateToggle')
            end
        end,
        
        GunLeftRemove = function(self, bp)
            local ubp = self:GetBlueprint()
            if ubp.Enhancements.GunLeft.EnableWeapon then
                self:SetWeaponEnabledByLabel( ubp.Enhancements.GunLeft.EnableWeapon, false )
                if not self:HasEnhancement('GunRight') and not self:HasEnhancement('GunRightUpgrade') and not self:HasEnhancement('RightRocket') then
                    self:RemoveCommandCap('RULEUCC_Attack')
                    self:RemoveCommandCap('RULEUCC_RetaliateToggle')
                end
            end
        end,
        
        GunLeftUpgrade = function(self, bp)
            local wep = self:GetWeaponByLabel('GunLeft')
            local wbp = wep:GetBlueprint()
            local rof = wbp.RateOfFire * (bp.RateOfFireMulti or 1)

            if bp.RateOfFireMulti then
                if not Buffs['NOMADSCULeftArmGunUpgrade'] then
                    BuffBlueprint {
                        Name = 'NOMADSCULeftArmGunUpgrade',
                        DisplayName = 'NOMADSCULeftArmGunUpgrade',
                        BuffType = 'SCUGUNUPGRADE',
                        Stacks = 'ADD',
                        Duration = -1,
                        Affects = {
                            RateOfFireSpecifiedWeapons = {
                                Mult = 1 / (bp.RateOfFireMulti or 1), -- here a value of 0.5 is actually doubling ROF
                            },
                        },
                    }
                end
                if Buff.HasBuff( self, 'NOMADSCULeftArmGunUpgrade' ) then
                    Buff.RemoveBuff( self, 'NOMADSCULeftArmGunUpgrade' )
                end
                Buff.ApplyBuff(self, 'NOMADSCULeftArmGunUpgrade')
            end

            -- adjust main gun
            wep:AddDamageMod( (bp.NewDamage or wbp.Damage) - wbp.Damage )
            wep:ChangeMaxRadius(bp.NewMaxRadius or wbp.MaxRadius)
            wep:SetMuzzleOverride(false)
            wep.RackRecoilReturnSpeed = wbp.RackRecoilReturnSpeed or math.abs( wbp.RackRecoilDistance / (( 1 / rof ) - (wbp.MuzzleChargeDelay or 0))) * 1.25

        end,
        
        GunLeftUpgradeRemove = function(self, bp)
            Buff.RemoveBuff(self, 'NOMADSCULeftArmGunUpgrade')

            -- adjust main gun
            local wep = self:GetWeaponByLabel('GunLeft')
            local wbp = wep:GetBlueprint()
            wep:AddDamageMod( -((bp.NewDamage or wbp.Damage) - wbp.Damage) )
            wep:ChangeMaxRadius(wbp.MaxRadius)
            wep:SetMuzzleOverride(true)
            wep.RackRecoilReturnSpeed = wbp.RackRecoilReturnSpeed or math.abs( wbp.RackRecoilDistance / (( 1 / wbp.RateOfFire ) - (wbp.MuzzleChargeDelay or 0))) * 1.25

            -- and disable it
            local ubp = self:GetBlueprint()
            if ubp.Enhancements.GunLeft.EnableWeapon then
                self:SetWeaponEnabledByLabel( ubp.Enhancements.GunLeft.EnableWeapon, false )
                if not self:HasEnhancement('GunRight') and not self:HasEnhancement('GunRightUpgrade') and not self:HasEnhancement('RightRocket') then
                    self:RemoveCommandCap('RULEUCC_Attack')
                    self:RemoveCommandCap('RULEUCC_RetaliateToggle')
                end
            end
        end,
        
        EngineeringLeft = function(self, bp)
            if not Buffs['NOMADSCULeftArmBuildRate'] then
                BuffBlueprint {
                    Name = 'NOMADSCULeftArmBuildRate',
                    DisplayName = 'NOMADSCULeftArmBuildRate',
                    BuffType = 'SCUBUILDRATELEFT',
                    Stacks = 'ADD',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.AddBuildRate,
                            Mult = 1,
                        },
                    },
                }
            end
            if Buff.HasBuff( self, 'NOMADSCULeftArmBuildRate' ) then
                Buff.RemoveBuff( self, 'NOMADSCULeftArmBuildRate' )
            end

            Buff.ApplyBuff(self, 'NOMADSCULeftArmBuildRate')
        end,
        
        EngineeringLeftRemove = function(self, bp)
            if Buff.HasBuff( self, 'NOMADSCULeftArmBuildRate' ) then
                Buff.RemoveBuff( self, 'NOMADSCULeftArmBuildRate' )
            end
        end,
        
        LeftRocket = function(self, bp)
            if bp.EnableWeapon then
                self:SetWeaponEnabledByLabel( bp.EnableWeapon, true )
                self:AddCommandCap('RULEUCC_Attack')
                self:AddCommandCap('RULEUCC_RetaliateToggle')
            end
        end,
        
        LeftRocketRemove = function(self, bp)
            local ubp = self:GetBlueprint()
            if ubp.Enhancements.LeftRocket.EnableWeapon then
                self:SetWeaponEnabledByLabel( ubp.Enhancements.LeftRocket.EnableWeapon, false )
                if not self:HasEnhancement('GunRight') and not self:HasEnhancement('GunRightUpgrade') and not self:HasEnhancement('RightRocket') then
                    self:RemoveCommandCap('RULEUCC_Attack')
                    self:RemoveCommandCap('RULEUCC_RetaliateToggle')
                end
            end
        end,
        
        Railgun = function(self, bp)
            if bp.EnableWeapon then
                self:SetWeaponEnabledByLabel( bp.EnableWeapon, true )
                self:AddCommandCap('RULEUCC_Attack')
                self:AddCommandCap('RULEUCC_RetaliateToggle')
            end
        end,
        
        RailgunRemove = function(self, bp)
            local ubp = self:GetBlueprint()
            if ubp.Enhancements.Railgun.EnableWeapon then
                self:SetWeaponEnabledByLabel( ubp.Enhancements.Railgun.EnableWeapon, false )
                if not self:HasEnhancement('GunRight') and not self:HasEnhancement('GunRightUpgrade') and not self:HasEnhancement('RightRocket') then
                    self:RemoveCommandCap('RULEUCC_Attack')
                    self:RemoveCommandCap('RULEUCC_RetaliateToggle')
                end
            end
        end,
        
        Capacitor = function(self, bp)
            self:HasCapacitorAbility(true)
        end,
        
        CapacitorRemove = function(self, bp)
            self:ResetCapacitor()
            self:HasCapacitorAbility(false)
        end,
        
        AdditionalCapacitor = function(self, bp)
            self:ResetCapacitor()
            self:HasCapacitorAbility(true)
            if bp.CapacitorNewChargeEnergyCost then
                self.ChargeEnergyCost = bp.CapacitorNewChargeEnergyCost
            end
            if bp.CapacitorNewDuration then
                self.CapDuration = bp.CapacitorNewDuration
            end
            if bp.CapacitorNewChargeTime then
                self.CapChargeTime = bp.CapacitorNewChargeTime
            end
            if bp.DecayNewTime then
                self.CapChargeTime = bp.DecayNewTime
            end
        end,
        
        AdditionalCapacitorRemove = function(self, bp)
            self:ResetCapacitor()
            self:HasCapacitorAbility(false)
            local orgBp = self:GetBlueprint()
            local obp = orgBp.Enhancements.AdditionalCapacitor
            if obp.CapacitorNewChargeEnergyCost then
                self.ChargeEnergyCost = orgBp.Abilities.Capacitor.ChargeEnergyCost
            end
            if obp.CapacitorNewDuration then
                self.CapDuration = orgBp.Abilities.Capacitor.Duration
            end
            if obp.CapacitorNewChargeTime then
                self.CapChargeTime = orgBp.Abilities.Capacitor.ChargeTime
            end
            if obp.DecayNewTime then
                self.DecayTime = orgBp.Abilities.Capacitor.DecayNewTime
            end
        end,
        
        MovementSpeedIncrease = function(self, bp)
            if not Buffs['NomadsSCUSpeedIncrease'] then
                BuffBlueprint {
                    Name = 'NomadsSCUSpeedIncrease',
                    DisplayName = 'NomadsSCUSpeedIncrease',
                    BuffType = 'NOMADSCUSPEEDINC',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MoveMult = {
                            Add = 0,
                            Mult = bp.SpeedMulti or 1.1,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'NomadsSCUSpeedIncrease')
        end,
        
        MovementSpeedIncreaseRemove = function(self, bp)
            if Buff.HasBuff( self, 'NomadsSCUSpeedIncrease' ) then
                Buff.RemoveBuff( self, 'NomadsSCUSpeedIncrease' )
            else
                LOG('*DEBUG: SCU enhancement movement speed increase removed but buff wasnt')
            end
        end,
        
        ResourceAllocation = function(self, bp)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
            
            -- TODO: show effect on bones Backpack_Fx1 and 2
        end,
        
        ResourceAllocationRemove = function(self, bp)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        end,
        
        RapidRepair = function(self, bp)
            if not Buffs['NomadsSCURapidRepair'] then  -- make sure this buff exists though not used yet
                BuffBlueprint {
                    Name = 'NomadsSCURapidRepair',
                    DisplayName = 'NomadsSCURapidRepair',
                    BuffType = 'NOMADSCURAPIDREPAIRREGEN',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = bp.RepairRate or 15,
                            Mult = 1.0,
                        },
                    },
                }
            end
            if not Buffs['NomadsSCURapidRepairPermanentHPboost'] and bp.AddHealth > 0 then
                BuffBlueprint {
                    Name = 'NomadsSCURapidRepairPermanentHPboost',
                    DisplayName = 'NomadsSCURapidRepairPermanentHPboost',
                    BuffType = 'NOMADSCURAPIDREPAIRREGENPERMHPBOOST',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                           Add = bp.AddHealth or 0,
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
                Buff.ApplyBuff(self, 'NomadsSCURapidRepairPermanentHPboost')
            end
            self:EnableRapidRepair(true)
        end,
        
        RapidRepairRemove = function(self, bp)
            -- keep code below synced to same code in PowerArmorRemove
            self:EnableRapidRepair(false)
            if Buff.HasBuff( self, 'NomadsSCURapidRepairPermanentHPboost' ) then
                Buff.RemoveBuff( self, 'NomadsSCURapidRepair' )
                Buff.RemoveBuff( self, 'NomadsSCURapidRepairPermanentHPboost' )
            else
                LOG('*DEBUG: SCU enhancement rapid repair removed but buff wasnt')
            end
        end,
        
        PowerArmor = function(self, bp)
            if not Buffs['NomadsSCUPowerArmor'] then
               BuffBlueprint {
                    Name = 'NomadsSCUPowerArmor',
                    DisplayName = 'NomadsSCUPowerArmor',
                    BuffType = 'NSCUUPGRADEHP',
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
            if Buff.HasBuff( self, 'NomadsSCUPowerArmor' ) then
                Buff.RemoveBuff( self, 'NomadsSCUPowerArmor' )
            end
            Buff.ApplyBuff(self, 'NomadsSCUPowerArmor')
            if bp.Mesh then
                self:SetMesh( bp.Mesh, true)
            end
        end,
        
        PowerArmorRemove = function(self, bp)
            local ubp = self:GetBlueprint()
            if bp.Mesh then
                self:SetMesh( ubp.Display.MeshBlueprint, true)
            end
            if Buff.HasBuff( self, 'NomadsSCUPowerArmor' ) then
                Buff.RemoveBuff( self, 'NomadsSCUPowerArmor' )
            end

            -- remove rapid repair - copy of above
            self:EnableRapidRepair(false)
            if Buff.HasBuff( self, 'NomadsSCURapidRepairPermanentHPboost' ) then
                Buff.RemoveBuff( self, 'NomadsSCURapidRepair' )
                Buff.RemoveBuff( self, 'NomadsSCURapidRepairPermanentHPboost' )
            end
        end,
        
        GunRight = function(self, bp)
            if bp.EnableWeapon then
                self:SetWeaponEnabledByLabel( bp.EnableWeapon, true )
                self:AddCommandCap('RULEUCC_Attack')
                self:AddCommandCap('RULEUCC_RetaliateToggle')
            end
        end,
        
        GunRightRemove = function(self, bp)
            local ubp = self:GetBlueprint()
            if ubp.Enhancements.GunRight.EnableWeapon then
                self:SetWeaponEnabledByLabel( ubp.Enhancements.GunRight.EnableWeapon, false )
                if not self:HasEnhancement('GunLeft') and not self:HasEnhancement('GunLeftUpgrade') and not self:HasEnhancement('LeftRocket') and not self:HasEnhancement('Railgun') then
                    self:RemoveCommandCap('RULEUCC_Attack')
                    self:RemoveCommandCap('RULEUCC_RetaliateToggle')
                end
            end
        end,
        
        GunRightUpgrade = function(self, bp) --Retard: looks like this doesnt do anything, consider removing
            -- adjust gattling
            -- local wep = self:GetWeaponByLabel('GunRight')
            WARN('Todo: SCU right arm upgrade')
        end,
        
        GunRightUpgradeRemove = function(self, bp) --Retard: looks like this doesnt do anything, consider removing
            -- adjust gattling
            -- local wep = self:GetWeaponByLabel('GunRight')

            -- and disable it
            local ubp = self:GetBlueprint()
            if ubp.Enhancements.GunRight.EnableWeapon then
                self:SetWeaponEnabledByLabel( ubp.Enhancements.GunRight.EnableWeapon, false )
                if not self:HasEnhancement('GunLeft') and not self:HasEnhancement('GunLeftUpgrade') and not self:HasEnhancement('LeftRocket') and not self:HasEnhancement('Railgun') then
                    self:RemoveCommandCap('RULEUCC_Attack')
                    self:RemoveCommandCap('RULEUCC_RetaliateToggle')
                end
            end
        end,
        
        EngineeringRight = function(self, bp)
            if not Buffs['NOMADSCURightArmBuildRate'] then
                BuffBlueprint {
                    Name = 'NOMADSCURightArmBuildRate',
                    DisplayName = 'NOMADSCURightArmBuildRate',
                    BuffType = 'SCUBUILDRATERIGHT',
                    Stacks = 'ADD',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.AddBuildRate,
                            Mult = 1,                            
                        },
                    },
                }
            end
            if Buff.HasBuff( self, 'NOMADSCURightArmBuildRate' ) then
                Buff.RemoveBuff( self, 'NOMADSCURightArmBuildRate' )
            end

            Buff.ApplyBuff(self, 'NOMADSCURightArmBuildRate')
        end,
        
        EngineeringRightRemove = function(self, bp)
            if Buff.HasBuff( self, 'NOMADSCULeftArmBuildRate' ) then
                Buff.RemoveBuff( self, 'NOMADSCULeftArmBuildRate' )
            end
        end,
        
        RightRocket = function(self, bp)
            if bp.EnableWeapon then
                self:SetWeaponEnabledByLabel( bp.EnableWeapon, true )
                self:AddCommandCap('RULEUCC_Attack')
                self:AddCommandCap('RULEUCC_RetaliateToggle')
            end
        end,
        
        RightRocketRemove = function(self, bp)
            local ubp = self:GetBlueprint()
            if ubp.Enhancements.RightRocket.EnableWeapon then
                self:SetWeaponEnabledByLabel( ubp.Enhancements.RightRocket.EnableWeapon, false )
                if not self:HasEnhancement('GunLeft') and not self:HasEnhancement('GunLeftUpgrade') and not self:HasEnhancement('LeftRocket') and not self:HasEnhancement('Railgun') then
                    self:RemoveCommandCap('RULEUCC_Attack')
                    self:RemoveCommandCap('RULEUCC_RetaliateToggle')
                end
            end
        end,
        
        Generic = function(self, bp)
        end,
    },
    
    
    CreateEnhancement = function(self, enh)
        NWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end

        -- show or hide repair geometry on arms of model, depending on presence of certain enhancements
        if enh == 'RapidRepair' or enh == 'PowerArmor' or enh == 'AdditionalCapacitor' or enh == 'ResourceAllocation' or enh == 'LeftRocket' or enh == 'RightRocket'
             or bp.CreatesLeftArm or bp.CreatesRightArm or bp.RemovesLeftArm or bp.RemovesRightArm then

            -- need to check presence of enhancements and presence of arms, then either hide or show bones. It's more complex than you would
            -- think.
            local RR = (self:HasEnhancement('RapidRepair') or enh == 'RapidRepair')
            local PA = (self:HasEnhancement('PowerArmor') or enh == 'PowerArmor')
            local C = (self:HasEnhancement('AdditionalCapacitor') or enh == 'AdditionalCapacitor')
            local RAS = (self:HasEnhancement('ResourceAllocation') or enh == 'ResourceAllocation')
            local MSLL = (self:HasEnhancement('LeftRocket') or enh == 'LeftRocket')
            local MSLR = (self:HasEnhancement('RightRocket') or enh == 'RightRocket')

            if bp.CreatesLeftArm then
                self.HasLeftArm = true
            elseif bp.RemovesLeftArm then
                self.HasLeftArm = false
            end
            if bp.CreatesRightArm then
                self.HasRightArm = true
            elseif bp.RemovesRightArm then
                self.HasRightArm = false
            end

            -- left arm + rapid repair or left arm + power armor
            if RR and self.HasLeftArm then
                self:ShowBone( 'Nano_LArm', true )
            else
                self:HideBone( 'Nano_LArm', true )
            end
            if PA and self.HasLeftArm then
                self:ShowBone( 'Nano_LPauld', true )
            else
                self:HideBone( 'Nano_LPauld', true )
            end
            if self.HasLeftArm then
                self:HideBone( 'SGun', true )
            end
            -- no left arm but missile launcher icw rapid repair and power armor
            if RR and MSLL then
                self:ShowBone( 'Nano_MissileL', true )
            else
                self:HideBone( 'Nano_MissileL', true )
            end
            if PA and MSLL then
                self:ShowBone( 'Nano_MissileL2', true )
            else
                self:HideBone( 'Nano_MissileL2', true )
            end
            -- right arm + rapid repair, or right arm + power armor
            if RR and self.HasRightArm then
                self:ShowBone( 'Nano_RArm', true )
            else
                self:HideBone( 'Nano_RArm', true )
            end
            if PA and self.HasRightArm then
                self:ShowBone( 'Nano_RPauld', true )
            else
                self:HideBone( 'Nano_RPauld', true )
            end
            -- no right arm but capacitor icw rapid repair, power armor and RAS
            if RR and C then
                self:ShowBone( 'Capacitor_Nano2', true )
            else
                self:HideBone( 'Capacitor_Nano2', true )
            end
            if PA and C then
                self:ShowBone( 'Capacitor_Nano', true )
            else
                self:HideBone( 'Capacitor_Nano', true )
            end
            if RAS and C then
                self:ShowBone( 'CapacitorTube', true )
            else
                self:HideBone( 'CapacitorTube', true )
            end
            -- no right arm but missile launcher icw rapid repair and power armor
            if RR and MSLR then
                self:ShowBone( 'Nano_MissileR', true )
            else
                self:HideBone( 'Nano_MissileR', true )
            end
            if PA and MSLR then
                self:ShowBone( 'Nano_MissileR2', true )
            else
                self:HideBone( 'Nano_MissileR2', true )
            end
        end

        if self.EnhancementBehaviours[enh] then
            self.EnhancementBehaviours[enh](self, bp)
        else
            WARN('Nomads: Enhancement '..repr(enh)..' has no script support.')
        end
    end,



    
-- =================================================================================================================

    CreateDestructionEffects = function( self, overKillRatio )
        -- explosions at these bones
        local bones = { 'Thigh_L', 'Thigh_R', 'Midleg_L', 'Midleg_R', 'Foreleg_L', 'Foreleg_R', }
        -- explosion at these bones and then hide them. As if the explosion destroys that part of the unit
        local hideBones = { 'Engi_Basic', 'Head', 'Pauldron_L', 'Pauldron_R', }

        -- check all enhancements to find bones we can use for effects
        local bp = self:GetBlueprint()
        for name, enh in bp.Enhancements do
            if self:HasEnhancement(name) and enh.ShowBones then
                hideBones = table.cat(hideBones, enh.ShowBones)
            end
        end

        -- determine effect templates to use
        local layer = self:GetCurrentLayer()
        local TemplReg = NomadsEffectTemplate.SCUDestructionRegularSurface
        local TemplSmall = NomadsEffectTemplate.SCUDestructionSmallExplosionsSurface
        if layer == 'Seabed' or layer == 'Sub' then
            TemplReg = NomadsEffectTemplate.SCUDestructionRegularUnderWater
            TemplSmall = NomadsEffectTemplate.SCUDestructionSmallExplosionsUnderWater
        end

        -- base effect
        local army = self:GetArmy()
        local emitters = {}
        local emit, rs, k
        for k, v in TemplReg do
            emit = CreateEmitterAtBone(self, 'Torso', army, v)
            table.insert(emitters, emit)
        end

        -- small epxlosions
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sy * sz
        local numHideBones = table.getn(hideBones)
        local numB = table.getn(bones)
        local total = numB + numHideBones
        local GetHideBone = RandomIter(hideBones)
        local num = math.min(8, math.max(3, Random( math.min(numHideBones, numB), math.max(numHideBones, numB)))) -- a random number between 3 and 8 based on number of fx bones
        for i=1, num do

            local rx, ry, rz = self:GetRandomOffset(0.1)
            rs = Random(vol/2, vol*2) / (vol*2)

            if Random(0, total) > numB then
                -- explosion at enhancement or bone that we want to hide
                k, bone = GetHideBone()
                self:HideBone(bone, true)
                total = total - 1
            else
                -- explosion at bone
                bone = bones[ Random(1, numB) ]
            end

            for k, v in TemplSmall do
                emit = CreateEmitterAtBone(self, bone, army, v):ScaleEmitter(rs):OffsetEmitter(rx, ry, rz)
                table.insert(emitters, emit)
            end

            WaitTicks(2)
        end
    end,
}

TypeClass = XNL0301
