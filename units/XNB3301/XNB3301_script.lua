-- T3 radar

local NRadarUnit = import('/lua/nomadsunits.lua').NRadarUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

XNB3301 = Class(NRadarUnit) {

    IntelBoostFxBone = 'blinlight.003',
    OverchargeChargingFxBone = 'blinlight.003',
    OverchargeExplosionFxBone = 0,

    IntelBoostFx = NomadsEffectTemplate.T3RadarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T3RadarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T3RadarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T3RadarOverchargeExplosion,

    OnCreate = function(self)
        NRadarUnit.OnCreate(self)

        -- set up a rotator
        self.Rotator = CreateRotator(self, 'rotator', 'y')
        self.Rotator:SetAccel(5)
        self.Trash:Add(self.Rotator)
        
        local bp = self:GetBlueprint()
        self.OmniRadiusBoosted = bp.Intel.OmniRadiusBoosted
        self.OmniRadiusDefault = bp.Intel.OmniRadius
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NRadarUnit.OnStopBeingBuilt(self, builder, layer)

        -- start the rotation
        self.Rotator:SetSpeed(10)
        self:ForkThread( self.RotatorThread )
    end,

    RotatorThread = function(self)
        local goal = 0
        while not self:BeenDestroyed() and not self.Dead do
            if goal == 0 then goal = -160 else goal = 0 end
            self.Rotator:SetGoal( goal )
            WaitTicks(1)
            WaitFor(self.Rotator)
        end
    end,

    OnIntelDisabled = function(self)
        NRadarUnit.OnIntelDisabled(self)
        self.Rotator:SetSpeed(1)
    end,

    OnIntelEnabled = function(self)
        NRadarUnit.OnIntelEnabled(self)
        self.Rotator:SetSpeed(10)
    end,
    
    OnScriptBitClear = function(self, bit)
        NRadarUnit.OnScriptBitClear(self, bit)
        if bit == 1 then
            self:SetIntelRadius('Omni', self.OmniRadiusBoosted or 300)
        end
    end,
    
    OnScriptBitSet = function(self, bit)
        NRadarUnit.OnScriptBitSet(self, bit)
        if bit == 1 then
            self:SetIntelRadius('Omni', self.OmniRadiusDefault or 200)
        end
    end,

}

TypeClass = XNB3301