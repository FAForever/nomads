local FusionMissile = import('/lua/nomadsprojectiles.lua').FusionMissile

NFusionMissile2 = Class(FusionMissile) {

    OnCreate = function(self, inWater)
        FusionMissile.OnCreate(self, inWater)

        self:SetTurnRate(0)
        self:ChangeMaxZigZag(0)
        self:ChangeZigZagFrequency(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(1.7)
        local bp = self:GetBlueprint().Physics
        self:SetTurnRate(bp.TurnRate)
        self:ChangeMaxZigZag(bp.MaxZigZag)
        self:ChangeZigZagFrequency(bp.ZigZagFrequency)
        WaitSeconds(2.1)
        self:SetTurnRate(0)
        self:TrackTarget(false)
    end,
}

TypeClass = NFusionMissile2