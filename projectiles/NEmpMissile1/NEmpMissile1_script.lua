local EMPMissile = import('/lua/nomadsprojectiles.lua').EMPMissile
local RandomOffsetTrackingTarget = import('/lua/utilities.lua').RandomOffsetTrackingTarget

NEmpMissile1 = Class(EMPMissile) {

    OnCreate = function(self, inWater)
        self:SetTurnRate(0)
        self:SetCollisionShape('Sphere', 0, 0, 0, 3.0)
        EMPMissile.OnCreate(self, inWater)
        self:ForkThread(self.MovementThread)        
    end,
    
    MovementThread = function(self)
        WaitSeconds(1.5)
        self:SetDestroyOnWater(true)
        self:SetNewTargetGround(RandomOffsetTrackingTarget(self, 10))
        self:SetTurnRate(8)
        WaitSeconds(0.3)        
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(1)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > 128 then       
            self:SetTurnRate(25)
        elseif dist > 64 and dist <= 128 then
            self:SetTurnRate(50)
        elseif dist > 16 and dist <= 64 then
            self:SetTurnRate(100)
        elseif dist > 0 and dist <= 16 then          
            self:SetTurnRate(200)   
            KillThread(self.MoveThread)         
        end
    end,        

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,

    OnExitWater = function(self)
        EMPMissile.OnExitWater(self)
        self:SetDestroyOnWater(true)
    end,
}

TypeClass = NEmpMissile1