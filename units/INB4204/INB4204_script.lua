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
        -- BeamType = CollisionBeam,
        -- FxMuzzleFlash = NomadEffectTemplate.MissileMuzzleFx,
        -- FxBeamEndPoint = EffectTemplate.TDFHiroGeneratorHitLand,
        -- WARN(repr(EffectTemplate.TDFHiroGeneratorHitLand)),
        -- TerrainImpactScale = 1,
        -- FxBeamEndPointScale = 1,
        -- FxNoneHitScale = 1,
        -- FxImpactProp = EffectTemplate.TDFHiroGeneratorHitLand,
        -- FxImpactShield = EffectTemplate.TDFHiroGeneratorHitLand,    
        -- FxImpactNone = EffectTemplate.TDFHiroGeneratorHitLand,

        -- FxUnitHitScale = 1,
        -- FxLandHitScale = 1,
        -- FxWaterHitScale = 1,
        -- FxUnderWaterHitScale = 0.25,
        -- FxAirUnitHitScale = 1,
        -- FxPropHitScale = 1,
        -- FxShieldHitScale = 1,
        -- FxNoneHitScale = 1,

            IdleState = State(HVFlakWeapon.IdleState) {
                Main = function(self)
                    HVFlakWeapon.IdleState.Main(self)
                    self.unit:OnTargetLost()
                end,
            },

            RackSalvoReloadState = State(HVFlakWeapon.RackSalvoReloadState) {
                Main = function(self)
                    HVFlakWeapon.RackSalvoReloadState.Main(self)
                    self.unit:OnTargetLost()
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
                    HVFlakWeapon.RackSalvoFiringState.Main(self)
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