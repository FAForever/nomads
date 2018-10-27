local ArcingTacticalMissile = import('/lua/nomadsprojectiles.lua').ArcingTacticalMissile

NTacticalMissile1_HighArc = Class(ArcingTacticalMissile) {
	OnCreate = function(self, inWater)
        ArcingTacticalMissile.OnCreate(self, inWater)

        self:SetTurnRate(0)
        self:ChangeMaxZigZag(0)
        self:ChangeZigZagFrequency(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(1.1)
        local bp = self:GetBlueprint().Physics
        self:SetTurnRate(bp.TurnRate)
        self:ChangeMaxZigZag(bp.MaxZigZag)
        self:ChangeZigZagFrequency(bp.ZigZagFrequency)
        WaitSeconds(1.3)
        self:ChangeMaxZigZag(0)
        self:ChangeZigZagFrequency(0)
    end,

}

TypeClass = NTacticalMissile1_HighArc
