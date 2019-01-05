local FusionMissile = import('/lua/nomadsprojectiles.lua').FusionMissile

NFusionMissile1 = Class(FusionMissile) {

    OnCreate = function(self, inWater)
        FusionMissile.OnCreate(self, inWater)

        self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(1)
        local bp = self:GetBlueprint().Physics
        self:SetTurnRate(bp.TurnRate)
    end,
}

TypeClass = NFusionMissile1