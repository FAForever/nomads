-- T2 mobile missile launcher

--local AddBombardModeToUnit = import('/lua/nomadsutils.lua').AddBombardModeToUnit
--local SupportedArtilleryWeapon = import('/lua/nomadsutils.lua').SupportedArtilleryWeapon
local NAmphibiousUnit = import('/lua/nomadsunits.lua').NAmphibiousUnit
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon1
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')

--removed these for now since tracking projectiles dont have firing randomness, but in case we want to redo the bombard and arty support to change other things its nice to have a reminder of this here.
--TacticalMissileWeapon1 = SupportedArtilleryWeapon( TacticalMissileWeapon1 )
--NAmphibiousUnit = AddBombardModeToUnit(NAmphibiousUnit)

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
        NAmphibiousUnit.OnCreate(self)
        --save the modifier for max radius so we dont have to go into the blueprint every time.
        local wep = self:GetWeaponByLabel('MainGun')
        local bp = wep:GetBlueprint()
        self.MissileMaxRadiusWater = bp.MaxRadiusUnderWater
        self.MissileMaxRadius = bp.MaxRadius
    end,
    
    OnLayerChange = function(self, new, old)
        NAmphibiousUnit.OnLayerChange(self, new, old)
        --change the range of the missiles when underwater, needs a catch because if spawned in it can call this before fully initialized
        local wep = self:GetWeaponByLabel('MainGun')
        if wep then
            if new == 'Seabed' then
                wep:ChangeMaxRadius(self.MissileMaxRadiusWater or 45)
            else
                wep:ChangeMaxRadius(self.MissileMaxRadius or 45)
            end
        end
        
    end,

}

TypeClass = INU2003
