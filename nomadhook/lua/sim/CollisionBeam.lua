----------------------------------------------------------------------------------------------------
-- File     :  /lua/sim/collisionbeam.lua
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-- CollisionBeam is the simulation (gameplay-relevant) portion of a beam. It wraps a special effect
-- that may or may not exist depending on how the simulation is executing.
----------------------------------------------------------------------------------------------------
local NUtils = import('/lua/nomadsutils.lua')
local SetBeamsToColoured = NUtils.SetBeamsToColoured
local CreateAttachedEmitter = NUtils.CreateAttachedEmitterColoured
local CreateEmitterAtBone = NUtils.CreateEmitterAtBoneColoured

local oldCollisionBeam = CollisionBeam

---@class CollisionBeam  : oldCollisionBeam
CollisionBeam = Class(oldCollisionBeam) {
    --fill this table with emitters to recolour. Works on beams and trails for now
    EmittersToRecolour = {},

    --TODO:Remove this after relevant FAF PR is merged
    ---@param self CollisionBeam
    OnCreate = function(self)
        oldCollisionBeam.OnCreate(self)
        self.Army = self:GetArmy()
    end,

    ---@param self CollisionBeam
    OnEnable = function(self)
        SetBeamsToColoured(self, self.EmittersToRecolour)
        oldCollisionBeam.OnEnable(self)
    end,

    ---@param self CollisionBeam
    ---@param weapon string
    SetParentWeapon = function(self, weapon)
        oldCollisionBeam.SetParentWeapon(self, weapon)
        self.ColourIndex = self.unit.ColourIndex or false
    end,

    --completely unchanged, just put here to allow the imported functions to override the engine functions.
    ---@param self CollisionBeam
    CreateBeamEffects = function(self)
        for k, y in self.FxBeamStartPoint do
            local fx = CreateAttachedEmitter(self, 0, self.Army, y):ScaleEmitter(self.FxBeamStartPointScale)
            table.insert(self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end
        for k, y in self.FxBeamEndPoint do
            local fx = CreateAttachedEmitter(self, 1, self.Army, y):ScaleEmitter(self.FxBeamEndPointScale)
            table.insert(self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end
        if table.getn(self.FxBeam) ~= 0 then
            local fxBeam = CreateBeamEmitter(self.FxBeam[Random(1, table.getn(self.FxBeam))], self.Army)
            AttachBeamToEntity(fxBeam, self, 0, self.Army)

            -- collide on start if it's a continuous beam
            local weaponBlueprint = self.Weapon:GetBlueprint()
            local bCollideOnStart = weaponBlueprint.BeamLifetime <= 0
            self:SetBeamFx(fxBeam, bCollideOnStart)

            table.insert(self.BeamEffectsBag, fxBeam)
            self.Trash:Add(fxBeam)
        else
            LOG('*ERROR: THERE IS NO BEAM EMITTER DEFINED FOR THIS COLLISION BEAM ', repr(self.FxBeam))
        end
    end,

    --completely unchanged, just put here to allow the imported functions to override the engine functions.
    ---@param self CollisionBeam
    ---@param army Army
    ---@param EffectTable table[]
    ---@param EffectScale number
    CreateImpactEffects = function(self, army, EffectTable, EffectScale)
        local emit = nil
        EffectTable = EffectTable or {}
        EffectScale = EffectScale or 1
        for k, v in EffectTable do
            emit = CreateEmitterAtBone(self,1,army,v)
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale)
            end
        end
    end,

    --completely unchanged, just put here to allow the imported functions to override the engine functions.
    ---@param self CollisionBeam
    ---@param army Army
    ---@param EffectTable table[]
    ---@param EffectScale number
    CreateTerrainEffects = function(self, army, EffectTable, EffectScale)
        local emit = nil
        for k, v in EffectTable do
            emit = CreateAttachedEmitter(self,1,army,v)
            table.insert(self.TerrainEffectsBag, emit)
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale)
            end
        end
    end,
}
