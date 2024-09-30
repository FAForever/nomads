local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NMassFabricationUnit = import('/lua/nomadsunits.lua').NMassFabricationUnit

--- Tech 2 Mass Fabricator
---@class XNB1104 : NMassFabricationUnit
XNB1104 = Class(NMassFabricationUnit) {

    ActiveEffectsTemplate = NomadsEffectTemplate.T2MFAmbient,

    ---@param self XNB1104
    OnCreate = function(self)
        NMassFabricationUnit.OnCreate(self)
        self.ActiveEffectsBag = TrashBag()
    end,

    ---@param self XNB1104
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self, builder, layer)
        NMassFabricationUnit.OnStopBeingBuilt(self, builder, layer)
        local bones = { 'flashlight.001', 'flashlight.002', 'flashlight.003', 'flashlight.004', }
        local emit
        for _, bone in bones do
            for k, v in NomadsEffectTemplate.AntennaeLights1 do
                emit = CreateEmitterAtBone(self, bone, self.Army, v)
                self.Trash:Add( emit )
            end
        end
    end,

    ---@param self XNB1104
    OnDestroy = function(self)
        self:DestroyActiveEffects()
        NMassFabricationUnit.OnDestroy(self)
    end,

    ---@param self XNB1104
    PlayActiveAnimation = function(self)
        self:PlayActiveEffects()
        NMassFabricationUnit.PlayActiveAnimation(self)
    end,

    ---@param self XNB1104
    OnProductionPaused = function(self)
        self:DestroyActiveEffects()
        NMassFabricationUnit.OnProductionPaused(self)
    end,

    ---@param self XNB1104
    OnProductionUnpaused = function(self)
        self:PlayActiveEffects()
        NMassFabricationUnit.OnProductionUnpaused(self)
    end,

    ---@param self XNB1104
    PlayActiveEffects = function(self)
        local emit
        for k, v in self.ActiveEffectsTemplate do
            emit = CreateEmitterAtBone(self, 0, self.Army, v)
            self.ActiveEffectsBag:Add( emit )
            self.Trash:Add( emit )
        end
    end,

    ---@param self XNB1104
    DestroyActiveEffects = function(self)
        self.ActiveEffectsBag:Destroy()
    end,
}

TypeClass = XNB1104