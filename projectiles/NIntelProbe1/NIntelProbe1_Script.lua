-- The intel probe (all versions) is initially a projectile until it hits the ground. When it does a new entity is created that looks like the
-- projectile. This entity is responsible for the intel.

local Buoy1 = import('/lua/nomadsprojectiles.lua').Buoy1
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NIntelProbe1 = Class(Buoy1) {

    OnCreate = function(self)
        Buoy1.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)  -- so the probe can be shot down by TMD
        self:SetDestroyOnWater(true)
    end,
    
    AddProbeUnit = function(self, probeType)
        local pos = self:GetPosition()
        self.probeType = probeType
        self.ProbeUnit = CreateUnitHPR('XNY0001', self.Army, pos[1], pos[2], pos[3], 0, 0, 0 )
        self.ProbeUnit:AttachTo(self,0)
        self.ProbeUnit.Projectile = self
        self.ProbeUnit.probeType = probeType
        return self.ProbeUnit
    end,
    
    OnImpact = function(self, targetType, targetEntity)
        if targetType ~= 'Projectile' then
            self.Impacted = true
            self.ProbeUnit.IntelAllowed = true
            self.ProbeUnit:SetIntel()
            ForkThread(self.ProbeUnit.LifetimeThread, self.ProbeUnit)
        end
        Buoy1.OnImpact(self, targetType, targetEntity)
    end,
    
    OnDestroy = function(self)
        if self.ProbeUnit and not self.Impacted then
            self.ProbeUnit:Destroy()
        end
        Buoy1.OnDestroy(self)
    end,
}

TypeClass = NIntelProbe1
