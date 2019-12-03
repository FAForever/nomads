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
    },

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.Projectile and not self.Projectile:BeenDestroyed() then
            self.Projectile:Destroy()
        end
        NStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    SetIntel = function(self, probeType)
        local army = self:GetArmy()
        local intelType = probeType
        if not self.IntelData[probeType] then
            WARN('Nomads: Invalid intel probe type, assuming default')
            intelType = 'IntelProbe'
        end
        
        for intel, radius in self.IntelData[intelType] do
            if radius and intel ~= 'Lifetime' then
                self:InitIntel(army, intel, radius)
                self:EnableIntel(intel)
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

