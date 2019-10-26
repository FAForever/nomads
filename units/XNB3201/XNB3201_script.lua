-- t2 radar

local NRadarUnit = import('/lua/nomadsunits.lua').NRadarUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

XNB3201 = Class(NRadarUnit) {

    IntelBoostFxBone = 'blinlight.001',
    OverchargeChargingFxBone = 'blinlight.001',
    OverchargeExplosionFxBone = 0,

    IntelBoostFx = NomadsEffectTemplate.T2RadarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T2RadarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T2RadarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T2RadarOverchargeExplosion,
}

TypeClass = XNB3201