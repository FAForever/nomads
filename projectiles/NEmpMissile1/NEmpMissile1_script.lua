local EMPMissile = import('/lua/nomadprojectiles.lua').EMPMissile

NEmpMissile1 = Class(EMPMissile) {

    OnCreate = function(self, inWater)
        EMPMissile.OnCreate(self, inWater)

        self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(2)
        self:SetTurnRate(self:GetBlueprint().Physics.TurnRate)
    end,
}

TypeClass = NEmpMissile1