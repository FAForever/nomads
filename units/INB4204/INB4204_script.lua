-- TMD

local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local AddLights = import('/lua/nomadutils.lua').AddLights
local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local MissileWeapon1 = import('/lua/nomadweapons.lua').MissileWeapon1

NStructureUnit = AddLights(NStructureUnit)

INB4204 = Class(NStructureUnit) {
    Weapons = {
        Turret01 = Class(MissileWeapon1) {

            IdleState = State(MissileWeapon1.IdleState) {
                Main = function(self)
                    MissileWeapon1.IdleState.Main(self)
                    self.unit:OnTargetLost()
                end,
            },

            RackSalvoReloadState = State(MissileWeapon1.RackSalvoReloadState) {
                Main = function(self)
                    MissileWeapon1.RackSalvoReloadState.Main(self)
                    self.unit:OnTargetLost()
                end,
            },

            RackSalvoFireReadyState = State(MissileWeapon1.RackSalvoFireReadyState ) {
                Main = function(self)
                    MissileWeapon1.RackSalvoFireReadyState.Main(self)
                    self.unit:OnTargetAcquired()
                end,
            },

            RackSalvoFiringState = State(MissileWeapon1.RackSalvoFiringState ) {
                Main = function(self)
                    MissileWeapon1.RackSalvoFiringState.Main(self)
                    self.unit:OnTargetAcquired()
                end,
            },
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