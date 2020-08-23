local Rocket2 = import('/lua/nomadsprojectiles.lua').Rocket1

NArtilleryRocket2 = Class(Rocket2) {
    OnCreate = function(self)
        Rocket2.OnCreate(self)
        self:SetTurnRate(0)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self:TrackTarget(true)
        self:ForkThread(self.MovementThread) 
    end,
    
    MovementThread = function(self)
        local bp = self:GetBlueprint().Physics
         WaitSeconds(0.1)
        self:SetTurnRate(8)
        WaitSeconds(0.3+Random(0,100)*0.01)
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(1)
        end
    end,
    
    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > 40 then        
            self:SetTurnRate(50)
            self:SetMaxSpeed(15)
        elseif dist > 10 and dist <= 25 then
            self:SetTurnRate(75)
            self:SetMaxSpeed(12)
        elseif dist > 5 and dist <= 15 then
            self:SetTurnRate(100)
            self:SetMaxSpeed(9)
        elseif dist > 0 and dist <= 5 then          
            self:SetTurnRate(125)
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

TypeClass = NArtilleryRocket2
