local NIFOrbitalMissile = import('/lua/nomadsprojectiles.lua').NIFOrbitalMissile

NIFOrbitalMissile01 = Class(NIFOrbitalMissile) {
    TargetSpread = 10,--This controls the spread of the bombardment projectiles
}

TypeClass = NIFOrbitalMissile01

FxAirUnitHitScale = 0.95,
FxLandHitScale = 0.95,
FxNoneHitScale = 0.95,
FxPropHitScale = 0.95,
FxProjectileHitScale = 0.95,
FxProjectileUnderWaterHitScale = 0.95,
FxShieldHitScale = 0.95,
FxUnderWaterHitScale = 0.95 * 0.25,
FxUnitHitScale = 0.95,
FxWaterHitScale = 0.95,
FxOnKilledScale = 0.95,