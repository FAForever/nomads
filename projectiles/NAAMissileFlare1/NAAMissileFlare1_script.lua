local Flare1 = import('/lua/nomadsprojectiles.lua').Flare1

---@class NAAMissileFlare1 : Flare1
NAAMissileFlare1 = Class(Flare1) {
    DetectProjectileDistance = 5,
}

TypeClass = NAAMissileFlare1
