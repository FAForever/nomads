local NIFCruiseMissile = import('/lua/nomadsprojectiles.lua').NIFCruiseMissile
local RandomOffsetTrackingTarget = import('/lua/utilities.lua').RandomOffsetTrackingTarget

NTacticalMissile2 = Class(NIFCruiseMissile) {
    
    OnCreate = function(self, inWater)
        local pos = self:GetPosition()
        NIFCruiseMissile.OnCreate(self, inWater)
        self.TargetPos = RandomOffsetTrackingTarget(self, 10)
        self:SetCollisionShape('Sphere', 0, 0, 0, 3.0) --these travel at a high speed so cybran which uses beams can miss!
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
        if dist > 100 then
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
