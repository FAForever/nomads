-- Nomads regular intel probe deployed

local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
--[[
the ability script tells the acu to launch the intel probe
the acu tells the command frigate to launch the intel probe

The command frigate creates the projectile and launches it.
The projectile creates the intel probe unit, attaches it to the projectile and returns that to the acu.

The acu sets itself to be the parent of that probe


When the probe is destroyed, it destroys the projectile if there is one
When the projectile is destroyed, it destroys the probe if there is one



--]]

XNY0001 = Class(NStructureUnit) {
    
    IntelData = {
        IntelProbe = {
            --Omni = false,
            Radar = 70,
            Sonar = 70,
            --Vision = false,
            --WaterVision = false,
        },
        IntelProbeAdvanced = {
            Omni = 35,
            Radar = 70,
            Sonar = 70,
            Vision = 35,
            WaterVision = 35,
        },
    },

    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.BuoyProjectile and not self.BuoyProjectile:BeenDestroyed() then
            self.BuoyProjectile:Destroy()
        end
        NStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    SetParentProjectile = function(self, projectile)
        self.BuoyProjectile = projectile
    end,
    
    SetIntel = function(self, probeType)
        local army = self:GetArmy()
        local intelType = probeType
        if not self.IntelData[probeType] then
            WARN('Nomads: Invalid intel probe type, assuming default')
            intelType = 'IntelProbe'
        end
        
        for k,v in self.IntelData do WARN(k) WARN(v) end
        for intel, radius in self.IntelData[intelType] do
            if radius and intel ~= 'Lifetime' then
                self:InitIntel(army, intel, radius)
                self:EnableIntel(intel)
            end
        end
    end,
    
    LifetimeThread = function(self)
        local duration = self.Lifetime
        WARN('wait time starting')
        if not duration then WARN('lifetime on probe missing, assuming 30 seconds') duration = 30 end
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

