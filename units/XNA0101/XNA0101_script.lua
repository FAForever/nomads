local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit

-- Tech 1 Air Scout
---@class XNA0101 : NAirUnit
XNA0101 = Class(NAirUnit) {
    DestructionPartsLowToss = {0},
    DestroySeconds = 7.5,

    ---@param self XNA0101
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self,builder,layer)
        NAirUnit.OnStopBeingBuilt(self,builder,layer)

        self.LandingAnimManip = CreateAnimator(self)
        self.LandingAnimManip:SetPrecedence(0)
        self.Trash:Add(self.LandingAnimManip)
        self.LandingAnimManip:PlayAnim(self.Blueprint.Display.AnimationLand):SetRate(1)
    end,

    ---@param self XNA0101
    ---@param new any
    ---@param old any
    OnMotionVertEventChange = function(self, new, old)
        NAirUnit.OnMotionVertEventChange(self, new, old)
        if new == 'Down' then
            self.LandingAnimManip:SetRate(-1)
        elseif new == 'Up' or new == 'Top' then
            self.LandingAnimManip:SetRate(1)
        end
    end,
}

TypeClass = XNA0101