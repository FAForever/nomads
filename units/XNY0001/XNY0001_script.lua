-- Nomads intel probe deployed

local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit

XNY0001 = Class(NStructureUnit) {
    
    IntelData = {
        IntelProbe = {
            Radar = 70,
            Sonar = 70,
        },
        IntelProbeAdvanced = {
            Omni = 35,
            Radar = 70,
            Sonar = 70,
            Vision = 35,
            WaterVision = 35,
        },
        IntelProbeCapacitor = {
            Radar = 100,
            Sonar = 100,
        },
        IntelProbeAdvancedCapacitor = {
            Omni = 55,
            Radar = 100,
            Sonar = 100,
            Vision = 55,
            WaterVision = 55,
        },
    },

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.Projectile and not self.Projectile:BeenDestroyed() then
            self.Projectile:Destroy()
        end
        NStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    SetIntel = function(self, probeType)
        if not self.IntelAllowed then return end
        local army = self:GetArmy()
        local intelType = probeType or self.probeType or 'IntelProbe'
        if self.CapacitorBoostEnabled then intelType = intelType..'Capacitor' end
        
        if not self.IntelData[intelType] then
            WARN('Nomads: Invalid intel probe type, assuming default')
            intelType = 'IntelProbe'
        end
        
        for intel, radius in self.IntelData[intelType] do
            if radius then
                self:InitIntel(army, intel, radius)
                self:EnableIntel(intel)
            else
                self:DisableIntel(intel)
            end
        end
    end,
    
    LifetimeThread = function(self)
        local duration = self.Lifetime or 30
        WaitSeconds(duration)
        self:Destroy()
    end,

    PointAntennaStraightUp = function(self)
        WaitSeconds(0.2)

        local orientation = self:GetOrientation()

        self:SetOrientation( {0,0,0,0}, true)
        for t=1, 10 do
            WaitTicks(5)
            self:SetOrientation( { t * 0.1 ,0,0,0}, true)
        end
    end,
}

TypeClass = XNY0001

