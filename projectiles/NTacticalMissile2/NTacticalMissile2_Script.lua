local NIFArtilleryMissile = import('/lua/nomadsprojectiles.lua').NIFArtilleryMissile
local RandomOffsetTrackingTarget = import('/lua/utilities.lua').RandomOffsetTrackingTarget

NTacticalMissile2 = Class(NIFArtilleryMissile) {
    
    OnCreate = function(self, inWater)
        local pos = self:GetPosition()
        NIFArtilleryMissile.OnCreate(self, inWater)
        self.TargetPos = RandomOffsetTrackingTarget(self, 10)
        self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        local pos = self:GetPosition()
        self:SetNewTargetGround({pos[1],pos[2] + 70,pos[3]})
        WaitSeconds(1 +Random(0,100)*0.01)
        self:SetNewTargetGround({self.TargetPos[1],self.TargetPos[2],self.TargetPos[3]})
        self:SetTurnRateByDist()
    end,
    
    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > 200 then
            self:SetTurnRate(10)
        elseif dist > 150 and dist <= 200 then
            self:SetTurnRate(25)
        elseif dist > 00 and dist <= 150 then
            self:SetTurnRate(50)
        elseif dist > 50 and dist <= 100 then
            self:SetTurnRate(75)
        elseif dist > 0 and dist <= 50 then
            self:SetTurnRate(100)
            KillThread(self.MoveThread)
        end
    end,
}

TypeClass = NTacticalMissile2
