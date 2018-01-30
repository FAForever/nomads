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
}


end