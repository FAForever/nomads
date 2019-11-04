local StrategicMissile = import('/lua/nomadsprojectiles.lua').StrategicMissile


NTacticalNukeMissile = Class(StrategicMissile) {

    OnCreate = function(self, inWater)
        self:SetTurnRate(0)
        StrategicMissile.OnCreate(self, inWater)
        self:ForkThread(self.MovementThread)        
    end,

    MovementThread = function(self)

        -- wait till exitting water
        if self.IsUnderWater then
            while self and self.IsUnderWater do
                WaitTicks(1)
            end
        end

        -- wait some more before tracking target. This makes the projectile rotate and go straight for the target instead of finishing the arc
        WaitSeconds( self.Data.TrackTargetDelay or 0.3 )
        self:TrackTarget(true)
        if self.Data.TrackTargetProjectileVelocity and self.Data.TrackTargetProjectileVelocity > 0 then
            self:SetVelocity( self.Data.TrackTargetProjectileVelocity )
        end

        -- update turn rate
                
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
    
    OnExitWater = function(self)
        StrategicMissile.OnExitWater(self)
        self:SetDestroyOnWater(true)
    end,  

}

TypeClass = NTacticalNukeMissile
