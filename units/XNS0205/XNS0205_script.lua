-- T2 railgun boat

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local UnderwaterRailgunWeapon1 = import('/lua/nomadsweapons.lua').UnderwaterRailgunWeapon1
local HVFlakWeapon = import('/lua/nomadsweapons.lua').HVFlakWeapon
local Utilities = import('/lua/utilities.lua')

NSeaUnit = AddNavalLights(NSeaUnit)

XNS0205 = Class(NSeaUnit) {
    Weapons = {
        MainGun = Class(UnderwaterRailgunWeapon1) {},
        RearGun = Class(UnderwaterRailgunWeapon1) {},
        TMD = Class(HVFlakWeapon) { --TODO: refactor this so all the counting is done in the HVFlakWeapon and here you just set parameters
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

    DestructionPartsLowToss = { 'TMD_Yaw', },
    LightBone_Left = 'Antennae_2',
    LightBone_Right = 'Antennae_1',
    SmokeEmitterBones = { 'Reactor_Smoke', },
    TMDEffectBones = { 'TMD_Fx1', 'TMD_Fx2', },

    OnCreate = function(self)
        NSeaUnit.OnCreate(self)
        self.SmokeEmitters = TrashBag()
        self.TAEffectsBag = TrashBag()
    end,

    DestroyAllDamageEffects = function(self)
        self:DestroyMovementSmokeEffects()
        NSeaUnit.DestroyAllDamageEffects(self)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self:DestroyMovementSmokeEffects()
        NSeaUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnDestroy = function(self)
        self:DestroyMovementSmokeEffects()
        self:DestroyTAEffects()
        NSeaUnit.OnDestroy(self)
    end,

    OnTargetAcquired = function(self)
        self:PlayTAEffects()
    end,

    OnTargetLost = function(self)
        self:DestroyTAEffects()
    end,

    OnMotionHorzEventChange = function( self, new, old )
        NSeaUnit.OnMotionHorzEventChange( self, new, old )

        self.TurretRotationEnabled = (old ~= 'None')

        -- blow smoke from the vents
        if new ~= old then
            self:DestroyMovementSmokeEffects()
            self:PlayMovementSmokeEffects(new)
        end
    end,

    PlayMovementSmokeEffects = function(self, type)
        local army, EffectTable, emit = self:GetArmy()

        if type == 'Stopping' then
            EffectTable = NomadsEffectTemplate.RailgunBoat_Stopping_Smoke
        elseif type == 'Stopped' then
            EffectTable = NomadsEffectTemplate.RailgunBoat_Stopped_Smoke
        else
            EffectTable = NomadsEffectTemplate.RailgunBoat_Moving_Smoke
        end

        for _, bone in self.SmokeEmitterBones do
            for k, v in EffectTable do
                emit = CreateAttachedEmitter( self, bone, army, v )
                self.SmokeEmitters:Add( emit )
                self.Trash:Add( emit )
            end
        end
    end,

    DestroyMovementSmokeEffects = function(self)
        self.SmokeEmitters:Destroy()
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
}

TypeClass = XNS0205