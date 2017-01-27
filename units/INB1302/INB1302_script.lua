-- T3 mex

local NMassCollectionUnit = import('/lua/nomadsunits.lua').NMassCollectionUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

INB1302 = Class(NMassCollectionUnit) {

    OnCreate = function(self)
        NMassCollectionUnit.OnCreate(self)

        -- set up animation manip
        self.AnimationManipulator = CreateAnimator(self):PlayAnim(self:GetBlueprint().Display.AnimationOpen, true)
        self.AnimationManipulator:SetRate(0)
        self.AnimationManipulator:SetAnimationFraction(0)
        self.Trash:Add(self.AnimationManipulator)

        self.ActiveEffectsBag = TrashBag()
    end,

    OnDestroy = function(self)
        self:StopActiveAnimation()
        self:DestroyActiveEffects()
        NMassCollectionUnit.OnDestroy(self)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NMassCollectionUnit.OnStopBeingBuilt(self, builder, layer)

        self:PlayActiveAnimation()
        self:PlayActiveEffects()
    end,

    OnProductionPaused = function(self)
        NMassCollectionUnit.OnProductionPaused(self)

        self:StopActiveAnimation()
        self:DestroyActiveEffects()
    end,

    OnProductionUnpaused = function(self)
        NMassCollectionUnit.OnProductionUnpaused(self)

        self:PlayActiveAnimation()
        self:PlayActiveEffects()
    end,

    PlayActiveEffects = function(self)
        local army, emit, beam = self:GetArmy()

        -- start emitters
        for k, v in NomadsEffectTemplate.T3MassExtractorActiveEffects do
            emit = CreateAttachedEmitter( self, -1, army, v )
            self.ActiveEffectsBag:Add( emit )
            self.Trash:Add( emit )
        end

        -- start beams
        for k, v in NomadsEffectTemplate.T3MassExtractorActiveBeams do
            beam = CreateBeamEntityToEntity( self, 'muzzle', self, 0, army, v )
            self.ActiveEffectsBag:Add( beam )
            self.Trash:Add( beam )
        end
    end,

    DestroyActiveEffects = function(self)
        self.ActiveEffectsBag:Destroy()
    end,

    PlayActiveAnimation = function(self)
        self.AnimationManipulator:SetRate(1)
    end,

    StopActiveAnimation = function(self)
        self.AnimationManipulator:SetRate(0)
    end,
}
TypeClass = INB1302