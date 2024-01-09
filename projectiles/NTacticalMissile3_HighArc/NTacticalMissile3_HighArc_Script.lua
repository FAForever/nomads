local NIFArtilleryMissile = import('/lua/nomadsprojectiles.lua').NIFArtilleryMissile
local RandomOffsetTrackingTarget = import('/lua/utilities.lua').RandomOffsetTrackingTarget

NTacticalMissile3 = Class(NIFArtilleryMissile) {
    
    OnCreate = function(self, inWater)
        local pos = self:GetPosition()
        NIFArtilleryMissile.OnCreate(self, inWater)
        self.TargetPos = RandomOffsetTrackingTarget(self, 20)
	    self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(10)
        local pos = self:GetPosition()
        self:SetTurnRateByDist()
    end,
    
    SetTurnRateByDist = function(self)
	    local dist = self:GetDistanceToTarget()
        local pos = self:GetPosition()
        if dist > 600 then
            self:SetTurnRate(2)
        elseif dist > 450 and dist <= 600 then
            self:SetTurnRate(4)
        elseif dist > 300 and dist <= 450 then
            self:SetTurnRate(8)
        elseif dist > 100 and dist <= 300 then
            self:SetTurnRate(10)
			self:SetNewTargetGround({self.TargetPos[1],self.TargetPos[2],self.TargetPos[3]})
        elseif dist > 50 and dist <= 100 then
            self:SetTurnRate(30)
        elseif dist > 0 and dist <= 50 then
            self:SetTurnRate(50) --TODO:Speedup or turn into child projectile
            KillThread(self.MoveThread)
        end
    end,
}

TypeClass = NTacticalMissile3
