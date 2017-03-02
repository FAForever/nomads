-- T2 missile launcher

local AddBombardModeToUnit = import('/lua/nomadsutils.lua').AddBombardModeToUnit
local Buff = import('/lua/sim/buff.lua')
local SupportedArtilleryWeapon = import('/lua/nomadsutils.lua').SupportedArtilleryWeapon
local NAmphibiousUnit = import('/lua/nomadsunits.lua').NAmphibiousUnit
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon1
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')
local SlowHover = import('/lua/defaultunits.lua').SlowHoverLandUnit

TacticalMissileWeapon1 = SupportedArtilleryWeapon( TacticalMissileWeapon1 )

NAmphibiousUnit = AddBombardModeToUnit(NAmphibiousUnit)

INU2003 = Class(NAmphibiousUnit, SlowHover) {
    Weapons = {
        MainGun = Class(TacticalMissileWeapon1) {

            FxMuzzleFlashScale = 0.35,

            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = TacticalMissileWeapon1.CreateProjectileAtMuzzle(self, muzzle)
                local layer = self.unit:GetCurrentLayer()
                if layer == 'Sub' or layer == 'Seabed' then   -- add under water effects
                    EffectUtilities.CreateBoneEffects( self.unit, muzzle, self.unit:GetArmy(), NomadsEffectTemplate.TacticalMissileMuzzleFxUnderWaterAddon )
                end
                return proj
            end,
        },
    },

    OnCreate = function(self)
        -- create buff used to reduce range under water
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

        SetBombardmentMode = function(self, enable, changedByTransport)
        NAmphibiousUnit.SetBombardmentMode(self, enable, changedByTransport)
        self:SetScriptBit('RULEUTC_WeaponToggle', enable)
    end,

    OnScriptBitSet = function(self, bit)
        NAmphibiousUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
            self.SetBombardmentMode(self, true, false)
        end
    end,

    OnScriptBitClear = function(self, bit)
        NAmphibiousUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
            self.SetBombardmentMode(self, false, false)
        end
    end,
    
}

TypeClass = INU2003
