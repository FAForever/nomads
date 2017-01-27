-- T2 mex

local NMassCollectionUnit = import('/lua/nomadsunits.lua').NMassCollectionUnit

INB1202 = Class(NMassCollectionUnit) {

    OnStartBuild = function(self, unitBeingBuilt, order)
        NMassCollectionUnit.OnStartBuild(self, unitBeingBuilt, order)
        if self.AnimationManipulator then
            self.AnimationManipulator:SetRate(0)
            self.AnimationManipulator:Destroy()
            self.AnimationManipulator = nil
        end
    end,


    OnKilled = function(self, instigator, type, overkillRatio)
        if self.TarmacBag.CurrentBP['AlbedoKilled'] then
            self.TarmacBag.CurrentBP.Albedo = self.TarmacBag.CurrentBP.AlbedoKilled
        end
        NMassCollectionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    PlayActiveAnimation = function(self)
        NMassCollectionUnit.PlayActiveAnimation(self)
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
        self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationOpen, true)
        self.AnimationManipulator:SetAnimationFraction(0.5)
    end,

    OnProductionPaused = function(self)
        NMassCollectionUnit.OnProductionPaused(self)
        if self.AnimationManipulator then
            self.AnimationManipulator:SetRate(0)
        end
    end,

    OnProductionUnpaused = function(self)
        NMassCollectionUnit.OnProductionUnpaused(self)
        if self.AnimationManipulator then
            self.AnimationManipulator:SetRate(1)
        end
    end,
}

TypeClass = INB1202