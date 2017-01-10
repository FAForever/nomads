do


local oldAirUnit = AirUnit

AirUnit = Class(oldAirUnit) {

    OnKilled = function(self, instigator, type, overkillRatio)
        -- if killed by black hole then suck in unit regardless of flying or not
        if self:DoOnKilledByBlackhole(type) then
            self.DeathBounce = 1
            if instigator and IsUnit(instigator) then
                instigator:OnKilledUnit(self)
            end
            MobileUnit.OnKilled(self, instigator, type, overkillRatio)
        else
            oldAirUnit.OnKilled(self, instigator, type, overkillRatio)
        end
    end,

    OnRunOutOfFuel = function(self)
        oldAirUnit.OnRunOutOfFuel(self)
        self:SetSpeedMult( math.pow(0.25,2) ) -- bug in SetSpeedMult fixed, adjusting value to keep same speed
    end,
}


end