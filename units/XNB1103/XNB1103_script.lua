-- T1 mex

local NMassCollectionUnit = import('/lua/nomadsunits.lua').NMassCollectionUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NMassCollectionUnit = AddRapidRepair(NMassCollectionUnit)

XNB1103 = Class(NMassCollectionUnit) {

    OnStartBuild = function(self, unitBeingBuilt, order)
        NMassCollectionUnit.OnStartBuild(self, unitBeingBuilt, order)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(0)
        self.AnimationManipulator:Destroy()
        self.AnimationManipulator = nil
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
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(0)
    end,

    OnProductionUnpaused = function(self)
        NMassCollectionUnit.OnProductionUnpaused(self)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(1)
    end,
}

TypeClass = XNB1103


