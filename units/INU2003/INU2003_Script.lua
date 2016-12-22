# T2 missile launcher

local Buff = import('/lua/sim/buff.lua')
local AddAnchorAbilty = import('/lua/nomadutils.lua').AddAnchorAbilty
local SupportedArtilleryWeapon = import('/lua/nomadutils.lua').SupportedArtilleryWeapon
local NAmphibiousUnit = import('/lua/nomadunits.lua').NAmphibiousUnit
local TacticalMissileWeapon1 = import('/lua/nomadweapons.lua').TacticalMissileWeapon1
local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')

NAmphibiousUnit = AddAnchorAbilty(NAmphibiousUnit)
TacticalMissileWeapon1 = SupportedArtilleryWeapon( TacticalMissileWeapon1 )

INU2003 = Class(NAmphibiousUnit) {
    Weapons = {
        MainGun = Class(TacticalMissileWeapon1) {

            FxMuzzleFlashScale = 0.35,

            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = TacticalMissileWeapon1.CreateProjectileAtMuzzle(self, muzzle)
                local layer = self.unit:GetCurrentLayer()
                if layer == 'Sub' or layer == 'Seabed' then   # add under water effects
                    EffectUtilities.CreateBoneEffects( self.unit, muzzle, self.unit:GetArmy(), NomadEffectTemplate.TacticalMissileMuzzleFxUnderWaterAddon )
                end
                return proj
            end,
        },
    },

    OnCreate = function(self)
        # create buff used to reduce range under water
        local wep = self:GetWeaponByLabel('MainGun')
        if wep then
            self.OnInWaterBuff = 'INU2003_OnWater'
            local wbp = wep:GetBlueprint()
            local MaxRadiusUnderWater = wbp.MaxRadiusUnderWater or wbp.MaxRadius
            BuffBlueprint {
                Name = self.OnInWaterBuff,
                DisplayName = self.OnInWaterBuff,
                BuffType = string.upper(self.OnInWaterBuff),
                Stacks = 'REPLACE',
                Duration = -1,
                Affects = {
                    MaxRadius = {
                        Add = (MaxRadiusUnderWater - wbp.MaxRadius),
                    },
                },
            }
        else
            self.OnInWaterBuff = nil
        end

        NAmphibiousUnit.OnCreate(self)
    end,

    OnInWater = function(self)
        if self.OnInWaterBuff then
            Buff.ApplyBuff(self, self.OnInWaterBuff)
        end
        return NAmphibiousUnit.OnInWater(self)
    end,

    OnWater = function(self)
        if self.OnInWaterBuff then
            Buff.RemoveBuff(self, self.OnInWaterBuff, true)
        end
        return NAmphibiousUnit.OnWater(self)
    end,

    OnLand = function(self)
        if self.OnInWaterBuff then
            Buff.RemoveBuff(self, self.OnInWaterBuff, true)
        end
        return NAmphibiousUnit.OnLand(self)
    end,

    EnableSpecialToggle = function(self)
        self:EnableAnchor(self)
    end,

    DisableSpecialToggle = function(self)
        self:DisableAnchor(self)
    end,
}

TypeClass = INU2003