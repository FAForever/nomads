local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local UnderwaterRailgunWeapon1 = import('/lua/nomadsweapons.lua').UnderwaterRailgunWeapon1
local EMPGun = import('/lua/nomadsweapons.lua').EMPGun

NSeaUnit = AddNavalLights(NSeaUnit)

--- Tech 2 Railgun
---@class XNS0102 : NSeaUnit
XNS0102 = Class(NSeaUnit) {
    Weapons = {
        MainGun = Class(UnderwaterRailgunWeapon1) {},
        RearGun = Class(UnderwaterRailgunWeapon1) {},
        EMPGun = Class(EMPGun) {
            FxMuzzleFlash = import('/lua/nomadseffecttemplate.lua').EMPGunMuzzleFlash_Tank,
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = EMPGun.CreateProjectileAtMuzzle(self, muzzle)
                local data = self:GetBlueprint().DamageToShields
                if proj and not proj:BeenDestroyed() then
                    proj:PassData(data)
                end
                return proj
            end,
        },
    },

    DestructionPartsLowToss = { 'TMD_Yaw', },
    LightBone_Left = 'Antennae_2',
    LightBone_Right = 'Antennae_1',
    SmokeEmitterBones = { 'Reactor_Smoke', },

    ---@param self XNS0102
    OnCreate = function(self)
        NSeaUnit.OnCreate(self)
        self.SmokeEmitters = TrashBag()
    end,

    ---@param self XNS0102
    DestroyAllDamageEffects = function(self)
        self:DestroyMovementSmokeEffects()
        NSeaUnit.DestroyAllDamageEffects(self)
    end,

    ---@param self XNS0102
    ---@param instigator Unit
    ---@param damageType DamageType
    ---@param overkillRatio number
    OnKilled = function(self, instigator, damageType, overkillRatio)
        self:DestroyMovementSmokeEffects()
        NSeaUnit.OnKilled(self, instigator, damageType, overkillRatio)
    end,

    ---@param self XNS0102
    OnDestroy = function(self)
        self:DestroyMovementSmokeEffects()
        NSeaUnit.OnDestroy(self)
    end,

    ---@param self XNS0102
    ---@param new VerticalMovementState
    ---@param old VerticalMovementState
    OnMotionHorzEventChange = function( self, new, old )
        NSeaUnit.OnMotionHorzEventChange( self, new, old )

        self.TurretRotationEnabled = (old ~= 'None')

        -- blow smoke from the vents
        if new ~= old then
            self:DestroyMovementSmokeEffects()
            self:PlayMovementSmokeEffects(new)
        end
    end,

    ---@param self XNS0102
    ---@param damageType DamageType
    PlayMovementSmokeEffects = function(self, damageType)
        local EffectTable, emit

        if damageType == 'Stopping' then
            EffectTable = NomadsEffectTemplate.RailgunBoat_Stopping_Smoke
        elseif damageType == 'Stopped' then
            EffectTable = NomadsEffectTemplate.RailgunBoat_Stopped_Smoke
        else
            EffectTable = NomadsEffectTemplate.RailgunBoat_Moving_Smoke
        end

        for _, bone in self.SmokeEmitterBones do
            for k, v in EffectTable do
                emit = CreateAttachedEmitter( self, bone, self.Army, v )
                self.SmokeEmitters:Add( emit )
                self.Trash:Add( emit )
            end
        end
    end,

    ---@param self XNS0102
    DestroyMovementSmokeEffects = function(self)
        self.SmokeEmitters:Destroy()
    end,
}
TypeClass = XNS0102