-- T2 railgun boat

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local UnderwaterRailgunWeapon1 = import('/lua/nomadsweapons.lua').UnderwaterRailgunWeapon1
local EMPGun = import('/lua/nomadsweapons.lua').EMPGun
local Utilities = import('/lua/utilities.lua')

NSeaUnit = AddNavalLights(NSeaUnit)

xns0102 = Class(NSeaUnit) {
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
    

    OnCreate = function(self)
        NSeaUnit.OnCreate(self)
        self.SmokeEmitters = TrashBag()
    end,

    DestroyAllDamageEffects = function(self)
        self:DestroyMovementSmokeEffects()
        NSeaUnit.DestroyAllDamageEffects(self)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self:DestroyMovementSmokeEffects()
        NSeaUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnDestroy = function(self)
        self:DestroyMovementSmokeEffects()
        NSeaUnit.OnDestroy(self)
    end,

    OnMotionHorzEventChange = function( self, new, old )
        NSeaUnit.OnMotionHorzEventChange( self, new, old )

        self.TurretRotationEnabled = (old ~= 'None')

        -- blow smoke from the vents
        if new ~= old then
            self:DestroyMovementSmokeEffects()
            self:PlayMovementSmokeEffects(new)
        end
    end,

    PlayMovementSmokeEffects = function(self, type)
        local EffectTable, emit

        if type == 'Stopping' then
            EffectTable = NomadsEffectTemplate.RailgunBoat_Stopping_Smoke
        elseif type == 'Stopped' then
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

    DestroyMovementSmokeEffects = function(self)
        self.SmokeEmitters:Destroy()
    end,
}

TypeClass = xns0102