local UnderwaterRailGunProj = import('/lua/nomadprojectiles.lua').UnderwaterRailGunProj

NUnderwaterRailProj3 = Class(UnderwaterRailGunProj) {

    FxAirUnitHitScale = 0.85,
    FxLandHitScale = 0.85,
    FxNoneHitScale = 0.85,
    FxPropHitScale = 0.85,
    FxProjectileHitScale = 0.85,
    FxProjectileUnderWaterHitScale = 0.85,
    FxShieldHitScale = 0.85,
    FxUnderWaterHitScale = 0.20,
    FxUnitHitScale = 0.85,
    FxWaterHitScale = 0.85,
    FxOnKilledScale = 0.85,
}

TypeClass = NUnderwaterRailProj3
