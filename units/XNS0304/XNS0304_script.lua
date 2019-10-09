-- T3 strategic sub

local Buff = import('/lua/sim/buff.lua')
local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSubUnit = import('/lua/nomadsunits.lua').NSubUnit
local TorpedoWeapon1 = import('/lua/nomadsweapons.lua').TorpedoWeapon1
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon1

NSubUnit = AddNavalLights(NSubUnit)

XNS0304 = Class(NSubUnit) {
    Weapons = {
        MissileLauncher1 = Class(TacticalMissileWeapon1) {},
        Torpedo = Class(TorpedoWeapon1) {},
    },

    DeathThreadDestructionWaitTime = 2,
    LightBone_Left = 'Light1',
    LightBone_Right = 'Light2',

    OnCreate = function(self)
        -- create buff used to reduce range under water
        local wep = self:GetWeaponByLabel('MissileLauncher1')
        if wep then
            self.OnInWaterBuff = 'XNS0304_OnWater'
            local wbp = wep:GetBlueprint()
            local MaxRadiusUnderWater = wbp.MaxRadiusUnderWater or wbp.MaxRadius
            BuffBlueprint {
                Name = self.OnInWaterBuff,
                DisplayName = self.OnInWaterBuff,
                BuffType = string.upper(self.OnInWaterBuff),
                Stacks = 'REPLACE',
                Duration = -1,
                Affects = {
                    MaxRadiusSpecifiedWeapons = {
                        Add = (MaxRadiusUnderWater - wbp.MaxRadius),
                    },
                },
            }
        else
            self.OnInWaterBuff = nil
        end

        NSubUnit.OnCreate(self)
    end,

    OnLayerChange = function(self, new, old)
        NSubUnit.OnLayerChange(self, new, old)
        if new == 'Water' then
            if self.OnInWaterBuff then
                Buff.RemoveBuff(self, self.OnInWaterBuff, true)
            end
        elseif new == 'Sub' or new == 'Seabed' then
            if self.OnInWaterBuff then
                Buff.ApplyBuff(self, self.OnInWaterBuff)
            end
        end
    end,
}

TypeClass = XNS0304

