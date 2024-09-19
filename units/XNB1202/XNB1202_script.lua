local NMassCollectionUnit = import('/lua/nomadsunits.lua').NMassCollectionUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NMassCollectionUnit = AddRapidRepair(NMassCollectionUnit)

--- Tech 2 Mass Extractor
---@class XNB1202 : NMassCollectionUnit
XNB1202 = Class(NMassCollectionUnit) {

    ---@param self XNB1202
    ---@param unitBeingBuilt boolean
    ---@param order string
    OnStartBuild = function(self, unitBeingBuilt, order)
        NMassCollectionUnit.OnStartBuild(self, unitBeingBuilt, order)
        if self.AnimationManipulator then
            self.AnimationManipulator:SetRate(0)
            self.AnimationManipulator:Destroy()
            self.AnimationManipulator = nil
        end
    end,

    ---@param self XNB1202
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        if self.TarmacBag.CurrentBP['AlbedoKilled'] then
            self.TarmacBag.CurrentBP.Albedo = self.TarmacBag.CurrentBP.AlbedoKilled
        end
        NMassCollectionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    ---@param self XNB1202
    PlayActiveAnimation = function(self)
        NMassCollectionUnit.PlayActiveAnimation(self)
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
        self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationOpen, true)
        self.AnimationManipulator:SetAnimationFraction(0.5)
    end,

    ---@param self XNB1202
    OnProductionPaused = function(self)
        NMassCollectionUnit.OnProductionPaused(self)
        if self.AnimationManipulator then
            self.AnimationManipulator:SetRate(0)
        end
    end,

    ---@param self XNB1202
    OnProductionUnpaused = function(self)
        NMassCollectionUnit.OnProductionUnpaused(self)
        if self.AnimationManipulator then
            self.AnimationManipulator:SetRate(1)
        end
    end,
}

TypeClass = XNB1202