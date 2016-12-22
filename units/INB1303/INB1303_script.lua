# T3 mass fab

local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local NMassFabricationUnit = import('/lua/nomadunits.lua').NMassFabricationUnit

INB1303 = Class(NMassFabricationUnit) {

    ActiveEffectsTemplate = NomadEffectTemplate.T3MFAmbient,

    OnCreate = function(self)
        NMassFabricationUnit.OnCreate(self)
        self.ActiveEffectsBag = TrashBag()
        self.Spinner = CreateRotator(self, 'Core', 'y', nil, 0, 10, 0)
        self.Trash:Add(self.Spinner)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NMassFabricationUnit.OnStopBeingBuilt(self, builder, layer)
        self.Spinner:SetTargetSpeed(500)
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
            emit = CreateEmitterAtBone(self, 'Core', army, v)
            self.ActiveEffectsBag:Add( emit )
            self.Trash:Add( emit )
        end
    end,

    DestroyActiveEffects = function(self)
        self.ActiveEffectsBag:Destroy()
    end,
}

TypeClass = INB1303