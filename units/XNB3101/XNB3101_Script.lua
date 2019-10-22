-- T1 radar

local NRadarUnit = import('/lua/nomadsunits.lua').NRadarUnit
local AddIntelOvercharge = import('/lua/nomadsutils.lua').AddIntelOvercharge
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

--NRadarUnit = AddIntelOvercharge( NRadarUnit )

XNB3101 = Class(NRadarUnit) {

    OverchargeFxBone = 'Blinklight',
    OverchargeChargingFxBone = 'Blinklight',
    OverchargeExplosionFxBone = 0,

    OverchargeFx = NomadsEffectTemplate.T1RadarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T1RadarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T1RadarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T1RadarOverchargeExplosion,
    
    OnCreate = function(self)
        NRadarUnit.OnCreate(self)
        local bp = self:GetBlueprint()
        self.IntelBoostMult = bp.Intel.IntelBoostMult
        self.DefaultIntelRadius = bp.Intel.RadarRadius
    end,
    
    OnScriptBitSet = function(self, bit)
        NRadarUnit.OnScriptBitSet(self, bit)
        if bit == 1 then
            self:SetIntelRadius('Radar', (self.DefaultIntelRadius * self.IntelBoostMult) or 170)
            self:SetConsumptionPerSecondEnergy(50)
        end
    end,

    OnScriptBitClear = function(self, bit)
        NRadarUnit.OnScriptBitClear(self, bit)
        if bit == 1 then
            self:SetIntelRadius('Radar', self.DefaultIntelRadius or 115)
            self:SetConsumptionPerSecondEnergy(20)
        end
    end,
}

TypeClass = XNB3101