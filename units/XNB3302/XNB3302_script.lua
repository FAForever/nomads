local NSonarUnit = import('/lua/nomadsunits.lua').NSonarUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

--- Tech 3 Sonar
---@class XNB3302 : NSonarUnit
XNB3302 = Class(NSonarUnit) {
    IntelBoostFxBone = 0,
    OverchargeChargingFxBone = 0,
    OverchargeExplosionFxBone = 0,

    IntelBoostFx = NomadsEffectTemplate.T3SonarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T3SonarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T3SonarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T3SonarOverchargeExplosion,
}
TypeClass = XNB3302