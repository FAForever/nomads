local Missile1 = import('/lua/nomadprojectiles.lua').Missile1

NMissileProj1 = Class(Missile1) {

    OnCreate = function(self, inWater)
        Missile1.OnCreate(self, inWater)

        self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(0.2)
        self:SetTurnRate(self:GetBlueprint().Physics.TurnRate)
    end,
}

TypeClass = NMissileProj1