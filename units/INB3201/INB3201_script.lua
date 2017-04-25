-- t2 radar

local NRadarUnit = import('/lua/nomadsunits.lua').NRadarUnit
local AddIntelOvercharge = import('/lua/nomadsutils.lua').AddIntelOvercharge
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NRadarUnit = AddIntelOvercharge( NRadarUnit )

INB3201 = Class(NRadarUnit) {

    OverchargeFxBone = 'blinlight.001',
    OverchargeChargingFxBone = 'blinlight.001',
    OverchargeExplosionFxBone = 0,

    OverchargeFx = NomadsEffectTemplate.T2RadarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T2RadarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T2RadarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T2RadarOverchargeExplosion,

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

TypeClass = INB3201