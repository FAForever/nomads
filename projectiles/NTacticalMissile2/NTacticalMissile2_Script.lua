local TacticalMissile = import('/lua/nomadsprojectiles.lua').TacticalMissile
local RandomOffsetTrackingTarget = import('/lua/utilities.lua').RandomOffsetTrackingTarget

NTacticalMissile2 = Class(TacticalMissile) {
	
	OnCreate = function(self, inWater)
        TacticalMissile.OnCreate(self, inWater)
        self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(1 +Random(0,100)*0.01)
        self:SetTurnRate(self:GetBlueprint().Physics.TurnRate)
		
        self:SetNewTargetGround(RandomOffsetTrackingTarget(self, 10))
    end,
}

TypeClass = NTacticalMissile2
