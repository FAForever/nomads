local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local Buoy = import('/lua/sim/Buoy.lua').Buoy

NCameraBuoy = Class(Buoy) {

    ActiveFx = NomadsEffectTemplate.BuoyActive,
    DestroyedFx = NomadsEffectTemplate.BuoyDestroyed,
    LightsFx = NomadsEffectTemplate.BuoyLights,

    OnCreate = function(self, spec)

-- TODO: this, make buoys have a strategic icon
-- spec.StrategicIconName = '/textures/ui/common/game/strategicicons/icon_intelprobe1.dds'

        self.Omni = spec.Omni or false
        self.Radar = spec.Radar or false
        self.Sonar = spec.Sonar or false
        self.Vision = spec.Vision or false
        self.WaterVision = spec.WaterVision or false
        self.Radius = spec.Radius or 0

        if not self.Radius or self.Radius <= 0 or (not self.Omni and not self.Radar and not self.Sonar and not self.Vision and not self.WaterVision) then
            WARN('NCameraBuoy: No radius or no intel type specified')
        end

        Buoy.OnCreate(self, spec)
    end,

    ActiveThread = function(self)
        if self.Radius > 0 then
            local army = self:GetArmy()
            if self.Omni then
                self:InitIntel(army, 'Omni', self.Radius)
                self:EnableIntel('Omni')
            end
            if self.Radar then
                self:InitIntel(army, 'Radar', self.Radius)
                self:EnableIntel('Radar')
            end
            if self.Sonar then
                self:InitIntel(army, 'Sonar', self.Radius)
                self:EnableIntel('Sonar')
            end
            if self.Vision then
                self:InitIntel(army, 'Vision', self.Radius)
                self:EnableIntel('Vision')
            end
            if self.WaterVision then
                self:InitIntel(army, 'WaterVision', self.Radius)
                self:EnableIntel('WaterVision')
            end
        end
    end,

    DeactivateBuoy = function(self)
        if self.Omni then self:DisableIntel('Omni') end
        if self.Radar then self:DisableIntel('Radar') end
        if self.Sonar then self:DisableIntel('Sonar') end
        if self.Vision then self:DisableIntel('Vision') end
        if self.WaterVision then self:DisableIntel('WaterVision') end
        Buoy.DeactivateBuoy(self)
    end,
}
