local NMissileProj2 = import('/projectiles/NMissileProj2/NMissileProj2_script.lua').NMissileProj2

NMissileProj2_aa = Class(NMissileProj2) {

    OnCreate = function(self, inWater)
        NMissileProj2.OnCreate(self, inWater)

        self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(0.2)
        self:SetTurnRate(self:GetBlueprint().Physics.TurnRate)
    end,
}

TypeClass = NMissileProj2_aa