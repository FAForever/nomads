local TacticalMissile = import('/lua/nomadsprojectiles.lua').TacticalMissile
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

NTacticalMissile2 = Class(TacticalMissile) {
	
	OnCreate = function(self, inWater)
	    self.TargetSpread = 10
        TacticalMissile.OnCreate(self, inWater)
        self.TargetPos = self:GetCurrentTargetPosition()
        self.TargetPos[1] = self.TargetPos[1] + RandomFloat(-self.TargetSpread,self.TargetSpread)
        self.TargetPos[3] = self.TargetPos[3] + RandomFloat(-self.TargetSpread,self.TargetSpread)

        self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(1 +Random(0,100)*0.01)
        self:SetTurnRate(self:GetBlueprint().Physics.TurnRate)
		
        self:SetNewTargetGround(self.TargetPos)
    end,
}

TypeClass = NTacticalMissile2
