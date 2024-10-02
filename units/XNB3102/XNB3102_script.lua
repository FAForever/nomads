local NSonarUnit = import('/lua/nomadsunits.lua').NSonarUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

--- Tech 1 Sonar
---@class XNB3102 : NSonarUnit
XNB3102 = Class(NSonarUnit) {

    IntelBoostFxBone = 0,
    OverchargeChargingFxBone = 0,
    OverchargeExplosionFxBone = 0,

    IntelBoostFx = NomadsEffectTemplate.T1SonarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T1SonarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T1SonarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T1SonarOverchargeExplosion,
}
TypeClass = XNB3102