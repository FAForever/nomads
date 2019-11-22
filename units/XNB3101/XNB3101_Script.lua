-- T1 radar

local NRadarUnit = import('/lua/nomadsunits.lua').NRadarUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

XNB3101 = Class(NRadarUnit) {

    IntelBoostFxBone = 'Blinklight',
    OverchargeExplosionFxBone = 0,

    IntelBoostFx = NomadsEffectTemplate.T1RadarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T1RadarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T1RadarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T1RadarOverchargeExplosion,

    OnStopBeingBuilt = function(self, builder, layer)
        NRadarUnit.OnStopBeingBuilt(self, builder, layer)
        --toggle the radar boost on, since it boosted is the same range as other factions radars
        self:SetScriptBit('RULEUTC_WeaponToggle', false)
    end,
}

TypeClass = XNB3101