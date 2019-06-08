local Rocket1 = import('/lua/nomadsprojectiles.lua').Rocket1

NArtilleryRocket1 = Class(Rocket1) {
	OnCreate = function(self)
		Rocket1.OnCreate(self)
        self:SetTurnRate(50)
        self:TrackTarget(true)
        --self:ChangeMaxZigZag(25)
        --self:ChangeZigZagFrequency(10)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(0.5)
        local bp = self:GetBlueprint().Physics
        self:SetTurnRate(bp.TurnRate)
        self:ChangeMaxZigZag(bp.MaxZigZag)
        self:ChangeZigZagFrequency(bp.ZigZagFrequency)
        WaitSeconds(1.5)
        self:ChangeMaxZigZag(0)
        self:ChangeZigZagFrequency(0)
    end,
}

TypeClass = NArtilleryRocket1
