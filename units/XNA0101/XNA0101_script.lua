-- T1 Air scout

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit

XNA0101 = Class(NAirUnit) {
    DestructionPartsLowToss = {0},
    DestroySeconds = 7.5,

    OnStopBeingBuilt = function(self,builder,layer)
        NAirUnit.OnStopBeingBuilt(self,builder,layer)

        self.LandingAnimManip = CreateAnimator(self)
        self.LandingAnimManip:SetPrecedence(0)
        self.Trash:Add(self.LandingAnimManip)
        self.LandingAnimManip:PlayAnim(self:GetBlueprint().Display.AnimationLand):SetRate(1)
    end,

    OnMotionVertEventChange = function(self, new, old)
        NAirUnit.OnMotionVertEventChange(self, new, old)
        if (new == 'Down') then
            self.LandingAnimManip:SetRate(-1)
        elseif (new == 'Up') then
            self.LandingAnimManip:SetRate(1)
        end
    end,
}

TypeClass = XNA0101