-- T2 tank Brute

local AddAnchorAbilty = import('/lua/nomadsutils.lua').AddAnchorAbilty
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1

NLandUnit = AddAnchorAbilty(NLandUnit)


XNL0202 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(ParticleBlaster1) {},
    },

    HideBarrel1 = false,
    HideBarrel2 = false,
    HideBarrel3 = false,
    HideRocketLauncher = true,
    HideSensors = false,

    OnCreate = function(self)
        NLandUnit.OnCreate(self)
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
        for k, v in NomadsEffectTemplate.AntennaeLights1 do
            emit = CreateAttachedEmitter(self, bone, army, v)
            self.Trash:Add(emit)
        end
    end,

    EnableSpecialToggle = function(self)
        self:EnableAnchor(self)
    end,

    DisableSpecialToggle = function(self)
        self:DisableAnchor(self)
    end,
}

TypeClass = XNL0202