local ArcingTacticalMissile = import('/lua/nomadprojectiles.lua').ArcingTacticalMissile

NTacticalMissile4_HighArc = Class(ArcingTacticalMissile) {

    MovementThread = function(self)

        # wait till exitting water
        if self.IsUnderWater then
            while self and self.IsUnderWater do
                WaitTicks(1)
            end
        end

        # wait some more before tracking target. This makes the projectile rotate and go straight for the target instead of finishing the arc
        WaitSeconds( self.Data.TrackTargetDelay or 0.3 )
        self:TrackTarget(true)
        if self.Data.TrackTargetProjectileVelocity and self.Data.TrackTargetProjectileVelocity > 0 then
            self:SetVelocity( self.Data.TrackTargetProjectileVelocity )
        end

        # update turn rate
        while not self:BeenDestroyed() do

            dist, height = self:GetDistanceToTargetAndHeight()

            if dist > 40 then
                self:SetTurnRate(40)
                WaitTicks(19)

            elseif dist > 30 then
                self:SetTurnRate(50)
                WaitTicks(2)

            elseif dist > 0 and dist <= 30 then
                self:SetTurnRate(100)

            end

            WaitTicks(1)
        end
    end,
}

TypeClass = NTacticalMissile4_HighArc
