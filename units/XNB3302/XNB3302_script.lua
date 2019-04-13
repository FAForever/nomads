-- T3 sonar

local NRadarUnit = import('/lua/nomadsunits.lua').NRadarUnit
local AddIntelOvercharge = import('/lua/nomadsutils.lua').AddIntelOvercharge
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NRadarUnit = AddIntelOvercharge( NRadarUnit )

XNB3302 = Class(NRadarUnit) {

    OverchargeFxBone = 0,
    OverchargeChargingFxBone = 0,
    OverchargeExplosionFxBone = 0,

    OverchargeFx = NomadsEffectTemplate.T3SonarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T3SonarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T3SonarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T3SonarOverchargeExplosion,

    OnScriptBitSet = function(self, bit)
        NRadarUnit.OnScriptBitSet(self, bit)
        if bit == 1 then
            self:IntelOverchargeBeginCharging()
        end
    end,

    OnScriptBitClear = function(self, bit)
        NRadarUnit.OnScriptBitClear(self, bit)
        if bit == 1 then
            self:IntelOverchargeChargingCancelled()
        end
    end,

    OnIntelOverchargeBeginCharging = function(self)
        NRadarUnit.OnIntelOverchargeBeginCharging(self)
        self:SetScriptBit('RULEUTC_WeaponToggle', true)
    end,

    OnIntelOverchargeChargingCancelled = function(self)
        NRadarUnit.OnIntelOverchargeChargingCancelled(self)
        self:SetScriptBit('RULEUTC_WeaponToggle', false)
    end,

    OnIntelOverchargeFinishedCharging = function(self)
        NRadarUnit.OnIntelOverchargeFinishedCharging(self)
        self:RemoveToggleCap('RULEUTC_WeaponToggle')
    end,

    OnBeginIntelOvercharge = function(self)
        NRadarUnit.OnBeginIntelOvercharge(self)
        self:RemoveToggleCap('RULEUTC_WeaponToggle')
    end,

    OnFinishedIntelOvercharge = function(self)
        NRadarUnit.OnFinishedIntelOvercharge(self)

        local OverchargeRecoverTime = self:GetBlueprint().Intel.OverchargeRecoverTime or 0
        if OverchargeRecoverTime <= 0 then
            self:AddToggleCap('RULEUTC_WeaponToggle')
            self:SetScriptBit('RULEUTC_WeaponToggle', false)
        end
    end,

    OnFinishedIntelOverchargeRecovery = function(self)
        NRadarUnit.OnFinishedIntelOverchargeRecovery(self)

        self:AddToggleCap('RULEUTC_WeaponToggle')
        self:SetScriptBit('RULEUTC_WeaponToggle', false)
    end,
}

TypeClass = XNB3302