-- carrier

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
--local SupportingArtilleryAbility = import('/lua/nomadsutils.lua').SupportingArtilleryAbility
local AddFlares = import('/lua/nomadsutils.lua').AddFlares
--local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1
local HVFlakWeapon = import('/lua/nomadsweapons.lua').HVFlakWeapon

-- add supporting artillery ability and aa missile flares
--NSeaUnit = AddNavalLights(NSeaUnit)
--NSeaUnit = SupportingArtilleryAbility( NSeaUnit )
NSeaUnit = AddFlares( NSeaUnit )

INS3003 = Class(NSeaUnit) {

    Weapons = {
        AAGun1 = Class(ParticleBlaster1) {
            OnCreate = function(self)
                ParticleBlaster1.OnCreate(self)
                self.AimControl:SetAimHeadingOffset(0.5)
            end,
        },
        AAGun2 = Class(ParticleBlaster1) {
            OnCreate = function(self)
                ParticleBlaster1.OnCreate(self)
                self.AimControl:SetAimHeadingOffset(0.5)
            end,
        },
        AAGun3 = Class(ParticleBlaster1) {
            OnCreate = function(self)
                ParticleBlaster1.OnCreate(self)
                self.AimControl:SetAimHeadingOffset(0.5)
            end,
        },
        AAGun4 = Class(ParticleBlaster1) {
            OnCreate = function(self)
                ParticleBlaster1.OnCreate(self)
                self.AimControl:SetAimHeadingOffset(0.5)
            end,
        },
        TMD1 = Class(HVFlakWeapon) {
            IdleState = State(HVFlakWeapon.IdleState) {
                Main = function(self)
                    HVFlakWeapon.IdleState.Main(self)
                    self.unit:OnTargetLost()
                    if self.IdleReloadThread then
                        KillThread(self.IdleReloadThread)
                    end
                    self.IdleReloadThread = self:ForkThread(self.ReloadThread)
                end,
                
                
                ReloadThread = function(self)
                    --WARN('waiting in idle reload')
                    WaitSeconds(1)
                    if not self.PlayingTAEffects then
                        --WARN('idle reload time elapsed successfully')
                        self.counter = 0
                    else
                        --WARN('idle reload time reset with counter: '..self.counter)
                    end
                    --self.RackSalvoFireReadyState.Main(self)
                end,
            },

            RackSalvoReloadState = State(HVFlakWeapon.RackSalvoReloadState) {
                Main = function(self)
                    ForkThread(function()
                        --WARN("reloading")
                        WaitSeconds(1)
                        --WARN('wait time elapsed')
                        HVFlakWeapon.RackSalvoReloadState.Main(self)
                        self.unit:OnTargetLost()
                    end)
                end,
            },

            RackSalvoFireReadyState = State(HVFlakWeapon.RackSalvoFireReadyState ) {
                Main = function(self)
                    HVFlakWeapon.RackSalvoFireReadyState.Main(self)
                    self.unit:OnTargetAcquired()
                end,
            },

            RackSalvoFiringState = State(HVFlakWeapon.RackSalvoFiringState ) {
                Main = function(self)
                    if not self.counter then
                        self.counter = 0
                    end
                    self.counter = self.counter + 1
                    if self.counter > 5 then
                        --WARN("reseting counter from: "..self.counter)
                        self.counter = 0
                        self.RackSalvoReloadState.Main(self)
                    else
                        self:PlaySound(self.Audio.FireSpecial)
                        --WARN('fire counter: '..self.counter)
                        HVFlakWeapon.RackSalvoFiringState.Main(self)
                        self.unit:OnTargetAcquired()
                    end
                end,
                
                Audio = {
                    FireSpecial = Sound {
                        Bank = 'NomadsWeapons',
                        Cue = 'DarkMatterCannon2_Muzzle',
                        LodCutoff = 'Weapon_LodCutoff',
                    },
                },
            },
        },
        TMD2 = Class(HVFlakWeapon) {
            IdleState = State(HVFlakWeapon.IdleState) {
                Main = function(self)
                    HVFlakWeapon.IdleState.Main(self)
                    self.unit:OnTargetLost()
                    if self.IdleReloadThread then
                        KillThread(self.IdleReloadThread)
                    end
                    self.IdleReloadThread = self:ForkThread(self.ReloadThread)
                end,
                
                
                ReloadThread = function(self)
                    --WARN('waiting in idle reload')
                    WaitSeconds(1.2)
                    if not self.PlayingTAEffects then
                        --WARN('idle reload time elapsed successfully')
                        self.counter = 0
                    else
                        --WARN('idle reload time reset with counter: '..self.counter)
                    end
                    --self.RackSalvoFireReadyState.Main(self)
                end,
            },

            RackSalvoReloadState = State(HVFlakWeapon.RackSalvoReloadState) {
                Main = function(self)
                    ForkThread(function()
                        --WARN("reloading")
                        WaitSeconds(1.2)
                        --WARN('wait time elapsed')
                        HVFlakWeapon.RackSalvoReloadState.Main(self)
                        self.unit:OnTargetLost()
                    end)
                end,
            },

            RackSalvoFireReadyState = State(HVFlakWeapon.RackSalvoFireReadyState ) {
                Main = function(self)
                    HVFlakWeapon.RackSalvoFireReadyState.Main(self)
                    self.unit:OnTargetAcquired()
                end,
            },

            RackSalvoFiringState = State(HVFlakWeapon.RackSalvoFiringState ) {
                Main = function(self)
                    if not self.counter then
                        self.counter = 0
                    end
                    self.counter = self.counter + 1
                    if self.counter > 5 then
                        --WARN("reseting counter from: "..self.counter)
                        self.counter = 0
                        self.RackSalvoReloadState.Main(self)
                    else
                        self:PlaySound(self.Audio.FireSpecial)
                        --WARN('fire counter: '..self.counter)
                        HVFlakWeapon.RackSalvoFiringState.Main(self)
                        self.unit:OnTargetAcquired()
                    end
                end,
                
                Audio = {
                    FireSpecial = Sound {
                        Bank = 'NomadsWeapons',
                        Cue = 'DarkMatterCannon2_Muzzle',
                        LodCutoff = 'Weapon_LodCutoff',
                    },
                },
            },
        },
    },

    BuildAttachBone = 'INS3003',
    DestructionPartsLowToss = { 'Pad1_1', 'Pad1_2', 'Pad1_3', 'Pad1_4', 'Pad1_5', 'Pad1_6', 
                                'Pad2_1', 'Pad2_2', 'Pad2_3', 'Pad2_4', 'Pad2_5', 'Pad2_6',
                                'Pad3_1', 'Pad3_2', 'Pad3_3', 'Pad3_4', 'Pad3_5', 'Pad3_6',
                                'AAGun1', 'AAGun2', 'AAGun3', 'AAGun4', 'TMD1', 'TMD2', 
    },
--    LightBone_Left = 'Light_03',
--    LightBone_Right = 'Light_02',
    TMDEffectBones = { { 'TMD1_Fx1', 'TMD1_Fx2', }, { 'TMD2_Fx1', 'TMD2_Fx2', }, },

    OnCreate = function(self)
        NSeaUnit.OnCreate(self)

        self.TAEffectsBag = TrashBag()
        self.PlayingTAEffects = false

        self:NextBuildAttachBone()

        self.OpenAnimManips = {}
        local n=1
        for i=1, 3 do  -- change the number of loops to control the number of pads used, max 3 and min 1
            self.OpenAnimManips[n] = CreateAnimator(self):PlayAnim('/units/INS3003/INS3003_OpenPad'..i..'.sca'):SetRate(0)
            self.OpenAnimManips[n]:SetAnimationFraction(0)
            self.Trash:Add( self.OpenAnimManips[n] )
            n = n + 1
        end
    end,

    OnDestroy = function(self)
        self:DestroyTAEffects()
        NSeaUnit.OnDestroy(self)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        NSeaUnit.OnStopBeingBuilt(self,builder,layer)
        ChangeState(self, self.IdleState)
    end,

    OnUnitAddedToStorage = function(self, unit)
        NSeaUnit.OnUnitAddedToStorage(self, unit)
    end,

    OnUnitRemovedFromStorage = function(self, unit)
        NSeaUnit.OnUnitRemovedFromStorage(self, unit)

        self:PlayAllOpenAnims(true)
        self:AutoClose()
    end,

    OnTargetAcquired = function(self, TMD)
        --LOG('OnTargetAcquired')
        self:PlayTAEffects(TMD)
    end,

    OnTargetLost = function(self, TMD)
        --LOG('OnTargetLost')
        self:DestroyTAEffects()
    end,

    PlayTAEffects = function(self, TMD)
        if not self.PlayingTAEffects then
            local army, emit = self:GetArmy()
            for _, bone in self.TMDEffectBones[TMD] do
                for k, v in NomadsEffectTemplate.T2MobileTacticalMissileDefenseTargetAcquired do
                    emit = CreateAttachedEmitter(self, bone, army, v)
                    self.TAEffectsBag:Add(emit)
                    self.Trash:Add(emit)
                end
            end
            local thread = function(self)
                WaitSeconds(1)
                self:DestroyTAEffects()
            end
            self.PlayingTAEffectsThread = self:ForkThread( thread )
            self.PlayingTAEffects = true
        end
    end,

    DestroyTAEffects = function(self)
        -- TODO: bug here. We destroy all effects, not the effects for a specific TMD. The other TMD migth not want its effects destroyed yet.
        -- minor problem at best.
        self.TAEffectsBag:Destroy()
        self.PlayingTAEffects = false
    end,

    AutoClose = function(self)
        if self.AutoCloseThreadHandle then
            KillThread(self.AutoCloseThreadHandle)
            self.AutoCloseThreadHandle = nil
        end

        local fn = function(self, timeout)
            WaitSeconds(timeout)
            self:PlayAllOpenAnims(false)
        end
        self.AutoCloseThreadHandle = self:ForkThread( fn, 2 )
    end,

    PlayAllOpenAnims = function(self, open)
        for k, v in self.OpenAnimManips do
            if open then
                v:SetRate(5)
            else
                v:SetRate(-1)
            end
        end
    end,

    NextBuildAttachBone = function(self)
        if self.BuildAttachBone == 'Pad1' then
            self.BuildAttachBone = 'Pad2'
        elseif self.BuildAttachBone == 'Pad2' then
            self.BuildAttachBone = 'Pad3'
        else
            self.BuildAttachBone = 'Pad1'
        end
    end,

    OnFailedToBuild = function(self)
        NSeaUnit.OnFailedToBuild(self)
        ChangeState(self, self.IdleState)
    end,

    IdleState = State {
        Main = function(self)
            self:DetachAll(self.BuildAttachBone)
            self:SetBusy(false)
        end,

        OnStartBuild = function(self, unitBuilding, order)
            NSeaUnit.OnStartBuild(self, unitBuilding, order)
            self.UnitBeingBuilt = unitBuilding
            ChangeState(self, self.BuildingState)
        end,
    },

    BuildingState = State {
        Main = function(self)
            self:SetBusy(true)
            self:DetachAll( self.BuildAttachBone )
            self.UnitBeingBuilt:HideBone( 0, true )
            self.UnitDoneBeingBuilt = false
        end,

        OnStopBuild = function(self, unitBeingBuilt)
            NSeaUnit.OnStopBuild(self, unitBeingBuilt)
            ChangeState(self, self.FinishedBuildingState)
        end,
    },

    FinishedBuildingState = State {
        Main = function(self)
            self:SetBusy(true)
            self.UnitBeingBuilt:DetachFrom(true)
            self:DetachAll(self.BuildAttachBone)
            if self:TransportHasAvailableStorage() then
                self:AddUnitToStorage( self.UnitBeingBuilt )
            else
                local worldPos = self:CalculateWorldPositionFromRelative( {0, 0, -20} )
                Warp( self.UnitBeingBuilt, self:GetPosition( self.BuildAttachBone ), self.UnitBeingBuilt:GetOrientation() )
                IssueMoveOffFactory( { self.UnitBeingBuilt, }, worldPos )
                self.UnitBeingBuilt:ShowBone( 0, true )
            end

            self:NextBuildAttachBone()

            self:SetBusy(false)
            self:RequestRefreshUI()
            ChangeState(self, self.IdleState)
        end,
    },
}

TypeClass = INS3003