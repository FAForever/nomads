-- T3 radar

local NRadarUnit = import('/lua/nomadsunits.lua').NRadarUnit
local AddIntelOvercharge = import('/lua/nomadsutils.lua').AddIntelOvercharge
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NRadarUnit = AddIntelOvercharge( NRadarUnit )

INB3301 = Class(NRadarUnit) {

    OverchargeFxBone = 'blinlight.003',
    OverchargeChargingFxBone = 'blinlight.003',
    OverchargeExplosionFxBone = 0,

    OverchargeFx = NomadsEffectTemplate.T3RadarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T3RadarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T3RadarOverchargeCharging,
    OverchargeExplosionFx = NomadsEffectTemplate.T3RadarOverchargeExplosion,

    OnCreate = function(self)
        NRadarUnit.OnCreate(self)

        -- set up a rotator
        self.Rotator = CreateRotator(self, 'rotator', 'y')
        self.Rotator:SetAccel(5)
        self.Trash:Add(self.Rotator)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NRadarUnit.OnStopBeingBuilt(self, builder, layer)

        -- start the rotation
        self.Rotator:SetSpeed(10)
        self:ForkThread( self.RotatorThread )
    end,

    RotatorThread = function(self)
        local goal = 0
        while not self:BeenDestroyed() and not self:IsDead() do
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

TypeClass = INB3301