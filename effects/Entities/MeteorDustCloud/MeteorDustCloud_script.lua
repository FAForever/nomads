local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

---@class MeteorDustCloud : EmitterProjectile
MeteorDustCloud = Class(EmitterProjectile) {
    FxTrails = NomadsEffectTemplate.MeteorSmokeRing,
}
TypeClass = MeteorDustCloud