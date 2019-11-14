
-- Hook AirUnit for Blackhole kills
local oldAirUnit = AirUnit

AirUnit = Class(oldAirUnit) {

    OnKilled = function(self, instigator, type, overkillRatio)
        -- if killed by black hole then suck in unit regardless of flying or not
        if self:WasUnitKilledByBlackhole(type) then
            self.DeathBounce = 1
            MobileUnit.OnKilled(self, instigator, type, overkillRatio)
        else
            oldAirUnit.OnKilled(self, instigator, type, overkillRatio)
        end
    end,

}

-- Fix problems with aircraft carriers handling transports inside transports.
local oldAircraftCarrier = AircraftCarrier
AircraftCarrier = Class(oldAircraftCarrier) {
    OnKilled = function(self, instigator, type, overkillRatio)
        --self:SaveCargoMass() --no need to run this twice
        self:DetachCarrierCargo()
        oldAircraftCarrier.OnKilled(self, instigator, type, overkillRatio)
    end,

    -- This is a copy of DetachCargo, saved so that no crazy patches to the base game disrupt this functionality.
    DetachCarrierCargo = function(self)
        local cargo = self:GetCargo()
        for _, unit in cargo do
            if EntityCategoryContains(categories.TRANSPORTATION, unit) then -- Kill the contents of a transport in a transport, however that happened
                for k, subUnit in unit:GetCargo() do
                    subUnit:Kill()
                end
            end
            unit:DetachFrom()
        end
    end,

}
