local NAmphibiousUnit = import('/lua/nomadsunits.lua').NAmphibiousUnit
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon1
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')
local SlowHoverLandUnit = import('/lua/defaultunits.lua').SlowHoverLandUnit

-- Upvalue for Perfomance
local TrashBagAdd = TrashBag.Add

--- Tech 2 Mobile Missile Launcher
---@class XNL0111 : NAmphibiousUnit, SlowHoverLandUnit
XNL0111 = Class(NAmphibiousUnit, SlowHoverLandUnit) {
    Weapons = {
        MainGun = Class(TacticalMissileWeapon1) {

            FxMuzzleFlashScale = 0.35,

            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = TacticalMissileWeapon1.CreateProjectileAtMuzzle(self, muzzle)
                local layer = self.unit:GetCurrentLayer()
                if layer == 'Sub' or layer == 'Seabed' then   -- add under water effects
                    EffectUtilities.CreateBoneEffects( self.unit, muzzle, self.unit.Army, NomadsEffectTemplate.TacticalMissileMuzzleFxUnderWaterAddon )
                end
                return proj
            end,
        },
    },

    ---@param self XNL0111
    OnCreate = function(self)
        NAmphibiousUnit.OnCreate(self)
        --save the modifier for max radius so we dont have to go into the blueprint every time.
        local wep = self:GetWeaponByLabel('MainGun')
        local weaponBp = wep.Blueprint
        self.MissileMaxRadiusWater = weaponBp.MaxRadiusUnderWater
        self.MissileMaxRadius = weaponBp.MaxRadius
    end,

    ---@param self XNL0111
    ---@param new VerticalMovementState
    ---@param old VerticalMovementState
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
TypeClass = XNL0111