local FusionMissile = import('/lua/nomadprojectiles.lua').FusionMissile

NFusionMissile1 = Class(FusionMissile) {

    OnCreate = function(self, inWater)
        FusionMissile.OnCreate(self, inWater)

        self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(2.2)
        self:SetTurnRate(self:GetBlueprint().Physics.TurnRate)
    end,
}

TypeClass = NFusionMissile1