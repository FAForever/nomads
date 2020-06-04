-- Nomads SACU

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NomadsEffectUtil = import('/lua/nomadseffectutilities.lua')
local Utilities = import('/lua/utilities.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair
local AddRapidRepairToWeapon = import('/lua/nomadsutils.lua').AddRapidRepairToWeapon
local AddAkimbo = import('/lua/nomadsutils.lua').AddAkimbo

local NCommandUnit = import('/lua/nomadsunits.lua').NCommandUnit

local APCannon1 = import('/lua/nomadsweapons.lua').APCannon1
local UnderwaterRailgunWeapon1 = import('/lua/nomadsweapons.lua').UnderwaterRailgunWeapon1
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local DeathEnergyBombWeapon = import('/lua/nomadsweapons.lua').DeathEnergyBombWeapon

NCommandUnit = AddAkimbo(AddRapidRepair(NCommandUnit))


XNL0301 = Class(NCommandUnit) {

    Weapons = {
        Rocket = Class(AddRapidRepairToWeapon(RocketWeapon1)) {
		    OnCreate = function(self)
                RocketWeapon1.OnCreate(self)
                self:DisableBuff('STUN')
            end,
		},
        Torpedo = Class(AddRapidRepairToWeapon(UnderwaterRailgunWeapon1)) {},
        MainGun = Class(AddRapidRepairToWeapon(APCannon1)) {
            OnCreate = function(self)
                APCannon1.OnCreate(self)
                self:DisableBuff('STUN')
            end,
		},
        RASDeathWeapon = Class(DeathEnergyBombWeapon) {},
    },

    __init = function(self)
        NCommandUnit.__init(self, 'MainGun')
    end,
    
    DestructionPartsLowToss = { 'Torso', 'Head', },

    OnCreate = function(self)
        NCommandUnit.OnCreate(self)

        local bp = self:GetBlueprint()

        -- TODO: Remove once related change gets released in the game patch
        self.BuildEffectBones = bp.General.BuildBones.BuildEffectBones

        self.HeadRotationEnabled = false -- initially disable head rotation to prevent initial wrong rotation

        self:SetCapturable(false)
        self:SetupBuildBones()
        
        self.RapidRepairBonusArmL = 0 --one for each upgrade slot, letting us easily track upgrade changes.
        self.RapidRepairBonusArmR = 0
        self.RapidRepairBonusBack = 0

        -- enhancement related
        self:RemoveToggleCap('RULEUTC_SpecialToggle')
        self:SetWeaponEnabledByLabel( 'Torpedo', false )
        self:SetWeaponEnabledByLabel( 'Rocket', false )
    
        self.Sync.Abilities = self:GetBlueprint().Abilities
    end,

    OnStartBeingBuilt = function(self, builder, layer)
        NCommandUnit.OnStartBeingBuilt(self, builder, layer)

        local bp = self:GetBlueprint()
        if bp.Display.AnimationAlert then
            self.AlertAnimManip = CreateAnimator(self):PlayAnim(bp.Display.AnimationAlert):SetRate(0)
            self.AlertAnimManip:SetAnimationFraction(0)
            self.Trash:Add( self.AlertAnimManip )
        end
    end,

    StopBeingBuiltEffects = function(self, builder, layer)
        NCommandUnit.StopBeingBuiltEffects(self, builder, layer)

        if self:HasEnhancement('PowerArmor') then
            local bp = self:GetBlueprint().Enhancements['PowerArmor']
            self:SetMesh( bp.Mesh, true)
        end
        if self.AlertAnimManip then
            self.AlertAnimManip:SetRate(1)
            WaitFor(self.AlertAnimManip)
        end
    end,

    -- =====================================================================================================================
    -- UNIT DEATH

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
            NCommandUnit.CreateWreckage(self, overkillRatio)
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


    CreateCaptureEffects = function( self, target )
        EffectUtil.PlayCaptureEffects( self, target, self:GetBuildBones() or {0,}, self.CaptureEffectsBag )
    end,

    --overwrite the GetBuildBones to allow for enhancement support
    GetBuildBones = function(self)
        local bones = table.deepcopy( self:GetBlueprint().General.BuildBones.BuildEffectBones )
        if self:HasEnhancement('EngineeringSuite') then
            table.insert( bones, 'Engi_R_Muzzle.001')
            table.insert( bones, 'Engi_R_Muzzle.002')
        end
        return bones
    end,

-- =================================================================================================================

    OnAttachedToTransport = function(self, transport, transportBone)
        -- disable head rotation. Coming of the transport, the head gets a weird rotation
        self.HeadRotationEnabled = false
        NCommandUnit.OnAttachedToTransport(self, transport, transportBone)
    end,

    OnDetachedFromTransport = function(self, transport, transportBone)
        -- disable head rotation. Coming of the transport, the head gets a weird rotation
        self.HeadRotationEnabled = false
        NCommandUnit.OnDetachedFromTransport(self, transport, transportBone)
    end,

    UpdateMovementEffectsOnMotionEventChange = function( self, new, old )
        self.HeadRotationEnabled = true
        NCommandUnit.UpdateMovementEffectsOnMotionEventChange( self, new, old )
    end,

-- =================================================================================================================

    CanBeStunned = function(self)
        if self:HasEnhancement('PowerArmor') then
            return false
        end
        return NCommandUnit.CanBeStunned(self)
    end,

    -- =====================================================================================================================
    -- RAPID REPAIR
    
    --This custom timer function allows us to reset or partially delay the timer without killing the thread
    StartRapidRepair = function(self)
        local bp = self:GetBlueprint()
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
        EMPWeapon = function(self, bp) --TODO: make this add splash and change projectiles for certain weapons
            local wep = self:GetWeaponByLabel('MainGun')
			local wbp = self:GetWeaponByLabel('Rocket')
			wep:ReEnableBuff('STUN')
            wbp:ReEnableBuff('STUN')
        end,
        
        EMPWeaponRemove = function(self, bp)
            local wep = self:GetWeaponByLabel('MainGun')
			local wbp = self:GetWeaponByLabel('Rocket')
			wep:DisableBuff('STUN')
            wbp:DisableBuff('STUN')
        end,
        
        EngineeringSuite = function(self, bp)
            if not Buffs['NOMADSCULeftArmBuildRate'] then
                BuffBlueprint {
                    Name = 'NOMADSCULeftArmBuildRate',
                    DisplayName = 'NOMADSCULeftArmBuildRate',
                    BuffType = 'SCUBUILDRATELEFT',
                    Stacks = 'ADD',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
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
        
        EngineeringSuiteRemove = function(self, bp)
            if Buff.HasBuff( self, 'NOMADSCULeftArmBuildRate' ) then
                Buff.RemoveBuff( self, 'NOMADSCULeftArmBuildRate' )
            end
        end,
        
        Torpedo = function(self, bp)
            self:SetWeaponEnabledByLabel( 'Torpedo', true )
            self:SetWeaponEnabledByLabel( 'Rocket', true )
        end,
        
        TorpedoRemove = function(self, bp)
            self:SetWeaponEnabledByLabel( 'Torpedo', false )
            self:SetWeaponEnabledByLabel( 'Rocket', false )
        end,
        
        ResourceAllocation = function(self, bp)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        end,
        
        ResourceAllocationRemove = function(self, bp)
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        end,
        
        RapidRepair = function(self, bp)
            self.RapidRepairBonusBack = bp.BonusRepairRate
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
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
        end,
        
        RapidRepairRemove = function(self, bp)
            self.RapidRepairBonusBack = 0
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
            if Buff.HasBuff( self, 'NomadsSCURapidRepairPermanentHPboost' ) then
                Buff.RemoveBuff( self, 'NomadsSCURapidRepairPermanentHPboost' )
            else
                LOG('*DEBUG: SCU enhancement rapid repair removed but buff wasnt')
            end
        end,
        
        PowerArmor = function(self, bp)
            --this doesnt have an additional rapid repair buff?
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
            self.RapidRepairBonusBack = 0
            self:StartRapidRepairCooldown(0) --update the repair bonus buff - this way doesnt disrupt the repair state
            local ubp = self:GetBlueprint()
            if bp.Mesh then
                self:SetMesh( ubp.Display.MeshBlueprint, true) --this doesnt actually work --TODO:fix it
            end
            if Buff.HasBuff( self, 'NomadsSCUPowerArmor' ) then
                Buff.RemoveBuff( self, 'NomadsSCUPowerArmor' )
            end

            -- remove rapid repair - copy of above
            if Buff.HasBuff( self, 'NomadsSCURapidRepairPermanentHPboost' ) then
                Buff.RemoveBuff( self, 'NomadsSCURapidRepairPermanentHPboost' )
            end
        end,
        
        GunUpgrade = function(self, bp)
            local wep = self:GetWeaponByLabel('MainGun')
            wep:ChangeRateOfFire(bp.NewRateOfFire)
            wep:ChangeMaxRadius(bp.NewMaxRadius or 30)
        end,
        
        GunUpgradeRemove = function(self, bp)
            local wep = self:GetWeaponByLabel('MainGun')
            wep:ChangeRateOfFire(self:GetBlueprint().Weapon[3].RateOfFire or 0.667)
            wep:ChangeMaxRadius(self:GetBlueprint().Weapon[3].MaxRadius or 25)
        end,
        
        Generic = function(self, bp)
        end,
    },
    
    CreateEnhancement = function(self, enh)
        NCommandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
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
        local hideBones = { 'Head', 'Pauldron_L', 'Pauldron_R', }

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
        local emitters = {}
        local emit, rs, k
        for k, v in TemplReg do
            emit = CreateEmitterAtBone(self, 'Torso', self.Army, v)
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
                emit = CreateEmitterAtBone(self, bone, self.Army, v):ScaleEmitter(rs):OffsetEmitter(rx, ry, rz)
                table.insert(emitters, emit)
            end

            WaitTicks(2)
        end
    end,
}

TypeClass = XNL0301
