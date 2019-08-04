-- T2 field enginer

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NConstructionUnit = import('/lua/nomadsunits.lua').NConstructionUnit
local HVFlakWeapon = import('/lua/nomadsweapons.lua').HVFlakWeapon

XNL0209 = Class(NConstructionUnit) {
    Weapons = {
        MainGun = Class(HVFlakWeapon) {
            IdleState = State(HVFlakWeapon.IdleState) { --TODO: refactor this so all the counting is done in the HVFlakWeapon and here you just set parameters
                Main = function(self)
                    HVFlakWeapon.IdleState.Main(self)
                    self.unit:OnTargetLost()
                    if self.IdleReloadThread then
                        KillThread(self.IdleReloadThread)
                    end
                    self.IdleReloadThread = self:ForkThread(self.ReloadThread)
                end,


                ReloadThread = function(self)
                    WaitSeconds(1.4)
                    if not self.PlayingTAEffects then
                        self.counter = 0
                    end
                end,
            },

            RackSalvoReloadState = State(HVFlakWeapon.RackSalvoReloadState) {
                Main = function(self)
                    ForkThread(function()
                        WaitSeconds(1.4)
                        if not self or self:BeenDestroyed() then return end
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
                        self.counter = 0
                        self.RackSalvoReloadState.Main(self)
                    else
                        self:PlaySound(self.Audio.FireSpecial)
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

    TMDEffectBones = { 'TMD_Fx1', 'TMD_Fx2', },

    OnCreate = function(self)
        NConstructionUnit.OnCreate(self)
        self.TAEffectsBag = TrashBag()
        self.PlayingTAEffects = false
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
}

TypeClass = XNL0209