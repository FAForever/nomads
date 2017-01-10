-- T2 main tank

local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local SupportingArtilleryAbility = import('/lua/nomadutils.lua').SupportingArtilleryAbility
local NLandUnit = import('/lua/nomadunits.lua').NLandUnit
local ParticleBlaster1 = import('/lua/nomadweapons.lua').ParticleBlaster1

NLandUnit = SupportingArtilleryAbility( NLandUnit )

INU2005 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(ParticleBlaster1) {},
    },

    ArtillerySupportFxBone = 'ArtillerySupport',
    HideArtillerySupport = false,
    HideBarrel1 = false,
    HideBarrel2 = false,
    HideBarrel3 = false,
    HideRocketLauncher = true,
    HideSensors = false,

    OnCreate = function(self)
        NLandUnit.OnCreate(self)

        if self.HideArtillerySupport then self:HideBone('ArtillerySupport', true) end
        if self.HideBarrel1 then self:HideBone('Barrel1', true) end
        if self.HideBarrel2 then self:HideBone('Barrel2', true) end
        if self.HideBarrel3 then self:HideBone('Barrel3', true) end
        if self.HideRocketLauncher then self:HideBone('RocketLauncher', true) end
        if self.HideSensors then self:HideBone('Sensors', true) end
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NLandUnit.OnStopBeingBuilt(self, builder, layer)
        if not self.HideSensors then self:CreateSensorEmitter() end
    end,

    CreateSensorEmitter = function(self)
        local bone, army, emit = 'Sensors', self:GetArmy()
        for k, v in NomadEffectTemplate.AntennaeLights1 do
            emit = CreateAttachedEmitter(self, bone, army, v)
            self.Trash:Add(emit)
        end
    end,
}

TypeClass = INU2005