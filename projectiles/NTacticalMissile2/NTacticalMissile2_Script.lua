local NIFCruiseMissile = import('/lua/nomadsprojectiles.lua').NIFCruiseMissile
local RandomOffsetTrackingTarget = import('/lua/utilities.lua').RandomOffsetTrackingTarget

NTacticalMissile2 = Class(NIFCruiseMissile) {
	
	OnCreate = function(self, inWater)
        NIFCruiseMissile.OnCreate(self, inWater)
        self:SetCollisionShape('Sphere', 0, 0, 0, 3.0) --these travel at a high speed so cybran which uses beams can miss!
        self:SetTurnRate(0)
        self:ForkThread(self.StageThread)
    end,

    StageThread = function(self)
        WaitSeconds(1 +Random(0,100)*0.01)
        self:SetTurnRate(self:GetBlueprint().Physics.TurnRate)
		
        self:SetNewTargetGround(RandomOffsetTrackingTarget(self, 10))
    end,
    
    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > 50 then
            self:SetTurnRate(50)
        elseif dist > 40 and dist <= 213 then
            self:SetTurnRate(40)
            WaitSeconds(0.5)
            self:SetTurnRate(60)
        elseif dist > 20 and dist <= 40 then
            WaitSeconds(0.3)
            self:SetTurnRate(100)
        elseif dist > 0 and dist <= 20 then
            self:SetTurnRate(100)
            KillThread(self.MoveThread)
        end
    end,
}

TypeClass = NTacticalMissile2
