-- T2 field enginer

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AddIntelOvercharge = import('/lua/nomadsutils.lua').AddIntelOvercharge
local NConstructionUnit = import('/lua/nomadsunits.lua').NConstructionUnit
local HVFlakWeapon = import('/lua/nomadsweapons.lua').HVFlakWeapon

NConstructionUnit = AddAnchorAbilty( AddIntelOvercharge( NConstructionUnit ))

XNL0209 = Class(NConstructionUnit) {
    Weapons = {
        MainGun = Class(HVFlakWeapon) {
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
                    WaitSeconds(1.4)
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
                        WaitSeconds(1.4)
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

    OverchargeFxBone = 'TMD_Fx1',
    OverchargeChargingFxBone = 'TMD_Fx1',
    OverchargeExplosionFxBone = 'TMD_Fx1',

    OverchargeFx = NomadsEffectTemplate.T1RadarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T1RadarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T1RadarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T1RadarOverchargeExplosion,

    TMDEffectBones = { 'TMD_Fx1', 'TMD_Fx2', },

    OnCreate = function(self)
        NConstructionUnit.OnCreate(self)
        self.TAEffectsBag = TrashBag()
        self.PlayingTAEffects = false
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NConstructionUnit.OnStopBeingBuilt(self, builder, layer)
        self:SetMaintenanceConsumptionActive()
    end,

    OnDestroy = function(self)
        self:DestroyTAEffects()
        NConstructionUnit.OnDestroy(self)
    end,

    OnTargetAcquired = function(self)
        --LOG('OnTargetAcquired')
        self:PlayTAEffects()
    end,

    OnTargetLost = function(self)
        --LOG('OnTargetLost')
        self:DestroyTAEffects()
    end,

    PlayTAEffects = function(self)
        if not self.PlayingTAEffects then
            local army, emit = self:GetArmy()
            for _, bone in self.TMDEffectBones do
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
        self.TAEffectsBag:Destroy()
        self.PlayingTAEffects = false
    end,

    OnScriptBitSet = function(self, bit)
        NConstructionUnit.OnScriptBitSet(self, bit)
        if bit == 1 then
            self:IntelOverchargeBeginCharging()
        end
    end,

    OnScriptBitClear = function(self, bit)
        NConstructionUnit.OnScriptBitClear(self, bit)
        if bit == 1 then
            self:IntelOverchargeChargingCancelled()
        end
    end,

    OnIntelOverchargeBeginCharging = function(self)
        NConstructionUnit.OnIntelOverchargeBeginCharging(self)
        self:SetScriptBit('RULEUTC_WeaponToggle', true)
    end,

    OnIntelOverchargeChargingCancelled = function(self)
        NConstructionUnit.OnIntelOverchargeChargingCancelled(self)
        self:SetScriptBit('RULEUTC_WeaponToggle', false)
    end,

    OnIntelOverchargeFinishedCharging = function(self)
        NConstructionUnit.OnIntelOverchargeFinishedCharging(self)
        self:RemoveToggleCap('RULEUTC_WeaponToggle')
    end,

    OnBeginIntelOvercharge = function(self)
        NConstructionUnit.OnBeginIntelOvercharge(self)
        self:RemoveToggleCap('RULEUTC_WeaponToggle')
    end,

    OnFinishedIntelOvercharge = function(self)
        NConstructionUnit.OnFinishedIntelOvercharge(self)

        local OverchargeRecoverTime = self:GetBlueprint().Intel.OverchargeRecoverTime or 0
        if OverchargeRecoverTime <= 0 then
            self:AddToggleCap('RULEUTC_WeaponToggle')
            self:SetScriptBit('RULEUTC_WeaponToggle', false)
        end
    end,

    OnFinishedIntelOverchargeRecovery = function(self)
        NConstructionUnit.OnFinishedIntelOverchargeRecovery(self)

        self:AddToggleCap('RULEUTC_WeaponToggle')
        self:SetScriptBit('RULEUTC_WeaponToggle', false)
    end,
}

TypeClass = XNL0209