local Rocket1 = import('/lua/nomadsprojectiles.lua').Rocket1

NArtilleryRocket1 = Class(Rocket1) {
	OnCreate = function(self)
		Rocket1.OnCreate(self)
        self:SetTurnRate(0)
        self:TrackTarget(true)
        self:ForkThread(self.MovementThread) 
    end,
	
	MovementThread = function(self)
        self.WaitTime = 0.1
        self:SetTurnRate(8)
        WaitSeconds(0.3)    
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(1)
        end
    end,
	
	SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
		local bp = self:GetBlueprint().Physics
        if dist > 20 then        
            WaitSeconds(0.5)
            self:SetTurnRate(175)
        elseif dist > 10 and dist <= 20 then
            WaitSeconds(0.5)
            self:SetTurnRate(200)
        elseif dist > 5 and dist <= 10 then
            WaitSeconds(0.1)
            self:SetTurnRate(225)
        elseif dist > 0 and dist <= 5 then          
            self:SetTurnRate(250)   
            KillThread(self.MoveThread)         
        end
    end,        

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
}

TypeClass = NArtilleryRocket1
