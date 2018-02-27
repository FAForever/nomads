local Entity = import('/lua/sim/entity.lua').Entity
local EffectTemplate = import('/lua/EffectTemplates.lua')
local util = import('utilities.lua')
local GetRandomFloat = util.GetRandomFloat
local GetRandomInt = util.GetRandomInt
local GetRandomOffset = util.GetRandomOffset
local GetRandomOffset2 = util.GetRandomOffset2
local EfctUtil = import('EffectUtilities.lua')
local CreateEffects = EfctUtil.CreateEffects
local CreateEffectsWithOffset = EfctUtil.CreateEffectsWithOffset
local CreateEffectsWithRandomOffset = EfctUtil.CreateEffectsWithRandomOffset
local CreateBoneEffects = EfctUtil.CreateBoneEffects
local CreateBoneEffectsOffset = EfctUtil.CreateBoneEffectsOffset
local CreateRandomEffects = EfctUtil.CreateRandomEffects
local ScaleEmittersParam = EfctUtil.ScaleEmittersParam

function CreateFlashCustom( obj, bone, army, scale, duration, textureflash, rampflash )
    CreateLightParticle( obj, bone, army, scale, duration, textureflash, rampflash )
end