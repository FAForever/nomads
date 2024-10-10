local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1

-- Upvalue for Perfomance
local CreateAttachedEmitter = CreateAttachedEmitter

--- Tech 2 Tank
---@class XNL0202 : NLandUnit
XNL0202 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(ParticleBlaster1) {},
    },

    HideBarrel1 = false,
    HideBarrel2 = false,
    HideBarrel3 = false,
    HideRocketLauncher = true,
    HideSensors = false,

    ---@param self XNL0202
    OnCreate = function(self)
        NLandUnit.OnCreate(self)
        if self.HideBarrel1 then self:HideBone('Barrel1', true) end
        if self.HideBarrel2 then self:HideBone('Barrel2', true) end
        if self.HideBarrel3 then self:HideBone('Barrel3', true) end
        if self.HideRocketLauncher then self:HideBone('RocketLauncher', true) end
        if self.HideSensors then self:HideBone('Sensors', true) end
    end,

    ---@param self XNL0202
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self, builder, layer)
        NLandUnit.OnStopBeingBuilt(self, builder, layer)
        if not self.HideSensors then self:CreateSensorEmitter() end
    end,

    ---@param self XNL0202
    CreateSensorEmitter = function(self)
        local emit
        for _, v in NomadsEffectTemplate.AntennaeLights1 do
            emit = CreateAttachedEmitter(self, 'Sensors', self.Army, v)
            self.Trash:Add(emit)
        end
    end,
}
TypeClass = XNL0202