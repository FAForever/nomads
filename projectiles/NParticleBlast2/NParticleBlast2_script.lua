local ParticleBlast = import('/lua/nomadsprojectiles.lua').ParticleBlast

NParticleBlast2 = Class(ParticleBlast) {
    FxAirUnitHitScale = 3,
    FxLandHitScale = 3,
    FxNoneHitScale = 3,
    FxPropHitScale = 3,
    FxProjectileHitScale = 3,
    FxProjectileUnderWaterHitScale = 3,
    FxShieldHitScale = 3,
    FxUnderWaterHitScale = 1,
    FxUnitHitScale = 3,
    FxWaterHitScale = 3,
    FxOnKilledScale = 3,
}

TypeClass = NParticleBlast2

