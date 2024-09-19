local NMassCollectionUnit = import('/lua/nomadsunits.lua').NMassCollectionUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NMassCollectionUnit = AddRapidRepair(NMassCollectionUnit)

--- Tech 3 Mass Extractor
---@class XNB1302 : NMassCollectionUnit
XNB1302 = Class(NMassCollectionUnit) {

    ---@param self XNB1302
    OnCreate = function(self)
        NMassCollectionUnit.OnCreate(self)

        -- set up animation manip
        self.AnimationManipulator = CreateAnimator(self):PlayAnim(self:GetBlueprint().Display.AnimationOpen, true)
        self.AnimationManipulator:SetRate(0)
        self.AnimationManipulator:SetAnimationFraction(0)
        self.Trash:Add(self.AnimationManipulator)

        self.ActiveEffectsBag = TrashBag()
    end,

    ---@param self XNB1302
    OnDestroy = function(self)
        self:StopActiveAnimation()
        self:DestroyActiveEffects()
        NMassCollectionUnit.OnDestroy(self)
    end,

    ---@param self XNB1302
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self, builder, layer)
        NMassCollectionUnit.OnStopBeingBuilt(self, builder, layer)

        self:PlayActiveAnimation()
        self:PlayActiveEffects()
    end,

    ---@param self XNB1302
    OnProductionPaused = function(self)
        NMassCollectionUnit.OnProductionPaused(self)

        self:StopActiveAnimation()
        self:DestroyActiveEffects()
    end,

    ---@param self XNB1302
    OnProductionUnpaused = function(self)
        NMassCollectionUnit.OnProductionUnpaused(self)

        self:PlayActiveAnimation()
        self:PlayActiveEffects()
    end,

    ---@param self XNB1302
    PlayActiveEffects = function(self)
        local emit, beam

        -- start emitters
        for k, v in NomadsEffectTemplate.T3MassExtractorActiveEffects do
            emit = CreateAttachedEmitter( self, -1, self.Army, v )
            self.ActiveEffectsBag:Add( emit )
            self.Trash:Add( emit )
        end

        -- start beams
        for k, v in NomadsEffectTemplate.T3MassExtractorActiveBeams do
            beam = CreateBeamEntityToEntity( self, 'muzzle', self, 0, self.Army, v )
            self.ActiveEffectsBag:Add( beam )
            self.Trash:Add( beam )
        end
    end,

    ---@param self XNB1302
    DestroyActiveEffects = function(self)
        self.ActiveEffectsBag:Destroy()
    end,

    ---@param self XNB1302
    PlayActiveAnimation = function(self)
        self.AnimationManipulator:SetRate(1)
    end,

    ---@param self XNB1302
    StopActiveAnimation = function(self)
        self.AnimationManipulator:SetRate(0)
    end,
}
TypeClass = XNB1302