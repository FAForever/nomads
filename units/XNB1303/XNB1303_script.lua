local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NMassFabricationUnit = import('/lua/nomadsunits.lua').NMassFabricationUnit

--- Tech 3 Mass Fabricator
---@class XNB1303 : NMassFabricationUnit
XNB1303 = Class(NMassFabricationUnit) {

    ActiveEffectsTemplate = NomadsEffectTemplate.T3MFAmbient,

    ---@param self XNB1303
    OnCreate = function(self)
        NMassFabricationUnit.OnCreate(self)
        self.ActiveEffectsBag = TrashBag()
        self.Spinner = CreateRotator(self, 'Core', 'y', nil, 0, 10, 0)
        self.Trash:Add(self.Spinner)
    end,

    ---@param self XNB1303
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self, builder, layer)
        NMassFabricationUnit.OnStopBeingBuilt(self, builder, layer)
        self.Spinner:SetTargetSpeed(500)
    end,

    ---@param self XNB1303
    OnDestroy = function(self)
        self:DestroyActiveEffects()
        NMassFabricationUnit.OnDestroy(self)
    end,

    ---@param self XNB1303
    PlayActiveAnimation = function(self)
        self:PlayActiveEffects()
        NMassFabricationUnit.PlayActiveAnimation(self)
    end,

    ---@param self XNB1303
    OnProductionPaused = function(self)
        self:DestroyActiveEffects()
        NMassFabricationUnit.OnProductionPaused(self)
    end,

    ---@param self XNB1303
    OnProductionUnpaused = function(self)
        self:PlayActiveEffects()
        NMassFabricationUnit.OnProductionUnpaused(self)
    end,

    ---@param self XNB1303
    PlayActiveEffects = function(self)
        local emit
        for k, v in self.ActiveEffectsTemplate do
            emit = CreateEmitterAtBone(self, 'Core', self.Army, v)
            self.ActiveEffectsBag:Add( emit )
            self.Trash:Add( emit )
        end
    end,

    ---@param self XNB1303
    DestroyActiveEffects = function(self)
        self.ActiveEffectsBag:Destroy()
    end,
}

TypeClass = XNB1303