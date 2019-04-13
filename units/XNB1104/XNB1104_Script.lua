-- T2 mass fab

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NMassFabricationUnit = import('/lua/nomadsunits.lua').NMassFabricationUnit

XNB1104 = Class(NMassFabricationUnit) {

    ActiveEffectsTemplate = NomadsEffectTemplate.T2MFAmbient,

    OnCreate = function(self)
        NMassFabricationUnit.OnCreate(self)
        self.ActiveEffectsBag = TrashBag()
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NMassFabricationUnit.OnStopBeingBuilt(self, builder, layer)
        local bones = { 'flashlight.001', 'flashlight.002', 'flashlight.003', 'flashlight.004', }
        local army, emit = self:GetArmy()
        for _, bone in bones do
            for k, v in NomadsEffectTemplate.AntennaeLights1 do
                emit = CreateEmitterAtBone(self, bone, army, v)
                self.Trash:Add( emit )
            end
        end
    end,

    OnDestroy = function(self)
        self:DestroyActiveEffects()
        NMassFabricationUnit.OnDestroy(self)
    end,

    PlayActiveAnimation = function(self)
        self:PlayActiveEffects()
        NMassFabricationUnit.PlayActiveAnimation(self)
    end,

    OnProductionPaused = function(self)
        self:DestroyActiveEffects()
        NMassFabricationUnit.OnProductionPaused(self)
    end,

    OnProductionUnpaused = function(self)
        self:PlayActiveEffects()
        NMassFabricationUnit.OnProductionUnpaused(self)
    end,

    PlayActiveEffects = function(self)
        local army, emit = self:GetArmy()
        for k, v in self.ActiveEffectsTemplate do
            emit = CreateEmitterAtBone(self, 0, army, v)
            self.ActiveEffectsBag:Add( emit )
            self.Trash:Add( emit )
        end
    end,

    DestroyActiveEffects = function(self)
        self.ActiveEffectsBag:Destroy()
    end,
}

TypeClass = XNB1104