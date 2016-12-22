# T3 strategic sub

local Buff = import('/lua/sim/buff.lua')
local AddNavalLights = import('/lua/nomadutils.lua').AddNavalLights
local NSubUnit = import('/lua/nomadunits.lua').NSubUnit
local TorpedoWeapon1 = import('/lua/nomadweapons.lua').TorpedoWeapon1
local TacticalMissileWeapon1 = import('/lua/nomadweapons.lua').TacticalMissileWeapon1

NSubUnit = AddNavalLights(NSubUnit)

INS3002 = Class(NSubUnit) {
    Weapons = {
        MissileLauncher1 = Class(TacticalMissileWeapon1) {},
        Torpedo = Class(TorpedoWeapon1) {},
    },

    DeathThreadDestructionWaitTime = 2,
    LightBone_Left = 'Light1',
    LightBone_Right = 'Light2',

    OnCreate = function(self)
        # create buff used to reduce range under water
        local wep = self:GetWeaponByLabel('MissileLauncher1')
        if wep then
            self.OnInWaterBuff = 'INS3002_OnWater'
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

    OnStopBeingBuilt = function(self, builder, layer)
        NSubUnit.OnStopBeingBuilt(self, builder, layer)

        local layer = self:GetCurrentLayer()
        if layer == 'Water' then
            self:OnWater()
        elseif layer == 'Sub' then
            self:OnInWater()
        end
    end,

    OnInWater = function(self)
        if self.OnInWaterBuff then
            Buff.ApplyBuff(self, self.OnInWaterBuff)
        end
        return NSubUnit.OnInWater(self)
    end,

    OnWater = function(self)
        if self.OnInWaterBuff then
            Buff.RemoveBuff(self, self.OnInWaterBuff, true)
        end
        return NSubUnit.OnWater(self)
    end,

    OnLand = function(self)
        if self.OnInWaterBuff then
            Buff.RemoveBuff(self, self.OnInWaterBuff, true)
        end
        return NSubUnit.OnLand(self)
    end,
}

TypeClass = INS3002

