local NIFOrbitalMissile = import('/lua/nomadsprojectiles.lua').NIFOrbitalMissile

NIFOrbitalMissile01 = Class(NIFOrbitalMissile) {
    TargetSpread = 10,--This controls the spread of the bombardment projectiles
}

TypeClass = NIFOrbitalMissile01
