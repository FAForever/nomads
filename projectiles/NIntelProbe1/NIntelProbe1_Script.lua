-- The intel probe (all versions) is initially a projectile until it hits the ground. When it does a new entity is created that looks like the
-- projectile. This entity is responsible for the intel.

local Buoy1 = import('/lua/nomadsprojectiles.lua').Buoy1
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NIntelProbe1 = Class(Buoy1) {

    OnCreate = function(self)
        Buoy1.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)  -- so the probe can be shot down by TMD
    end,

    GetSpec = function(self, targetType, targetEntity)

        -- setting up additional buoy specifications
        local spec = Buoy1.GetSpec(self, targetType, targetEntity)
        spec = table.merged( spec, {
            Lifetime = self.Data.Lifetime or 60,

            ActiveFx = NomadsEffectTemplate.IntelProbeSurfaceActive,
            DestroyedFx = NomadsEffectTemplate.IntelProbeSurfaceDestroyed,
            LightsFx = NomadsEffectTemplate.IntelProbeSurfaceLights,

            Radius = self.Data.Radius or 10,
            Omni = self.Data.Omni or false,
            Radar = self.Data.Radar or true,
            Sonar = self.Data.Sonar or true,
            Vision = self.Data.Vision or false,
            WaterVision = self.Data.WaterVision or self.Data.Vision or false,
        })
        if not self.Data.CanBeKilledByAllFriendlyFire then   -- the army parameter determines what weapons can kill the buoy. If 'Army' is used
            spec['Army'] = spec.RealArmy                     -- then weapons with DamageFriendly turned on don't damage it
        end

        return spec
    end,

    CreateBuoy = function(self, spec, targetType, targetEntity)
        return import('/lua/nomadsbuoys.lua').NCameraBuoy(spec)
    end,
}

TypeClass = NIntelProbe1
