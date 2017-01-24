-- TMD

local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local AddLights = import('/lua/nomadutils.lua').AddLights
local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local EffectTemplate = import('/lua/EffectTemplates.lua')
local HVFlakWeapon = import('/lua/nomadweapons.lua').HVFlakWeapon

NStructureUnit = AddLights(NStructureUnit)

INB4204 = Class(NStructureUnit) {
    Weapons = {
        Turret01 = Class(HVFlakWeapon) {

            IdleState = State(HVFlakWeapon.IdleState) {
                Main = function(self)
                    HVFlakWeapon.IdleState.Main(self)
                    self.unit:OnTargetLost()
                    self.IdleReloadThread = self:ForkThread(self.ReloadThread)
                    --self.DeadBaseThread = self:ForkThread( self.DeadBaseMonitor )
                end,
                
                
                ReloadThread = function(self)
                    WARN('waiting in idle reload')
                    WaitSeconds(1.5)
                    if not self.PlayingTAEffects then
                        WARN('idle reload time elapsed successfully')
                        self.counter = 0
                    else
                        WARN('idle reload time reset with counter: '..self.counter)
                    end
                    --self.RackSalvoFireReadyState.Main(self)
                end,
            },

            RackSalvoReloadState = State(HVFlakWeapon.RackSalvoReloadState) {
                Main = function(self)
                    ForkThread(function()
                        WARN("reloading")
                        WaitSeconds(1.5)
                        WARN('wait time elapsed')
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
                    if self.counter >= 5 then
                        WARN("reseting counter from: "..self.counter)
                        self.counter = 0
                        self.RackSalvoReloadState.Main(self)
                    else
                        WARN('fire counter: '..self.counter)
                        HVFlakWeapon.RackSalvoFiringState.Main(self)
                        self.unit:OnTargetAcquired()
                    end
                end,
                
            },
                
            ReloadThread = function(self) --i think this isnt needed
                WARN('waiting in idle reload')
                WaitSeconds(1.5)
                if not self.PlayingTAEffects then
                    WARN('idle reload time elapsed successfully')
                    self.counter = 0
                else
                    WARN('idle reload time reset with counter: '..self.counter)
                end
                --self.RackSalvoFireReadyState.Main(self)
            end,
            
            
        },
    },

    LightBones = {
        { 'Light1', }, { 'Light2', }, { 'Light3', }, { 'Light4', }, { 'Light5', }, { 'Light6', },
    },

    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
        self.TAEffectsBag = TrashBag()
        self.PlayingTAEffects = false
    end,

    OnDestroy = function(self)
        self:DestroyTAEffects()
        NStructureUnit.OnDestroy(self)
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
            local bone, army, emit = 'RadarDish', self:GetArmy()
            for k, v in NomadEffectTemplate.T2TacticalMissileDefenseTargetAcquired do
                emit = CreateAttachedEmitter(self, bone, army, v)
                self.TAEffectsBag:Add(emit)
                self.Trash:Add(emit)
            end
            self.PlayingTAEffects = true
        end
    end,

    DestroyTAEffects = function(self)
        self.TAEffectsBag:Destroy()
        self.PlayingTAEffects = false
    end,
}

TypeClass = INB4204