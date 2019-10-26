local EMPMissile = import('/lua/nomadsprojectiles.lua').EMPMissile
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

NEmpMissile1 = Class(EMPMissile) {

    OnCreate = function(self, inWater)
        self.TargetSpread = 10
        self.TargetPos = self:GetCurrentTargetPosition()
        self.TargetPos[1] = self.TargetPos[1] + RandomFloat(-self.TargetSpread,self.TargetSpread)
        self.TargetPos[3] = self.TargetPos[3] + RandomFloat(-self.TargetSpread,self.TargetSpread)
        EMPMissile.OnCreate(self, inWater)
        self:ForkThread(self.MovementThread)        
    end,

    
    MovementThread = function(self)        
        self.WaitTime = 0.1
        self:SetNewTargetGround(self.TargetPos)
        self:SetTurnRate(8)
        WaitSeconds(0.3)        
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(1)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > 50 then        
            WaitSeconds(2)
            self:SetTurnRate(20)
        elseif dist > 64 and dist <= 107 then
            self:SetTurnRate(30)
            WaitSeconds(1.5)
            self:SetTurnRate(30)
        elseif dist > 21 and dist <= 53 then
            WaitSeconds(0.3)
            self:SetTurnRate(50)
        elseif dist > 0 and dist <= 21 then          
            self:SetTurnRate(100)   
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