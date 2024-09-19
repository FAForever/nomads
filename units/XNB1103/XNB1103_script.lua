local NMassCollectionUnit = import('/lua/nomadsunits.lua').NMassCollectionUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NMassCollectionUnit = AddRapidRepair(NMassCollectionUnit)

--- Tech 1 Mass Extractor
---@class XNB1103 : NMassCollectionUnit
XNB1103 = Class(NMassCollectionUnit) {

    ---@param self XNB1103
    ---@param unitBeingBuilt boolean
    ---@param order string
    OnStartBuild = function(self, unitBeingBuilt, order)
        NMassCollectionUnit.OnStartBuild(self, unitBeingBuilt, order)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(0)
        self.AnimationManipulator:Destroy()
        self.AnimationManipulator = nil
    end,

    ---@param self XNB1103
    PlayActiveAnimation = function(self)
        NMassCollectionUnit.PlayActiveAnimation(self)
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
        self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationOpen, true)
        self.AnimationManipulator:SetAnimationFraction(0.5)
    end,

    ---@param self XNB1103
    OnProductionPaused = function(self)
        NMassCollectionUnit.OnProductionPaused(self)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(0)
    end,

    ---@param self XNB1103
    OnProductionUnpaused = function(self)
        NMassCollectionUnit.OnProductionUnpaused(self)
        if not self.AnimationManipulator then return end
        self.AnimationManipulator:SetRate(1)
    end,
}
TypeClass = XNB1103