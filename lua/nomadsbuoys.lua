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

NOrbitalStrikeBuoy = Class(Buoy) {
-- not used currently. Calls in an orbital strike from the frigate.
    ActiveFx = NomadsEffectTemplate.BuoyActive,
    DestroyedFx = NomadsEffectTemplate.BuoyDestroyed,
    LightsFx = NomadsEffectTemplate.BuoyLights,

    ActiveThread = function(self)
        local aiBrain = self:GetBrain()
        brain:OrbitalStrikeTarget( self.spec.Pos )
    end,
}

NIntelligenceBuoy = Class(NCameraBuoy) {

    ActiveFx = nil,
    DestroyedFx = nil,
    LightsFx = nil,

    -- TO make this buoy work a unit is used that contains the "SUPPORTARTILLERY" unit category. This is the only viable way to make
    -- supporting artillery work here.

    OnCreate = function(self, spec)
        NCameraBuoy.OnCreate(self, spec)

        -- we die when the probe unit dies or lifetime runs out, not because of enemy actions
        self:SetCanTakeDamage(false)
        self:SetCanBeKilled(false)

        local army = self:GetArmy()
        local x, y, z = unpack( self:GetPosition() )
        local Orientation = spec.Orientation or {0,0,0,0}
        local UnitBpId = spec.UnitBpId or 'iny0001'

        self.ProbeUnit = CreateUnitHPR( UnitBpId, army, x, y, z, 0,0,0 )
        self.ProbeUnit:SetOrientation( Orientation, true )
        self.ProbeUnit:SetParentBuoy( self )
        self.ProbeUnit:SetMaxHealth( self.Health )
        self.ProbeUnit:SetHealth( nil, self.Health )

        self.ProbeUnit:SetArtillerySupportRange( spec.ArtillerySupportRange or 5 )

        if spec.Omni then
            self.ProbeUnit:SetIntelRadius( 'Omni', spec.Radius )
        else
            self.ProbeUnit:SetIntelRadius( 'Omni', 0 )
            self.ProbeUnit:DisableIntel( 'Omni' )
        end
        if spec.Radar then
            self.ProbeUnit:SetIntelRadius( 'Radar', spec.Radius )
        else
            self.ProbeUnit:SetIntelRadius( 'Radar', 0 )
            self.ProbeUnit:DisableIntel( 'Radar' )
        end
        if spec.Sonar then
            self.ProbeUnit:SetIntelRadius( 'Sonar', spec.Radius )
        else
            self.ProbeUnit:SetIntelRadius( 'Sonar', 0 )
            self.ProbeUnit:DisableIntel( 'Sonar' )
        end
        if spec.Vision then
            self.ProbeUnit:SetIntelRadius( 'Vision', spec.Radius )
        else
            self.ProbeUnit:SetIntelRadius( 'Vision', 0 )
            self.ProbeUnit:DisableIntel( 'Vision' )
        end
        if spec.WaterVision then
            self.ProbeUnit:SetIntelRadius( 'WaterVision', spec.Radius )
        else
            self.ProbeUnit:SetIntelRadius( 'WaterVision', 0 )
            self.ProbeUnit:DisableIntel( 'WaterVision' )
        end
    end,

    OnKilled = function(self, instigator, damageType, overkill)
        if self.ProbeUnit and not self.ProbeUnit:BeenDestroyed() and not self.ProbeUnit:IsDead() then
            self.ProbeUnit:Kill()
        end
        NCameraBuoy.OnKilled(self, instigator, damageType, overkill)
    end,

    SetBuoyCollision = function(self, shape, centerx, centery, centerz, sizex, sizey, sizez, radius)
        -- don't need a collision box
    end,
}
