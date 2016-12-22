local EMPMissile = import('/lua/nomadprojectiles.lua').EMPMissile

NEmpMissile2 = Class(EMPMissile) {

    OnCreate = function(self, inWater)
        EMPMissile.OnCreate(self, inWater)

        self:SetTurnRate(0)
        self:ChangeMaxZigZag(0)
        self:ChangeZigZagFrequency(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(2)
        local bp = self:GetBlueprint().Physics
        self:SetTurnRate(bp.TurnRate)
        self:ChangeMaxZigZag(bp.MaxZigZag)
        self:ChangeZigZagFrequency(bp.ZigZagFrequency)
        WaitSeconds(2.1)
        self:SetTurnRate(0)
        self:TrackTarget(false)
    end,
}

TypeClass = NEmpMissile2