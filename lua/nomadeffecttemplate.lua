local EffectTemplate = import('/lua/EffectTemplates.lua')
local EmtBpPath = '/effects/emitters/'
local EmtBpPathNomad = '/effects/emitters/'
local TableCat = import('/lua/utilities.lua').TableCat


--------------------------------------------------------------------------
--  Nomad Kinetic Cannon
--------------------------------------------------------------------------
-- Used on ACU, T1 tank destroyer, Crawler

KineticCannonMuzzleFlash = {
    EmtBpPath .. 'cannon_artillery_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_07_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_10_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_03_emit.bp',
}

KineticCannonTrail = {
    EmtBpPathNomad .. 'nomad_kineticcannon_trail02_emit.bp',
}

KineticCannonPolyTrail = EmtBpPath .. 'default_polytrail_04_emit.bp'

KineticCannonHitNone1 = {
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_03_emit.bp',  -- fast explosion
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_05_emit.bp',  -- smoke
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_06_emit.bp',  -- long explosion
}

KineticCannonHitLand1 = TableCat( KineticCannonHitNone1, {
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_07_emit.bp',  -- shockwave rings
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

KineticCannonHitWater1 = TableCat( KineticCannonHitNone1, {
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_07_emit.bp',  -- shockwave rings
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

KineticCannonHitUnit1 = TableCat( KineticCannonHitNone1, {
    EmtBpPath .. 'destruction_explosion_sparks_02_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

KineticCannonHitAirUnit1 = KineticCannonHitUnit1
KineticCannonHitShield1 = KineticCannonHitNone1
KineticCannonHitProjectile1 = KineticCannonHitUnit1
KineticCannonHitProp1 = KineticCannonHitUnit1
KineticCannonHitUnderWater1 = KineticCannonHitLand1

-- more dramatic effect for the T1 tank destroyer

KineticCannonPolyTrail2 = EmtBpPath .. 'nomad_kineticcannon_polytrail01.bp'

KineticCannonHitNone2 = TableCat( KineticCannonHitNone1, {
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_04_emit.bp',  -- short flames
})

KineticCannonHitLand2 = TableCat( KineticCannonHitLand1, {
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_04_emit.bp',  -- short flames
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_07_emit.bp',  -- shockwave rings
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

KineticCannonHitWater2 = KineticCannonHitWater1

KineticCannonHitUnit2 = TableCat( KineticCannonHitUnit1, {
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_04_emit.bp',  -- short flames
})

KineticCannonHitAirUnit2 = KineticCannonHitUnit2
KineticCannonHitShield2 = KineticCannonHitNone2
KineticCannonHitProjectile2 = KineticCannonHitUnit2
KineticCannonHitProp2 = KineticCannonHitUnit2
KineticCannonHitUnderWater2 = KineticCannonHitLand2

--------------------------------------------------------------------------
--  Nomad AP Cannon weapon
--------------------------------------------------------------------------
-- Used by ACU and SCU

APCannonMuzzleFlash = {
    EmtBpPath .. 'cannon_artillery_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_07_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_10_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_03_emit.bp',
}

APCannonTrail = {
--    EmtBpPathNomad .. 'nomad_apcannon_trail02_emit.bp',
}

APCannonPolyTrail = EmtBpPath .. 'nomad_apcannon_polytrail01_emit.bp'

APCannonHitNone1 = {
    EmtBpPathNomad .. 'nomad_apcannon_hit_01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_apcannon_hit_02_emit.bp',  -- small explosion
    EmtBpPathNomad .. 'nomad_apcannon_hit_04_emit.bp',  -- fire
    EmtBpPathNomad .. 'nomad_apcannon_hit_05_emit.bp',  -- color changing fast shockwave
}

APCannonHitLand1 = TableCat( APCannonHitNone1, {
    EmtBpPathNomad .. 'nomad_apcannon_hit_03_emit.bp',  -- shockwave rings
--    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

APCannonHitWater1 = TableCat( APCannonHitNone1, {
    EmtBpPathNomad .. 'nomad_apcannon_hit_03_emit.bp',  -- shockwave rings
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

APCannonHitUnit1 = TableCat( APCannonHitNone1, {
    EmtBpPath .. 'destruction_explosion_sparks_02_emit.bp',
--    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

APCannonHitAirUnit1 = APCannonHitUnit1
APCannonHitShield1 = APCannonHitNone1
APCannonHitProjectile1 = APCannonHitUnit1
APCannonHitProp1 = APCannonHitUnit1
APCannonHitUnderWater1 = APCannonHitLand1

-- a version with a DoT effect (only visuals)
APCannonMuzzleFlash2 = {
    EmtBpPath .. 'cannon_artillery_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_07_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_10_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_03_emit.bp',
}

APCannonTrail2 = {
    EmtBpPathNomad .. 'nomad_apcannon_trail02_emit.bp', -- whitish effect
}

APCannonPolyTrail2 = EmtBpPath .. 'nomad_apcannon_polytrail01_emit.bp'

APCannonHitNone2 = {
    EmtBpPathNomad .. 'nomad_apcannon_hit_01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_apcannon_hit_07_emit.bp',  -- small explosion
    EmtBpPathNomad .. 'nomad_apcannon_hit_06_emit.bp',  -- fire
    EmtBpPathNomad .. 'nomad_apcannon_hit_09_emit.bp',  -- color changing fast shockwave
}

APCannonHitLand2 = TableCat( APCannonHitNone2, {
    EmtBpPathNomad .. 'nomad_apcannon_hit_03_emit.bp',  -- shockwave rings
    EmtBpPathNomad .. 'nomad_apcannon_hit_08_emit.bp',  -- glow
})

APCannonHitWater2 = TableCat( APCannonHitNone2, {
    EmtBpPathNomad .. 'nomad_apcannon_hit_03_emit.bp',  -- shockwave rings
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

APCannonHitUnit2 = TableCat( APCannonHitNone2, {
    EmtBpPath .. 'destruction_explosion_sparks_02_emit.bp',
})

APCannonHitAirUnit2 = APCannonHitUnit2
APCannonHitShield2 = APCannonHitNone2
APCannonHitProjectile2 = APCannonHitUnit2
APCannonHitProp2 = APCannonHitUnit2
APCannonHitUnderWater2 = APCannonHitLand2

--------------------------------------------------------------------------
--  Nomad Dark Matter weapon
--------------------------------------------------------------------------
-- Used by T1 light tank and scout

DarkMatterWeaponMuzzleFlash = {
    EmtBpPath .. 'machinegun_muzzle_fire_01_emit.bp',
    EmtBpPath .. 'machinegun_muzzle_fire_02_emit.bp',
}

DarkMatterWeaponTrail = {}
DarkMatterWeaponPolyTrails = {
    EmtBpPathNomad .. 'nomad_DarkMatterWeapon_polytrail_01_emit.bp',
    EmtBpPathNomad .. 'nomad_DarkMatterWeapon_polytrail_02_emit.bp',
    EmtBpPathNomad .. 'nomad_DarkMatterWeapon_polytrail_03_emit.bp',
}

DarkMatterWeaponHitNone1 = {
--    EmtBpPathNomad .. 'nomad_DarkMatterWeapon_hit_01_emit.bp', -- splashes
    EmtBpPathNomad .. 'nomad_DarkMatterWeapon_hit_02_emit.bp', -- 'explosions'
}

DarkMatterWeaponHitLand1 = TableCat( DarkMatterWeaponHitNone1, {
})

DarkMatterWeaponHitUnit1 = TableCat( DarkMatterWeaponHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

DarkMatterWeaponHitAirUnit1 = DarkMatterWeaponHitNone1
DarkMatterWeaponHitShield1 = DarkMatterWeaponHitNone1
DarkMatterWeaponHitProjectile1 = DarkMatterWeaponHitUnit1
DarkMatterWeaponHitProp1 = DarkMatterWeaponHitUnit1
DarkMatterWeaponHitWater1 = DarkMatterWeaponHitLand1
DarkMatterWeaponHitUnderWater1 = DarkMatterWeaponHitNone1

-- Different effect

DarkMatterWeaponBeam2 = EmtBpPathNomad .. 'nomad_DarkMatterWeapon_beam02_emit.bp'

DarkMatterWeaponHitNone2 = {
    EmtBpPathNomad .. 'nomad_DarkMatterWeapon_hit_01_emit.bp', -- splashes
    EmtBpPathNomad .. 'nomad_DarkMatterWeapon_hit_02_emit.bp', -- black 'explosions'
    EmtBpPathNomad .. 'nomad_DarkMatterWeapon_hit_03_emit.bp',
}

DarkMatterWeaponHitLand2 = TableCat( DarkMatterWeaponHitNone2, {
})

DarkMatterWeaponHitUnit2 = TableCat( DarkMatterWeaponHitNone2, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

DarkMatterWeaponHitAirUnit2 = DarkMatterWeaponHitNone2
DarkMatterWeaponHitShield2 = DarkMatterWeaponHitNone2
DarkMatterWeaponHitProjectile2 = DarkMatterWeaponHitUnit2
DarkMatterWeaponHitProp2 = DarkMatterWeaponHitUnit2
DarkMatterWeaponHitWater2 = DarkMatterWeaponHitLand2
DarkMatterWeaponHitUnderWater2 = DarkMatterWeaponHitNone2

--------------------------------------------------------------------------
--  Nomad Ion blast
--------------------------------------------------------------------------
-- Used on AA guns

IonBlastMuzzleFlash = {
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

IonBlastTrail = {
    EmtBpPathNomad .. 'nomad_ionblast_trail_01_emit.bp',
}

IonBlastPolyTrail = EmtBpPathNomad .. 'nomad_ionblast_polytrail_01_emit.bp'

IonBlastHitNone1 = {
    EmtBpPathNomad .. 'nomad_ionblast_hit_01_emit.bp',  -- red/purple dot
    EmtBpPathNomad .. 'nomad_ionblast_hit_02_emit.bp',  -- discharge blue
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

IonBlastHitLand1 = TableCat( IonBlastHitNone1, {
    EmtBpPathNomad .. 'nomad_ionblast_hit_03_emit.bp',  -- small red disk
})

IonBlastHitWater1 = TableCat( IonBlastHitLand1, {
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
})

IonBlastHitUnit1 = TableCat( IonBlastHitNone1, {
--    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

IonBlastHitAirUnit1 = IonBlastHitUnit1
IonBlastHitShield1 = IonBlastHitNone1
IonBlastHitProjectile1 = IonBlastHitNone1
IonBlastHitProp1 = IonBlastHitUnit1
IonBlastHitUnderWater1 = IonBlastHitUnit1

--------------------------------------------------------------------------
--  Nomad Particle blast
--------------------------------------------------------------------------
-- Used on T1 tank

ParticleBlastMuzzleFlash = {
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

ParticleBlastTrail = {
    EmtBpPathNomad .. 'nomad_particleblast_trail_01_emit.bp',
    EmtBpPathNomad .. 'nomad_particleblast_trail_02_emit.bp',
}

ParticleBlastPolyTrail = EmtBpPathNomad .. 'nomad_particleblast_polytrail_01_emit.bp'

ParticleBlastHitNone1 = {
    EmtBpPathNomad .. 'nomad_particleblast_hit_02_emit.bp',  -- discharge effect
    EmtBpPathNomad .. 'nomad_particleblast_hit_04_emit.bp',  -- discharge purple
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

ParticleBlastHitLand1 = TableCat( ParticleBlastHitNone1, {
    EmtBpPathNomad .. 'nomad_particleblast_hit_01_emit.bp',  -- stripes on the ground that slowly expand
--    EmtBpPathNomad .. 'nomad_particleblast_hit_03_emit.bp',  -- rings
})

ParticleBlastHitWater1 = TableCat( ParticleBlastHitLand1, {
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
})

ParticleBlastHitUnit1 = TableCat( ParticleBlastHitNone1, {
--    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

ParticleBlastHitAirUnit1 = ParticleBlastHitUnit1
ParticleBlastHitShield1 = ParticleBlastHitNone1
ParticleBlastHitProjectile1 = ParticleBlastHitNone1
ParticleBlastHitProp1 = ParticleBlastHitUnit1
ParticleBlastHitUnderWater1 = ParticleBlastHitUnit1

--------------------------------------------------------------------------
-- Gattling gun
--------------------------------------------------------------------------

GattlingMuzzleFx1 = {
    EmtBpPath .. 'gauss_cannon_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'gauss_cannon_muzzle_flash_02_emit.bp',
    EmtBpPath .. 'gauss_cannon_muzzle_smoke_02_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_09_emit.bp', 
}

GattlingTrail1 = {}

GattlingPolyTrails1 = {
    EmtBpPath .. 'gauss_cannon_polytrail_01_emit.bp',
    EmtBpPath .. 'gauss_cannon_polytrail_02_emit.bp',
}

GattlingHitNone1 = {
    EmtBpPath .. 'gauss_cannon_hit_01_emit.bp',
    EmtBpPath .. 'gauss_cannon_hit_02_emit.bp',
    EmtBpPath .. 'gauss_cannon_hit_03_emit.bp',    
    EmtBpPath .. 'gauss_cannon_hit_04_emit.bp',
    EmtBpPath .. 'gauss_cannon_hit_05_emit.bp',
}

GattlingHitLand1 = TableCat( GattlingHitNone1, {
})

GattlingHitWater1 = TableCat( GattlingHitLand1, {
})

GattlingHitUnit1 = TableCat( GattlingHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

GattlingHitAirUnit1 = GattlingHitUnit1
GattlingHitShield1 = GattlingHitNone1
GattlingHitProjectile1 = GattlingHitNone1
GattlingHitProp1 = GattlingHitUnit1
GattlingHitUnderWater1 = GattlingHitUnit1

GattlingMuzzleFx2 = {
    EmtBpPath .. 'gauss_cannon_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'gauss_cannon_muzzle_flash_02_emit.bp',
    EmtBpPath .. 'gauss_cannon_muzzle_smoke_02_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_09_emit.bp', 
}

GattlingTrail2 = {}

GattlingPolyTrails2 = {
    EmtBpPath .. 'nomad_gattling_polytrail_01_emit.bp',
    EmtBpPath .. 'nomad_gattling_polytrail_02_emit.bp',
}

GattlingHitNone2 = {
    EmtBpPathNomad .. 'nomad_gattling_hit_01_emit.bp',
    EmtBpPathNomad .. 'nomad_gattling_hit_02_emit.bp',
    EmtBpPathNomad .. 'nomad_gattling_hit_03_emit.bp',
    EmtBpPathNomad .. 'nomad_gattling_hit_04_emit.bp',
    EmtBpPathNomad .. 'nomad_gattling_hit_05_emit.bp',
    EmtBpPathNomad .. 'nomad_gattling_hit_06_emit.bp',
}

GattlingHitLand2 = TableCat( GattlingHitNone2, {
})

GattlingHitWater2 = TableCat( GattlingHitLand2, {
})

GattlingHitUnit2 = TableCat( GattlingHitNone2, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

GattlingHitAirUnit2 = GattlingHitUnit2
GattlingHitShield2 = GattlingHitNone2
GattlingHitProjectile2 = GattlingHitNone2
GattlingHitProp2 = GattlingHitUnit2
GattlingHitUnderWater2 = GattlingHitUnit2

--------------------------------------------------------------------------
--  Nomad Annihilator weapon
--------------------------------------------------------------------------

AnnihilatorMuzzleFlash = {
--    EmtBpPath .. 'cannon_artillery_muzzle_flash_01_emit.bp',
--    EmtBpPath .. 'cannon_muzzle_smoke_07_emit.bp',
--    EmtBpPath .. 'cannon_muzzle_smoke_10_emit.bp',
--    EmtBpPath .. 'cannon_muzzle_flash_03_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

AnnihilatorTrail = {
    EmtBpPathNomad .. 'nomad_annihilator_trail_01_emit.bp',
}

AnnihilatorPolyTrail = EmtBpPath .. 'nomad_annihilator_polytrail01_emit.bp'

AnnihilatorHitNone1 = {
    EmtBpPathNomad .. 'nomad_annihilator_hit_11_emit.bp',  -- circular effect
    EmtBpPathNomad .. 'nomad_annihilator_hit_12_emit.bp',  -- star effect
--    EmtBpPathNomad .. 'nomad_annihilator_hit_13_emit.bp',  -- glow effect
    EmtBpPathNomad .. 'nomad_annihilator_hit_04_emit.bp',  -- flash
}

AnnihilatorHitLand1 = TableCat( AnnihilatorHitNone1, {
    EmtBpPathNomad .. 'nomad_annihilator_hit_01_emit.bp',  -- flat circular effect
    EmtBpPathNomad .. 'nomad_annihilator_hit_02_emit.bp',  -- flat star effect
--    EmtBpPathNomad .. 'nomad_annihilator_hit_03_emit.bp',  -- flat glow effect
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

AnnihilatorHitWater1 = TableCat( AnnihilatorHitNone1, {
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

AnnihilatorHitUnit1 = TableCat( AnnihilatorHitNone1, {
    EmtBpPath .. 'destruction_explosion_sparks_02_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

AnnihilatorHitAirUnit1 = AnnihilatorHitUnit1
AnnihilatorHitShield1 = AnnihilatorHitNone1
AnnihilatorHitProjectile1 = AnnihilatorHitUnit1
AnnihilatorHitProp1 = AnnihilatorHitUnit1
AnnihilatorHitUnderWater1 = AnnihilatorHitLand1

--------------------------------------------------------------------------
--  Nomad Particle blast Artillery
--------------------------------------------------------------------------

ParticleBlastArtilleryMuzzleFx = {
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

ParticleBlastArtilleryTrail = {
    EmtBpPathNomad .. 'nomad_particleblast_trail_01_emit.bp',
    EmtBpPathNomad .. 'nomad_particleblast_trail_02_emit.bp',
}

ParticleBlastArtilleryPolyTrail = EmtBpPathNomad .. 'nomad_particleblast_large_polytrail_01_emit.bp'

ParticleBlastArtilleryHitNone1 = {
    EmtBpPathNomad .. 'nomad_particleblast_large_hit02_emit.bp',  -- discharge effect
    EmtBpPathNomad .. 'nomad_particleblast_large_hit04_emit.bp',  -- discharge purple
    EmtBpPathNomad .. 'nomad_particleblast_large_hit05_emit.bp',  -- circular expanding effect
    EmtBpPathNomad .. 'nomad_particleblast_large_hit07_emit.bp',  -- sparks
    EmtBpPathNomad .. 'nomad_particleblast_large_hit08_emit.bp',  -- flash
--    EmtBpPath .. 'antimatter_hit_14_emit.bp',  -- dark clouds short duration
}

ParticleBlastArtilleryHitLand1 = TableCat( ParticleBlastArtilleryHitNone1, {
    EmtBpPathNomad .. 'nomad_particleblast_large_hit01_emit.bp',  -- stripes on the ground that slowly expand
--    EmtBpPathNomad .. 'nomad_particleblast_large_hit03_emit.bp',  -- rings
    EmtBpPathNomad .. 'nomad_particleblast_large_hit06_emit.bp',  -- flash flat
    EmtBpPath .. 'destruction_explosion_debris_04_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_01_emit.bp',
    EmtBpPath .. 'dust_cloud_04_emit.bp',
})

ParticleBlastArtilleryHitWater1 = TableCat( ParticleBlastArtilleryHitNone1, {
    EmtBpPathNomad .. 'nomad_particleblast_large_hit01_emit.bp',  -- stripes on the ground that slowly expand
--    EmtBpPathNomad .. 'nomad_particleblast_large_hit03_emit.bp',  -- rings
    EmtBpPathNomad .. 'nomad_particleblast_large_hit06_emit.bp',  -- flash flat
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
})

ParticleBlastArtilleryHitUnit1 = {
    EmtBpPathNomad .. 'nomad_particleblast_large_hit01_emit.bp',  -- stripes on the ground that slowly expand
--    EmtBpPathNomad .. 'nomad_particleblast_large_hit03_emit.bp',  -- rings
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
}

ParticleBlastArtilleryHitAirUnit1 = ParticleBlastArtilleryHitUnit1
ParticleBlastArtilleryHitShield1 = ParticleBlastArtilleryHitNone1
ParticleBlastArtilleryHitProjectile1 = ParticleBlastArtilleryHitNone1
ParticleBlastArtilleryHitProp1 = ParticleBlastArtilleryHitLand1
ParticleBlastArtilleryHitUnderWater1 = ParticleBlastArtilleryHitNone1

--------------------------------------------------------------------------
--  Nomad Artillery
--------------------------------------------------------------------------

ArtilleryMuzzleFx = {
    EmtBpPath .. 'cannon_artillery_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_07_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_10_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_03_emit.bp',
}

ArtilleryBeam = ''
ArtilleryPolyTrail = EmtBpPath .. 'default_polytrail_07_emit.bp'  -- white line
ArtilleryTrail = {}

ArtilleryHitNone1 = {
    EmtBpPath .. 'antimatter_hit_12_emit.bp',  -- lightning moving outwards
    EmtBpPath .. 'antimatter_hit_14_emit.bp',  -- dark clouds short duration
    EmtBpPath .. 'antimatter_hit_15_emit.bp',  -- blue flash
    EmtBpPath .. 'antimatter_hit_16_emit.bp',  -- black lightning
    EmtBpPath .. 'antimatter_ring_03_emit.bp',  -- circular ground effect moving outwards
    EmtBpPath .. 'antimatter_ring_04_emit.bp',  -- dark ring moving outwards
    EmtBpPath .. 'quark_bomb_explosion_06_emit.bp',  -- blue star effect short
    EmtBpPathNomad .. 'nomad_artillery_hit01_emit.bp',  -- black hole effect (vortex)
    EmtBpPathNomad .. 'nomad_artillery_hit02_emit.bp',  -- white thick lightning in center
    EmtBpPathNomad .. 'nomad_artillery_hit03_emit.bp',  -- black stripes moving inwards
    EmtBpPathNomad .. 'nomad_artillery_hit04_emit.bp',  -- refraction stripes inwards
}

ArtilleryHitWater1 = TableCat( ArtilleryHitNone1, {
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
})

ArtilleryHitLand1 = ArtilleryHitNone1
ArtilleryHitUnit1 = ArtilleryHitNone1
ArtilleryHitUnderWater1 = ArtilleryHitNone1
ArtilleryHitAirUnit1 = ArtilleryHitNone1
ArtilleryHitShield1 = ArtilleryHitNone1
ArtilleryHitProjectile1 = ArtilleryHitLand1
ArtilleryHitProp1 = ArtilleryHitUnit1

--------------------------------------------------------------------------
--  Nomad Railgun
--------------------------------------------------------------------------

RailgunMuzzleFx = {
    EmtBpPath .. 'flash_01_emit.bp',
    EmtBpPathNomad .. 'nomad_railgun_muzzle01_emit.bp',
}

RailgunBeam = ''
RailgunPolyTrail = EmtBpPath .. 'nomad_railgun_polytrail01_emit.bp'  -- white line
RailgunTrail = {
    EmtBpPathNomad .. 'nomad_railgun_trail01_emit.bp',  -- bolt
    EmtBpPathNomad .. 'nomad_railgun_trail02_emit.bp',  -- longer bolt
    EmtBpPathNomad .. 'nomad_railgun_trail03_emit.bp',  -- slight distortion effect
}

RailgunHitNone1 = {
--    EmtBpPathNomad .. 'nomad_railgun_hit01_emit.bp',  -- quick star effect
    EmtBpPathNomad .. 'nomad_railgun_hit02_emit.bp',  -- small circular effect
    EmtBpPathNomad .. 'nomad_railgun_hit03_emit.bp',  -- sparks
    EmtBpPathNomad .. 'nomad_railgun_hit04_emit.bp',  -- circular effect
    EmtBpPathNomad .. 'nomad_railgun_hit05_emit.bp',  -- flash
--    EmtBpPathNomad .. 'nomad_railgun_hit06_emit.bp',  -- logn lasting electric effect
--    EmtBpPathNomad .. 'nomad_railgun_hit07_emit.bp',  -- circular electric effect
}

RailgunHitLand1 = TableCat( RailgunHitNone1, {
    EmtBpPathNomad .. 'nomad_railgun_hit08_emit.bp',  -- small shockwave
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

RailgunHitWater1 = TableCat( RailgunHitNone1, {
    EmtBpPathNomad .. 'nomad_railgun_hit08_emit.bp',  -- small shockwave
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
})

RailgunHitUnit1 = TableCat( RailgunHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

RailgunHitUnderWater1 = {
    EmtBpPathNomad .. 'nomad_railgun_hit02_emit.bp',  -- small circular effect
    EmtBpPathNomad .. 'nomad_railgun_hit04_emit.bp',  -- circular effect
    EmtBpPathNomad .. 'nomad_railgun_hit05_emit.bp',  -- flash
}

RailgunHitAirUnit1 = RailgunHitUnit1
RailgunHitShield1 = RailgunHitNone1
RailgunHitProjectile1 = RailgunHitUnit1
RailgunHitProp1 = RailgunHitUnit1

--------------------------------------------------------------------------
--  Nomad Under water Railgun
--------------------------------------------------------------------------

UnderWaterRailgunMuzzleFx = {
    EmtBpPathNomad .. 'nomad_underwaterrailgun_muzzle01_emit.bp',
    EmtBpPathNomad .. 'nomad_railgun_muzzle02_emit.bp',
}

UnderWaterRailgunBeam = ''
UnderWaterRailgunPolyTrail = EmtBpPath .. 'nomad_railgun_polytrail01_emit.bp'  -- white line
UnderWaterRailgunTrail = {
    EmtBpPathNomad .. 'nomad_railgun_trail01_emit.bp',  -- bolt
    EmtBpPathNomad .. 'nomad_railgun_trail02_emit.bp',  -- longer bolt
    EmtBpPathNomad .. 'nomad_railgun_trail03_emit.bp',  -- slight distortion effect
--    EmtBpPath .. 'torpedo_underwater_wake_01_emit.bp',
--    EmtBpPath .. 'torpedo_underwater_wake_02_emit.bp',
--    EmtBpPath .. 'destruction_underwater_sinking_wash_01_emit.bp',
}

UnderWaterRailgunHitNone1 = {
    EmtBpPathNomad .. 'nomad_railgun_hit02_emit.bp',  -- small circular effect
    EmtBpPathNomad .. 'nomad_railgun_hit04_emit.bp',  -- circular effect
    EmtBpPathNomad .. 'nomad_railgun_hit05_emit.bp',  -- flash
}

UnderWaterRailgunHitLand1 = TableCat( UnderWaterRailgunHitNone1, {
    EmtBpPathNomad .. 'nomad_railgun_hit08_emit.bp',  -- small shockwave
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

UnderWaterRailgunHitWater1 = TableCat( UnderWaterRailgunHitNone1, {
    EmtBpPathNomad .. 'nomad_railgun_hit08_emit.bp',  -- small shockwave
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
})

UnderWaterRailgunHitUnit1 = TableCat( UnderWaterRailgunHitNone1, {
    EmtBpPathNomad .. 'nomad_railgun_hit03_emit.bp',  -- sparks
})

UnderWaterRailgunHitAirUnit1 = UnderWaterRailgunHitNone1
UnderWaterRailgunHitShield1 = UnderWaterRailgunHitNone1
UnderWaterRailgunHitProjectile1 = UnderWaterRailgunHitNone1
UnderWaterRailgunHitProp1 = UnderWaterRailgunHitUnit1
UnderWaterRailgunHitUnderWater1 = UnderWaterRailgunHitNone1

--------------------------------------------------------------------------
--  Nomad Depth Charge
--------------------------------------------------------------------------

DepthChargeBombMuzzleFx = {
    EmtBpPath .. 'cannon_artillery_muzzle_flash_01_emit.bp',
}

DepthChargeBombTrailAir = {
    EmtBpPath .. 'mortar_munition_01_emit.bp',
}

DepthChargeBombTrailWater = {
    EmtBpPath .. 'torpedo_underwater_wake_01_emit.bp',
    EmtBpPath .. 'torpedo_underwater_wake_02_emit.bp',
}

DepthChargeBombTransitionAirToWater = {
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_wash_01_emit.bp',
    EmtBpPathNomad .. 'water_surface_ripple.bp',
}

DepthChargeBombHitNone1 = {
    EmtBpPathNomad .. 'nomad_depthchargebomb_01_emit.bp',  -- small flash
    EmtBpPathNomad .. 'nomad_depthchargebomb_03_emit.bp',  -- star effect
}

DepthChargeBombHitLand1 = TableCat( DepthChargeBombHitNone1, {
    EmtBpPathNomad .. 'nomad_depthchargebomb_02_emit.bp',  -- flat star effect
    EmtBpPathNomad .. 'nomad_depthchargebomb_04_emit.bp',  -- shockwave (refraction)
})

DepthChargeBombHitWater1 = TableCat( DepthChargeBombHitNone1, {
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_wash_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_plume_01_emit.bp',
})

DepthChargeBombHitUnderWater1 = TableCat( DepthChargeBombHitNone1, {
    EmtBpPath .. 'destruction_underwater_explosion_flash_01_emit.bp',
    EmtBpPath .. 'destruction_underwater_explosion_flash_02_emit.bp',
    EmtBpPath .. 'destruction_underwater_explosion_splash_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_wash_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_plume_01_emit.bp',
    EmtBpPath .. 'destruction_underwater_explosion_surface_ripples_01_emit.bp',
})

DepthChargeBombHitSeabed1 = TableCat( DepthChargeBombHitUnderWater1, {
})

DepthChargeBombHitUnit1 = TableCat( DepthChargeBombHitNone1, {
    EmtBpPathNomad .. 'nomad_depthchargebomb_02_emit.bp',  -- flat star effect
    EmtBpPathNomad .. 'nomad_depthchargebomb_04_emit.bp',  -- shockwave (refraction)
})

DepthChargeBombHitAirUnit1 = TableCat( DepthChargeBombHitNone1, {
    EmtBpPathNomad .. 'nomad_depthchargebomb_04_emit.bp',  -- shockwave (refraction)
})

DepthChargeBombHitShield1 = DepthChargeBombHitNone1
DepthChargeBombHitProjectile1 = DepthChargeBombHitNone1
DepthChargeBombHitProp1 = DepthChargeBombHitUnit1

DepthChargeBombDeepWaterExplosion = TableCat( DepthChargeBombHitNone1, {
})

--------------------------------------------------------------------------
--  Nomad EMP gun
--------------------------------------------------------------------------
-- used by T2 emp tank and T2 cruiser

EMPGunMuzzleFlash = {
--    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
    EmtBpPathNomad .. 'nomad_EMP_gun_muzzle_flash_03_emit.bp',
}

EMPGunMuzzleFlash_Tank = {
--    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
    EmtBpPathNomad .. 'nomad_EMP_gun_muzzle_flash_01_emit.bp',
    EmtBpPathNomad .. 'nomad_EMP_gun_muzzle_flash_02_emit.bp',
}

EMPGunTrail = {
    EmtBpPathNomad .. 'nomad_EMP_gun_trail_01_emit.bp', -- green haze
    EmtBpPathNomad .. 'nomad_EMP_gun_trail_02_emit.bp', -- bolt
    EmtBpPathNomad .. 'nomad_EMP_gun_trail_03_emit.bp', -- electricity
    EmtBpPathNomad .. 'nomad_EMP_gun_trail_04_emit.bp', -- bolt
}

EMPGunPolyTrail = EmtBpPathNomad .. 'nomad_EMP_gun_polytrail_03_emit.bp'

EMPGunElectricityEffect = {
    EmtBpPathNomad .. 'nomad_EMP_gun_hit_03_emit.bp',
    EmtBpPathNomad .. 'nomad_EMP_gun_hit_04_emit.bp',
}
EMPGunElectricityEffectDurationMulti = 2.5

EMPGunHitNone1 = {
    EmtBpPathNomad .. 'nomad_EMP_gun_hit_01_emit.bp',
    EmtBpPathNomad .. 'nomad_EMP_gun_hit_02_emit.bp',
}

EMPGunHitWater1 = TableCat( EMPGunHitNone1, {
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
})

EMPGunHitLand1 = EMPGunHitNone1
EMPGunHitUnit1 = EMPGunHitNone1
EMPGunHitAirUnit1 = EMPGunHitUnit1
EMPGunHitShield1 = EMPGunHitNone1
EMPGunHitProjectile1 = EMPGunHitNone1
EMPGunHitProp1 = EMPGunHitUnit1
EMPGunHitUnderWater1 = EMPGunHitNone1

-------------------------------------------------------------------------------------------
-- Nomad Stingray Emitters
-------------------------------------------------------------------------------------------

StingrayMuzzleFx = {
    EmtBpPathNomad .. 'nomad_stingray_muzzle01_emit.bp',  -- orange effect following projectile
    EmtBpPathNomad .. 'nomad_stingray_muzzle02_emit.bp',  -- flash effect stars
    EmtBpPathNomad .. 'nomad_stingray_muzzle03_emit.bp',  -- flash effect
}

StingrayTrail= {
    EmtBpPathNomad .. 'nomad_stingray_trail01_emit.bp',  -- still rings
}
StingrayPolyTrails = {
    EmtBpPathNomad .. 'nomad_stingray_polytrail01_emit.bp',  -- yellow trail short
    EmtBpPathNomad .. 'nomad_stingray_polytrail02_emit.bp',  -- yellow trail long
}

StingrayHitNone1 = {
    EmtBpPathNomad .. 'nomad_stingray_hit01_emit.bp',  -- basic explosive effect
    EmtBpPathNomad .. 'nomad_stingray_hit03_emit.bp',  -- "long" flames effect
    EmtBpPathNomad .. 'nomad_stingray_hit04_emit.bp',  -- short flames effect
}

StingrayHitLand1 = TableCat(StingrayHitNone1, {
    EmtBpPathNomad .. 'nomad_stingray_hit02_emit.bp',  -- expanding ring at ground
})

StingrayHitWater1 = TableCat(StingrayHitNone1, {
    EmtBpPathNomad .. 'nomad_stingray_hit02_emit.bp',  -- expanding ring at ground
})

StingrayHitUnit1 = TableCat(StingrayHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

StingrayHitAirUnit1 = StingrayHitNone1
StingrayHitShield1 = StingrayHitNone1
StingrayHitProjectile1 = StingrayHitNone1
StingrayHitProp1 = StingrayHitUnit1
StingrayHitUnderWater1 = StingrayHitNone1

--------------------------------------------------------------------------
--  Flares
--------------------------------------------------------------------------

FlareMuzzleFx = {
-- TODO: these effects
}

FlareTrail = {
    EmtBpPathNomad .. 'nomad_aamflare_trail01_emit.bp', -- stars
    EmtBpPathNomad .. 'nomad_aamflare_trail02_emit.bp', -- stars
    EmtBpPathNomad .. 'nomad_aamflare_trail03_emit.bp', -- trails
    EmtBpPathNomad .. 'nomad_navallight01_emit.bp',  -- constant green light
}

FlarePolyTrail =  EmtBpPath .. 'default_polytrail_01_emit.bp'

FlareHitNone1 = {  -- default impact effect, if impacting with ground or a unit. No damage is dealt, no big FX needed
    EmtBpPathNomad .. 'nomad_aamflare_impact01_emit.bp',
}

FlareHitLand1 = TableCat(FlareHitNone1, {
})

FlareHitWater1 = TableCat(FlareHitNone1, {
})

FlareHitProjectile1 = TableCat(FlareHitNone1, { 
-- TODO: the flare impacts with a missile projectile. Should be a little bigger eplosion
    EmtBpPathNomad .. 'nomad_aamflare_impact01_emit.bp',
})

FlareHitUnit1 = FlareHitProjectile1
FlareHitAirUnit1 = FlareHitNone1
FlareHitShield1 = FlareHitNone1
FlareHitProp1 = FlareHitProjectile1
FlareHitUnderWater1 = FlareHitNone1

--------------------------------------------------------------------------
--  Nomad Small Missile (guided)
--------------------------------------------------------------------------
-- Used by a lot of units

MissileMuzzleFx = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
}

MissileMuzzleFx2 = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp', -- smoke out back
}

MissileBeam = EmtBpPathNomad .. 'nomad_missilebeam01_emit.bp'
MissileTrail = {}
MissilePolyTrail = EmtBpPath .. 'nomad_missile_polytrail_01_emit.bp'

MissileHitNone1 = {
    EmtBpPathNomad .. 'nomad_missile_hit_01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_missile_hit_02_emit.bp',  -- yellow core
    EmtBpPathNomad .. 'nomad_missile_hit_03_emit.bp',  -- orange ring
}

MissileHitLand1 = TableCat( MissileHitNone1, {
    EmtBpPathNomad .. 'nomad_missile_hit_11_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_missile_hit_12_emit.bp',  -- yellow core
    EmtBpPathNomad .. 'nomad_missile_hit_13_emit.bp',  -- orange ring
    EmtBpPathNomad .. 'nomad_missile_hit_14_emit.bp',  -- shockwave ring
})

MissileHitWater1 = TableCat( MissileHitNone1, {
    EmtBpPathNomad .. 'nomad_missile_hit_14_emit.bp',  -- shockwave ring
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
})

MissileHitUnit1 = TableCat( MissileHitNone1, {
})

MissileHitAirUnit1 = MissileHitUnit1
MissileHitShield1 = MissileHitNone1
MissileHitProjectile1 = MissileHitNone1
MissileHitProp1 = MissileHitUnit1
MissileHitUnderWater1 = MissileHitUnit1

-- bigger effect
MissileHitNone2 = {
    EmtBpPathNomad .. 'nomad_missile_hit_07_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_missile_hit_02_emit.bp',  -- yellow core
    EmtBpPathNomad .. 'nomad_missile_hit_03_emit.bp',  -- orange ring
    EmtBpPathNomad .. 'nomad_missile_hit_05_emit.bp',  -- orange star/flare
    EmtBpPathNomad .. 'nomad_missile_hit_06_emit.bp',  -- sparks
}

MissileHitLand2 = TableCat( MissileHitNone2, {
    EmtBpPathNomad .. 'nomad_missile_hit_17_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_missile_hit_12_emit.bp',  -- yellow core
    EmtBpPathNomad .. 'nomad_missile_hit_13_emit.bp',  -- orange ring
    EmtBpPathNomad .. 'nomad_missile_hit_14_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

MissileHitWater2 = TableCat( MissileHitNone2, {
    EmtBpPathNomad .. 'nomad_missile_hit_14_emit.bp',  -- shockwave ring
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

MissileHitUnit2 = TableCat( MissileHitNone2, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

MissileHitAirUnit2 = MissileHitUnit2
MissileHitShield2 = MissileHitNone2
MissileHitProjectile2 = MissileHitNone2
MissileHitProp2 = MissileHitUnit2
MissileHitUnderWater2 = MissileHitNone2

MissileMuzzleFx = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
}

MissileMuzzleFx2 = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp', -- smoke out back
}

MissileBeam = EmtBpPathNomad .. 'nomad_missilebeam01_emit.bp'
MissileTrail = {}
MissilePolyTrail = EmtBpPath .. 'nomad_missile_polytrail_01_emit.bp'

--------------------------------------------------------------------------
--  Nomad Small rocket (unguided)
--------------------------------------------------------------------------
-- Used by a lot of units

RocketMuzzleFx = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
}

RocketMuzzleFx2 = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp', -- smoke out back
}

RocketBeam = EmtBpPathNomad .. 'nomad_rocket_beam01_emit.bp'
RocketTrail = {
    EmtBpPathNomad .. 'nomad_rocket_trail01_emit.bp',
}
RocketPolyTrail = EmtBpPath .. 'nomad_rocket_polytrail_01_emit.bp'

RocketHitNone1 = {
    EmtBpPathNomad .. 'nomad_rocket_hit_01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_rocket_hit_02_emit.bp',  -- orange electricity
    EmtBpPathNomad .. 'nomad_rocket_hit_03_emit.bp',  -- black electricity
}

RocketHitLand1 = TableCat( RocketHitNone1, {
    EmtBpPathNomad .. 'nomad_rocket_hit_05_emit.bp',  -- dark smoke
    EmtBpPathNomad .. 'nomad_rocket_hit_04_emit.bp',  -- shockwave ring
})

RocketHitWater1 = TableCat( RocketHitNone1, {
    EmtBpPathNomad .. 'nomad_rocket_hit_05_emit.bp',  -- dark smoke
    EmtBpPathNomad .. 'nomad_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
})

RocketHitUnit1 = TableCat( RocketHitNone1, {
    EmtBpPathNomad .. 'nomad_rocket_hit_05_emit.bp',  -- dark smoke
})

RocketHitAirUnit1 = TableCat( RocketHitNone1, {
})

RocketHitShield1 = RocketHitNone1
RocketHitProjectile1 = RocketHitNone1
RocketHitProp1 = RocketHitUnit1
RocketHitUnderWater1 = RocketHitUnit1

-- longer lasting effect and shaky trail
RocketHitNone2 = {
    EmtBpPathNomad .. 'nomad_rocket_hit_01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_rocket_hit_12_emit.bp',  -- white->red electricity
    EmtBpPathNomad .. 'nomad_rocket_hit_13_emit.bp',  -- black electricity
}

RocketHitLand2 = TableCat( RocketHitNone2, {
    EmtBpPathNomad .. 'nomad_rocket_hit_15_emit.bp',  -- dark smoke
    EmtBpPathNomad .. 'nomad_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

RocketHitWater2 = TableCat( RocketHitNone2, {
    EmtBpPathNomad .. 'nomad_rocket_hit_15_emit.bp',  -- dark smoke
    EmtBpPathNomad .. 'nomad_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

RocketHitUnit2 = TableCat( RocketHitNone2, {
    EmtBpPathNomad .. 'nomad_rocket_hit_15_emit.bp',  -- dark smoke
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

RocketHitAirUnit2 = TableCat( RocketHitNone2, {
})

RocketHitShield2 = RocketHitNone2
RocketHitProjectile2 = RocketHitNone2
RocketHitProp2 = RocketHitUnit2
RocketHitUnderWater2 = RocketHitNone2

RocketBeam2 = EmtBpPathNomad .. 'nomad_rocket_beam01_emit.bp'
RocketTrail2 = {
    EmtBpPathNomad .. 'nomad_rocket_trail01_emit.bp',
}
RocketPolyTrail2 = EmtBpPath .. 'nomad_rocket_polytrail_02_emit.bp'


RocketMuzzleFx2 = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
}

RocketMuzzleFx2 = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp', -- smoke out back
}

-- Slightly different visuals

RocketBeam3 = EmtBpPathNomad .. 'nomad_rocket_beam03_emit.bp'
RocketTrail3 = {
    EmtBpPathNomad .. 'nomad_rocket_trail03_emit.bp',
}
RocketPolyTrail3 = EmtBpPath .. 'nomad_rocket_polytrail_03_emit.bp'

RocketHitNone3 = {
    EmtBpPathNomad .. 'nomad_rocket_hit_08_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_rocket_hit_09_emit.bp',  -- star effect on ground
}

RocketHitLand3 = TableCat( RocketHitNone3, {
    EmtBpPathNomad .. 'nomad_rocket_hit_05_emit.bp',  -- dark smoke
    EmtBpPathNomad .. 'nomad_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

RocketHitWater3 = TableCat( RocketHitNone3, {
    EmtBpPathNomad .. 'nomad_rocket_hit_05_emit.bp',  -- dark smoke
    EmtBpPathNomad .. 'nomad_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
})

RocketHitUnit3 = TableCat( RocketHitNone3, {
    EmtBpPathNomad .. 'nomad_rocket_hit_05_emit.bp',  -- dark smoke
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

RocketHitAirUnit3 = TableCat( RocketHitNone3, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

RocketHitShield3 = RocketHitNone3
RocketHitProjectile3 = RocketHitNone3
RocketHitProp3 = RocketHitUnit3
RocketHitUnderWater3 = RocketHitUnit3

-- again, different visuals, this time for a DoT effect

RocketBeam4 = EmtBpPathNomad .. 'nomad_rocket_beam04_emit.bp'
RocketTrail4 = {
    EmtBpPathNomad .. 'nomad_rocket_trail04_emit.bp',
}
RocketPolyTrail4 = EmtBpPath .. 'nomad_rocket_polytrail_04_emit.bp'

RocketHitNone4 = {
    EmtBpPathNomad .. 'nomad_rocket_hit_20_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_rocket_hit_23_emit.bp',  -- blue smoke effect
    EmtBpPathNomad .. 'nomad_rocket_hit_24_emit.bp',  -- blue star effect
}

RocketHitLand4 = {
    EmtBpPathNomad .. 'nomad_rocket_hit_20_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_rocket_hit_21_emit.bp',  -- blue smoke effect slightly above impact
    EmtBpPathNomad .. 'nomad_rocket_hit_22_emit.bp',  -- blue star effect slightly above impact
    EmtBpPathNomad .. 'nomad_rocket_hit_04_emit.bp',  -- shockwave ring
}

RocketHitWater4 = {
    EmtBpPathNomad .. 'nomad_rocket_hit_20_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_rocket_hit_21_emit.bp',  -- blue smoke effect slightly above impact
    EmtBpPathNomad .. 'nomad_rocket_hit_22_emit.bp',  -- blue star effect slightly above impact
    EmtBpPathNomad .. 'nomad_rocket_hit_04_emit.bp',  -- shockwave ring
}

RocketHitUnit4 = TableCat( RocketHitNone4, {
})

RocketHitAirUnit4 = TableCat( RocketHitNone4, {
})

RocketHitShield4 = RocketHitNone4
RocketHitProjectile4 = RocketHitNone4
RocketHitProp4 = RocketHitUnit4
RocketHitUnderWater4 = RocketHitUnit4

-- no DoT effect
RocketBeam5 = EmtBpPathNomad .. 'nomad_rocket_beam05_emit.bp'
RocketTrail5 = {
    EmtBpPathNomad .. 'nomad_rocket_trail05_emit.bp',
}
RocketPolyTrail5 = EmtBpPath .. 'nomad_rocket_polytrail_05_emit.bp'

RocketHitNone5 = {
    EmtBpPathNomad .. 'nomad_rocket_hit_26_emit.bp',  -- flash
}

RocketHitLand5 = TableCat( RocketHitNone5, {
    EmtBpPathNomad .. 'nomad_rocket_hit_27_emit.bp',  -- very short blue smoke effect (flat)
    EmtBpPathNomad .. 'nomad_rocket_hit_06_emit.bp',  -- shockwave ring
})

RocketHitWater5 = TableCat( RocketHitNone5, {
    EmtBpPathNomad .. 'nomad_rocket_hit_27_emit.bp',  -- very short blue smoke effect (flat)
    EmtBpPathNomad .. 'nomad_rocket_hit_06_emit.bp',  -- shockwave ring
})

RocketHitUnit5 = TableCat( RocketHitNone5, {
    EmtBpPathNomad .. 'nomad_rocket_hit_25_emit.bp',  -- very short blue smoke effect
})

RocketHitAirUnit5 = TableCat( RocketHitNone5, {
    EmtBpPathNomad .. 'nomad_rocket_hit_25_emit.bp',  -- very short blue smoke effect
})

RocketHitShield5 = RocketHitNone5
RocketHitProjectile5 = RocketHitNone5
RocketHitProp5 = RocketHitUnit5
RocketHitUnderWater5 = RocketHitUnit5

--------------------------------------------------------------------------
--  NOMAD FUSION MISSILE EMITTERS
--------------------------------------------------------------------------
FusionMissileMuzzleFx = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp',
}

FusionMissile_DroppedActivation = {
    EmtBpPathNomad .. 'nomad_fusionmissile_dropped_activation01_emit.bp',
}

FusionMissileBeam = ''
FusionMissilePolyTrail = ''
FusionMissileTrail = {
    EmtBpPathNomad .. 'nomad_fusionmissile_trail01_emit.bp',
    EmtBpPathNomad .. 'nomad_fusionmissile_trail02_emit.bp',
}

FusionMissileHitNone1 = {
    EmtBpPathNomad .. 'nomad_fusionmissile_hit01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_fusionmissile_hit02_emit.bp',  -- fire effect
    EmtBpPathNomad .. 'nomad_fusionmissile_hit03_emit.bp',  -- brown smoke
}

FusionMissileHitLand1 = TableCat( FusionMissileHitNone1, {
    EmtBpPathNomad .. 'nomad_fusionmissile_hit04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_explosion_debris_04_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

FusionMissileHitWater1 = TableCat( FusionMissileHitNone1, {
    EmtBpPathNomad .. 'nomad_fusionmissile_hit04_emit.bp',  -- shockwave ring
--    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
--    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

FusionMissileHitUnit1 = TableCat( FusionMissileHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

FusionMissileHitAirUnit1 = FusionMissileHitUnit1
FusionMissileHitShield1 = FusionMissileHitNone1
FusionMissileHitProjectile1 = FusionMissileHitNone1
FusionMissileHitProp1 = FusionMissileHitUnit1
FusionMissileHitUnderWater1 = FusionMissileHitUnit1

--------------------------------------------------------------------------
--  NOMAD EMP MISSILE EMITTERS
--------------------------------------------------------------------------
EMPMissileMuzzleFx = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp',
}

EMPMissileBeam = ''
EMPMissilePolyTrail = ''
EMPMissileTrail = {
    EmtBpPathNomad .. 'nomad_empmissile_trail01_emit.bp',
    EmtBpPathNomad .. 'nomad_empmissile_trail02_emit.bp',
    EmtBpPathNomad .. 'nomad_empmissile_trail03_emit.bp',
}

EMPMissileHitNone1 = {
    EmtBpPathNomad .. 'nomad_empmissile_hit05_emit.bp',  
	EmtBpPathNomad .. 'nomad_empmissile_hit07_emit.bp',  
    -- EmtBpPath .. 'destruction_explosion_debris_04_emit.bp',
    -- EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
}

EMPMissileElectricityEffect = {
    EmtBpPathNomad .. 'nomad_empmissile_hit03_emit.bp', 
    EmtBpPathNomad .. 'nomad_empmissile_hit04_emit.bp',  
}
EMPMissileElectricityEffectDurationMulti = 0.5

EMPMissileHitLand1 = TableCat( EMPMissileHitNone1, {
})

EMPMissileHitWater1 = TableCat( EMPMissileHitNone1, {
    EmtBpPathNomad .. 'nomad_empmissile_hit05_emit.bp',  -- shockwave ring
})

EMPMissileHitUnit1 = TableCat( EMPMissileHitNone1, {
    EmtBpPathNomad .. 'nomad_empmissile_hit05_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

EMPMissileHitAirUnit1 = EMPMissileHitUnit1
EMPMissileHitShield1 = EMPMissileHitNone1
EMPMissileHitProjectile1 = EMPMissileHitNone1
EMPMissileHitProp1 = EMPMissileHitUnit1
EMPMissileHitUnderWater1 = EMPMissileHitUnit1

--------------------------------------------------------------------------
--  Nomad Tactical Missiles
--------------------------------------------------------------------------
-- Used by the TML and Crawler

TacticalMissileMuzzleFx = {
    EmtBpPathNomad .. 'nomad_tacticalmissilelaunch01_emit.bp',
    EmtBpPathNomad .. 'nomad_tacticalmissilelaunch02_emit.bp',
    EmtBpPathNomad .. 'nomad_tacticalmissilelaunch03_emit.bp',
}

TacticalMissileMuzzleFxUnderWaterAddon = { 
    -- only use if unit is under water sufficiently, like 3 - 4 units under water, or you'll see air bubbles above the water
    EmtBpPath .. 'terran_cruise_missile_sublaunch_01_emit.bp',
}

TacticalMissileBeam = EmtBpPath .. 'nomad_missilebeam01_emit.bp'
TacticalMissilePolyTrail = EmtBpPath .. 'nomad_missile_polytrail_01_emit.bp'
TacticalMissileTrail = {
	EmtBpPathNomad .. 'nomad_small_lense_flare_emit.bp',
    EmtBpPathNomad .. 'nomad_tacticalmissile_trail01_emit.bp',
}
TacticalMissileTrailFxUnderWaterAddon = {
    -- Adds bubbles to the previous entry. Only use if unit is under water, remove this trail when exiting water
    EmtBpPath .. 'destruction_underwater_sinking_wash_01_emit.bp',
}

TacticalMissileHitNone1 = {
	EmtBpPathNomad .. 'smoke_black_small.bp',  -- smoke
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit01_emit.bp',  -- orange flames
	EmtBpPathNomad .. 'nomad_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit03_emit.bp',  -- red lightning
}

TacticalMissileHitLand1 = TableCat( TacticalMissileHitNone1, {
    -- EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    -- EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

TacticalMissileHitWater1 = TableCat( TacticalMissileHitNone1, {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

TacticalMissileHitUnit1 = TableCat( TacticalMissileHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

TacticalMissileHitAirUnit1 = TacticalMissileHitUnit1
TacticalMissileHitShield1 = TacticalMissileHitNone1
TacticalMissileHitProjectile1 = TacticalMissileHitNone1
TacticalMissileHitProp1 = TacticalMissileHitUnit1
TacticalMissileHitUnderWater1 = TacticalMissileHitUnit1

-- used by TML
TacticalMissileHitNone2 = {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit01_emit.bp',  -- orange flames
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit03_emit.bp',  -- red lightning
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit04_emit.bp',  -- red flash
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit05_emit.bp',  -- brown smoke
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit06_emit.bp',  -- residual flame cloud
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit14_emit.bp',  -- ground sparks
}

TacticalMissileHitLand2 = TableCat( TacticalMissileHitNone2, {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
    EmtBpPath .. 'dust_cloud_04_emit.bp',
})

TacticalMissileHitWater2 = TableCat( TacticalMissileHitNone2, {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

TacticalMissileHitUnit2 = TableCat( TacticalMissileHitNone2, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

TacticalMissileHitAirUnit2 = TacticalMissileHitUnit2
TacticalMissileHitShield2 = TacticalMissileHitNone2
TacticalMissileHitProjectile2 = TacticalMissileHitNone2
TacticalMissileHitProp2 = TacticalMissileHitUnit2
TacticalMissileHitUnderWater2 = TacticalMissileHitUnit2

--------------------------------------------------------------------------
--  Nomad Artillery rockets
--------------------------------------------------------------------------
-- Used by T2 MML and T3 rocket artillery

ArcingTacticalMissileBeam = TacticalMissileBeam
ArcingTacticalMissileTrail = TacticalMissileTrail
ArcingTacticalMissilePolyTrail = TacticalMissilePolyTrail

ArcingTacticalMissileHitNone1 = {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit01_emit.bp',  -- orange flames
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit03_emit.bp',  -- red lightning
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit04_emit.bp',  -- red flash
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit05_emit.bp',  -- brown smoke
}

ArcingTacticalMissileHitLand1 = TableCat( ArcingTacticalMissileHitNone1, {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

ArcingTacticalMissileHitWater1 = TableCat( ArcingTacticalMissileHitNone1, {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

ArcingTacticalMissileHitUnit1 = TableCat( ArcingTacticalMissileHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

ArcingTacticalMissileHitAirUnit1 = ArcingTacticalMissileHitUnit1
ArcingTacticalMissileHitShield1 = ArcingTacticalMissileHitNone1
ArcingTacticalMissileHitProjectile1 = ArcingTacticalMissileHitNone1
ArcingTacticalMissileHitProp1 = ArcingTacticalMissileHitUnit1
ArcingTacticalMissileHitUnderWater1 = ArcingTacticalMissileHitUnit1

-- used by T3 rocket artillery
ArcingTacticalMissileHitNone2 = {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit10_emit.bp',  -- yellow sparks fountain
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit11_emit.bp',  -- ground ring
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit12_emit.bp',  -- flash
}

ArcingTacticalMissileHitLand2 = TableCat( ArcingTacticalMissileHitNone2, {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'destruction_explosion_debris_01_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
    EmtBpPath .. 'dust_cloud_04_emit.bp',
})

ArcingTacticalMissileHitWater2 = TableCat( ArcingTacticalMissileHitNone2, {
    EmtBpPathNomad .. 'nomad_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

ArcingTacticalMissileHitUnit2 = TableCat( ArcingTacticalMissileHitLand2, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

ArcingTacticalMissileHitAirUnit2 = ArcingTacticalMissileHitUnit2
ArcingTacticalMissileHitShield2 = ArcingTacticalMissileHitNone2
ArcingTacticalMissileHitProjectile2 = ArcingTacticalMissileHitNone2
ArcingTacticalMissileHitProp2 = ArcingTacticalMissileHitUnit2
ArcingTacticalMissileHitUnderWater2 = ArcingTacticalMissileHitNone2

ArcingTacticalMissileSpeedupFlash = {
    EmtBpPathNomad .. 'nomad_tacticalmissile_speedup01_emit.bp',  -- flash
	EmtBpPathNomad .. 'nomad_tacticalmissile_speedup02_emit.bp',  -- lense
	EmtBpPathNomad .. 'smoke_white_small.bp',  -- smoke
	EmtBpPathNomad .. 'split_shockwave.bp',  -- shockwave 
}

--------------------------------------------------------------------------
-- Nomad Torpedoes
--------------------------------------------------------------------------

TorpedoEnterWater = {  -- falling from above water

}

TorpedoTrail = {
    EmtBpPath .. 'torpedo_underwater_wake_01_emit.bp',
}

TorpedoHitNone1 = {
    EmtBpPath .. 'destruction_underwater_explosion_flash_01_emit.bp',
    EmtBpPath .. 'destruction_underwater_explosion_flash_02_emit.bp',
    EmtBpPath .. 'destruction_underwater_explosion_splash_01_emit.bp',
}

TorpedoHitLand1 = TableCat( TorpedoHitNone1, {
})

TorpedoHitWater1 = TableCat( TorpedoHitNone1, {
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_wash_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_plume_01_emit.bp',
})

TorpedoHitUnit1 = TableCat( TorpedoHitNone1, {
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_wash_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_plume_01_emit.bp',
})

TorpedoHitAirUnit1 = TorpedoHitNone1
TorpedoHitShield1 = TorpedoHitNone1
TorpedoHitProjectile1 = TorpedoHitNone1
TorpedoHitProp1 = TorpedoHitNone1
TorpedoHitUnderWater1 = TorpedoHitNone1

--------------------------------------------------------------------------
--  Conventional bomb
--------------------------------------------------------------------------
-- currently not used, basically a bomb with same effects as kinetic projectiles

ConventionalBombMuzzleFx = {}

ConventionalBombTrail = {}
ConventionalBombPolyTrail = EmtBpPath .. 'default_polytrail_01_emit.bp'

ConventionalBombHitNone1 = {
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_03_emit.bp',  -- fast explosion
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_05_emit.bp',  -- smoke
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_06_emit.bp',  -- long explosion
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_04_emit.bp',  -- short flames
}

ConventionalBombHitLand1 = TableCat( ConventionalBombHitNone1, {
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_07_emit.bp',  -- shockwave rings
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_08_emit.bp',  -- long shockwave rings
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

ConventionalBombHitWater1 = TableCat( ConventionalBombHitNone1, {
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_07_emit.bp',  -- shockwave rings
    EmtBpPathNomad .. 'nomad_kineticcannon_hit_08_emit.bp',  -- long shockwave rings
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

ConventionalBombHitUnit1 = TableCat( ConventionalBombHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

ConventionalBombHitAirUnit1 = ConventionalBombHitUnit1
ConventionalBombHitShield1 = ConventionalBombHitNone1
ConventionalBombHitProjectile1 = ConventionalBombHitNone1
ConventionalBombHitProp1 = ConventionalBombHitUnit1
ConventionalBombHitUnderWater1 = ConventionalBombHitUnit1

--------------------------------------------------------------------------
--  Concussion bomb
--------------------------------------------------------------------------

ConcussionBombMuzzleFx = {}

ConcussionBombTrail = {
    EmtBpPathNomad .. 'nomad_concussionbomb_trail01_emit.bp',  -- the 'bomb'
    EmtBpPathNomad .. 'nomad_concussionbomb_trail02_emit.bp',  -- orange trail
}
ConcussionBombPolyTrail = '/effects/emitters/default_polytrail_01_emit.bp'

ConcussionBombSplit = {
    EmtBpPath .. 'terran_fragmentation_bomb_split_01_emit.bp',
    EmtBpPath .. 'terran_fragmentation_bomb_split_02_emit.bp',
}

ConcussionBombHitNone1 = {
    EmtBpPath .. 'flash_01_emit.bp',
    EmtBpPathNomad .. 'nomad_concussionbomb_hit01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_concussionbomb_hit02_emit.bp',  -- orange sparks large
    EmtBpPathNomad .. 'nomad_concussionbomb_hit05_emit.bp',  -- circular effect at ground
--    EmtBpPathNomad .. 'nomad_concussionbomb_hit07_emit.bp',  -- refraction ring
}

ConcussionBombHitLand1 = TableCat( ConcussionBombHitNone1, {
    EmtBpPathNomad .. 'nomad_concussionbomb_hit03_emit.bp',  -- orange ring shrinking
--    EmtBpPathNomad .. 'nomad_concussionbomb_hit04_emit.bp',  -- chunks
--    EmtBpPathNomad .. 'nomad_concussionbomb_hit06_emit.bp',  -- flat refraction effect
})

ConcussionBombHitWater1 = TableCat( ConcussionBombHitNone1, {
    EmtBpPathNomad .. 'nomad_concussionbomb_hit03_emit.bp',  -- orange ring shrinking
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

ConcussionBombHitUnit1 = TableCat( ConcussionBombHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

ConcussionBombHitAirUnit1 = ConcussionBombHitUnit1
ConcussionBombHitShield1 = ConcussionBombHitNone1
ConcussionBombHitProjectile1 = ConcussionBombHitNone1
ConcussionBombHitProp1 = ConcussionBombHitUnit1
ConcussionBombHitUnderWater1 = ConcussionBombHitUnit1

--------------------------------------------------------------------------
--  Plasma Cannon
--------------------------------------------------------------------------

PlasmaBoltMuzzleFlash = {
    EmtBpPathNomad .. 'nomad_plasmabolt_muzzle01_emit.bp',
    EmtBpPathNomad .. 'nomad_plasmabolt_muzzle02_emit.bp',
    EmtBpPathNomad .. 'nomad_plasmabolt_muzzle03_emit.bp',
    EmtBpPathNomad .. 'nomad_plasmabolt_muzzle04_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

PlasmaBoltBeam = EmtBpPathNomad .. 'nomad_plasmacannon_beam01.bp'

PlasmaBoltTrail = {
--    EmtBpPathNomad .. 'nomad_plasmabolt_trail01_emit.bp',  -- smaller projectile
    EmtBpPathNomad .. 'nomad_plasmabolt_trail02_emit.bp',  -- smoke
    EmtBpPathNomad .. 'nomad_plasmabolt_trail03_emit.bp',  -- larger projectile
}

PlasmaBoltPolyTrail = EmtBpPath .. 'default_polytrail_04_emit.bp'
--PlasmaBoltPolyTrail = ''

PlasmaBoltHitNone1 = {
    EmtBpPathNomad .. 'nomad_plasmabolt_hit02.bp',  -- flash
    EmtBpPathNomad .. 'nomad_plasmabolt_hit03.bp',  -- fountain
}

PlasmaBoltHitLand1 = TableCat( PlasmaBoltHitNone1, {
    EmtBpPathNomad .. 'nomad_plasmabolt_hit01.bp',  -- shock wave
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

PlasmaBoltHitWater1 = TableCat( PlasmaBoltHitNone1, {
    EmtBpPathNomad .. 'nomad_plasmabolt_hit01.bp',  -- shock wave
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

PlasmaBoltHitUnit1 = TableCat( PlasmaBoltHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

PlasmaBoltHitAirUnit1 = PlasmaBoltHitUnit1
PlasmaBoltHitShield1 = PlasmaBoltHitNone1
PlasmaBoltHitProjectile1 = PlasmaBoltHitNone1
PlasmaBoltHitProp1 = PlasmaBoltHitUnit1
PlasmaBoltHitUnderWater1 = PlasmaBoltHitUnit1

--------------------------------------------------------------------------
--  Plasma Bolt Made From Missile
--------------------------------------------------------------------------

RcktArtyPlasmaBoltMuzzleFlash = {
    EmtBpPathNomad .. 'nomad_plasmabolt_muzzle01_emit_rcktarty.bp',
    EmtBpPathNomad .. 'nomad_plasmabolt_muzzle02_emit_rcktarty.bp',
    EmtBpPathNomad .. 'nomad_plasmabolt_muzzle03_emit_rcktarty.bp',
    EmtBpPathNomad .. 'nomad_plasmabolt_muzzle04_emit_rcktarty.bp',
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

RcktArtyPlasmaBoltBeam = EmtBpPathNomad .. 'nomad_plasmacannon_beam01_rcktarty.bp'

RcktArtyPlasmaBoltTrail = {
--    EmtBpPathNomad .. 'nomad_plasmabolt_trail01_emit.bp',  -- smaller projectile
    EmtBpPathNomad .. 'nomad_plasmabolt_trail02_emit_rcktarty.bp',  -- smoke
    EmtBpPathNomad .. 'nomad_plasmabolt_trail03_emit_rcktarty.bp',  -- larger projectile
}

RcktArtyPlasmaBoltPolyTrail = EmtBpPath .. 'default_polytrail_04_emit.bp'
--PlasmaBoltPolyTrail = ''

RcktArtyPlasmaBoltHitNone1 = {
    -- EmtBpPathNomad .. 'nomad_plasmabolt_hit02_rcktarty.bp',  -- flash
	EmtBpPathNomad .. 'nomad_plasmabolt_hit04_rcktarty.bp',  -- flames
    EmtBpPathNomad .. 'smoke_black_arty.bp',  -- smoke
	EmtBpPathNomad .. 'nomad_plasmabolt_hit03_rcktarty.bp',  -- fountain
	EmtBpPathNomad .. 'nomad_plasmabolt_hit01_rcktarty.bp',  -- shock wave
}

RcktArtyPlasmaBoltHitLand1 = TableCat( RcktArtyPlasmaBoltHitNone1, {
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

RcktArtyPlasmaBoltHitWater1 = TableCat( RcktArtyPlasmaBoltHitNone1, {
    EmtBpPathNomad .. 'nomad_plasmabolt_hit01_rcktarty.bp',  -- shock wave
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

RcktArtyPlasmaBoltHitUnit1 = TableCat( RcktArtyPlasmaBoltHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

RcktArtyPlasmaBoltHitAirUnit1 = PlasmaBoltHitUnit1
RcktArtyPlasmaBoltHitShield1 = PlasmaBoltHitNone1
RcktArtyPlasmaBoltHitProjectile1 = PlasmaBoltHitNone1
RcktArtyPlasmaBoltHitProp1 = PlasmaBoltHitUnit1
RcktArtyPlasmaBoltHitUnderWater1 = PlasmaBoltHitUnit1

--------------------------------------------------------------------------
--  Nomad Phase-Ray emitters
--------------------------------------------------------------------------
-- Used by beamer

PhaseRayChargeUpFxStart = {
    EmtBpPath .. 'nomad_phaseray_charge01_emit.bp',  -- a series of flashes
}

PhaseRayChargeUpFxPerm = {
    EmtBpPath .. 'nomad_phaseray_charge02_emit.bp',  -- constant flashing
}

PhaseRayBeam = {
    EmtBpPathNomad .. 'nomad_phaseray_beam01_emit.bp',
}

PhaseRayMuzzle = {
    EmtBpPathNomad .. 'nomad_phaseray_muzzle01_emit.bp',  -- sparks
    EmtBpPathNomad .. 'nomad_phaseray_muzzle02_emit.bp',  -- circular effect shrinking
    EmtBpPathNomad .. 'nomad_phaseray_muzzle03_emit.bp',  -- emitter to the right
    EmtBpPathNomad .. 'nomad_phaseray_muzzle04_emit.bp',  -- emitter to the left
    EmtBpPathNomad .. 'nomad_phaseray_muzzle05_emit.bp',  -- glowing stars effect
    EmtBpPathNomad .. 'nomad_phaseray_muzzle06_emit.bp',  -- faint star effect
    EmtBpPathNomad .. 'nomad_phaseray_muzzle07_emit.bp',  -- glow effect
}

PhaseRayBeamEnd = {
    EmtBpPathNomad .. 'nomad_phaseray_hit01_emit.bp',  -- spark flower
    EmtBpPathNomad .. 'nomad_phaseray_hit03_emit.bp',  -- core, 'fire'
    EmtBpPathNomad .. 'nomad_phaseray_hit04_emit.bp',  -- extra fire effects, random
}

PhaseRayFakeBeam = PhaseRayBeam

PhaseRayFakeBeamMuzzle = {
    EmtBpPathNomad .. 'nomad_phaseray_muzzle02_emit.bp',  -- circular effect shrinking
    EmtBpPathNomad .. 'nomad_phaseray_muzzle05_emit.bp',  -- glowing stars effect
    EmtBpPathNomad .. 'nomad_phaseray_muzzle07_emit.bp',  -- glow effect
    EmtBpPathNomad .. 'nomad_phaseray_muzzle08_emit.bp',  -- flash
}

PhaseRayFakeBeamMuzzleBeamingStopped = {
    EmtBpPathNomad .. 'nomad_phaseray_muzzle08_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_phaseray_muzzle09_emit.bp',  -- glow fading away
    EmtBpPathNomad .. 'nomad_phaseray_muzzle10_emit.bp',  -- star glow fading away
}

PhaseRayHitNone1 = {
}

PhaseRayHitLand1 = TableCat( PhaseRayHitNone1, {
    EmtBpPathNomad .. 'nomad_phaseray_hit02_emit.bp',  -- circle effect at ground
    EmtBpPathNomad .. 'nomad_phaseray_hit05_emit.bp',  -- sparks
})

PhaseRayHitWater1 = PhaseRayHitLand1

PhaseRayHitUnit1 = TableCat( PhaseRayHitNone1, {
    EmtBpPathNomad .. 'nomad_phaseray_hit05_emit.bp',  -- sparks
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

PhaseRayHitAirUnit1 = PhaseRayHitUnit1
PhaseRayHitShield1 = PhaseRayHitNone1
PhaseRayHitProjectile1 = PhaseRayHitUnit1
PhaseRayHitProp1 = PhaseRayHitUnit1
PhaseRayHitUnderWater1 = PhaseRayHitUnit1


-- Used by T3 tank
PhaseRayBeamCannon = {
    EmtBpPathNomad .. 'nomad_phaseray_beam02_emit.bp',
}

PhaseRayCannonMuzzle = {
--    EmtBpPathNomad .. 'nomad_phaseray_muzzle01_emit.bp',  -- sparks
    EmtBpPathNomad .. 'nomad_phaseray_muzzle02_emit.bp',  -- circular effect shrinking
    EmtBpPathNomad .. 'nomad_phaseray_muzzle03_emit.bp',  -- emitter to the right
    EmtBpPathNomad .. 'nomad_phaseray_muzzle04_emit.bp',  -- emitter to the left
    EmtBpPathNomad .. 'nomad_phaseray_muzzle05_emit.bp',  -- glowing stars effect
    EmtBpPathNomad .. 'nomad_phaseray_muzzle06_emit.bp',  -- faint star effect
    EmtBpPathNomad .. 'nomad_phaseray_muzzle07_emit.bp',  -- glow effect
}

PhaseRayCannonBeamEnd = {
    EmtBpPathNomad .. 'nomad_phaseray_hit01_emit.bp',  -- spark flower
    EmtBpPathNomad .. 'nomad_phaseray_hit03_emit.bp',  -- core, 'fire'
    EmtBpPathNomad .. 'nomad_phaseray_hit04_emit.bp',  -- extra fire effects, random
}

PhaseRayCannonHitNone1 = {
    EmtBpPathNomad .. 'nomad_phaseray_hit06_emit.bp',  -- flash
}

PhaseRayCannonHitLand1 = TableCat( PhaseRayCannonHitNone1, {
--    EmtBpPathNomad .. 'nomad_phaseray_hit02_emit.bp',  -- circle effect at ground
    EmtBpPathNomad .. 'nomad_phaseray_hit05_emit.bp',  -- sparks
})

PhaseRayCannonHitWater1 = PhaseRayCannonHitLand1

PhaseRayCannonHitUnit1 = TableCat( PhaseRayCannonHitNone1, {
    EmtBpPathNomad .. 'nomad_phaseray_hit05_emit.bp',  -- sparks
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

PhaseRayCannonHitAirUnit1 = PhaseRayCannonHitUnit1
PhaseRayCannonHitShield1 = PhaseRayCannonHitNone1
PhaseRayCannonHitProjectile1 = PhaseRayCannonHitUnit1
PhaseRayCannonHitProp1 = PhaseRayCannonHitUnit1
PhaseRayCannonHitUnderWater1 = PhaseRayCannonHitUnit1

--------------------------------------------------------------------------
--  Nomad Energy projectile
--------------------------------------------------------------------------
-- used on T2 destroyer and T2 static artillery and t3 bomber

EnergyProjMuzzleFlash = {
    EmtBpPathNomad .. 'nomad_energyproj_muzzleflash01_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

EnergyProjTrail = {
    EmtBpPathNomad .. 'nomad_energyproj_trail01_emit.bp',  -- red projectile
    EmtBpPathNomad .. 'nomad_energyproj_trail02_emit.bp',  -- star effect
}
EnergyProjPolyTrail = EmtBpPathNomad .. 'nomad_energyproj_polytrail02_emit.bp'  -- white long line

EnergyProjHitNone1 = {
    EmtBpPathNomad .. 'nomad_energyproj_hit02_emit.bp',  -- short star effect large
    EmtBpPathNomad .. 'nomad_energyproj_hit07_emit.bp',  -- short flash
}

EnergyProjHitLand1 = {  -- no dirt emitters on purpuse
    EmtBpPathNomad .. 'nomad_energyproj_hit01_emit.bp',  -- slow flash
    EmtBpPathNomad .. 'nomad_energyproj_hit02_emit.bp',  -- short star effect large
    EmtBpPathNomad .. 'nomad_energyproj_hit03_emit.bp',  -- circular effect at ground
    EmtBpPathNomad .. 'nomad_energyproj_hit04_emit.bp',  -- sparks moving up
    EmtBpPathNomad .. 'nomad_energyproj_hit05_emit.bp',  -- flames
    EmtBpPathNomad .. 'nomad_energyproj_hit06_emit.bp',  -- flame refraction effect
}

EnergyProjHitWater1 = EnergyProjHitLand1

EnergyProjHitUnit1 = EnergyProjHitLand1

EnergyProjHitAirUnit1 = EnergyProjHitUnit1
EnergyProjHitShield1 = EnergyProjHitNone1
EnergyProjHitProjectile1 = EnergyProjHitNone1
EnergyProjHitProp1 = EnergyProjHitUnit1
EnergyProjHitUnderWater1 = EnergyProjHitUnit1

-- used by exp, dropped from high. These are mostly the same as above but sized 300%
EnergyProjHitNone2 = {
    EmtBpPathNomad .. 'nomad_energyproj_large_hit02_emit.bp',  -- short star effect large
    EmtBpPathNomad .. 'nomad_energyproj_large_hit07_emit.bp',   -- short flash
}

EnergyProjHitLand2 = {
    EmtBpPathNomad .. 'nomad_energyproj_large_hit01_emit.bp',  -- slow flash
    EmtBpPathNomad .. 'nomad_energyproj_large_hit02_emit.bp',  -- short star effect large
	EmtBpPathNomad .. 'nomad_energyproj_large_hit02_secondary_emit.bp',  -- even shorter star effect large, imitates flash
    EmtBpPathNomad .. 'nomad_energyproj_large_hit02_tertiary_emit.bp',  -- longer star effect giving illusion of expansion
	EmtBpPathNomad .. 'nomad_energyproj_large_hit03_emit.bp',  -- circular effect at ground
    EmtBpPathNomad .. 'nomad_energyproj_large_hit04_emit.bp',  -- sparks moving up
    EmtBpPathNomad .. 'nomad_energyproj_large_hit05_emit.bp',  -- flames
    EmtBpPathNomad .. 'nomad_energyproj_large_hit06_emit.bp',  -- flame refraction effect
}

EnergyProjHitWater2 = EnergyProjHitLand2

EnergyProjHitUnit2 = EnergyProjHitLand2

EnergyProjHitAirUnit2 = EnergyProjHitUnit2
EnergyProjHitShield2 = EnergyProjHitNone2
EnergyProjHitProjectile2 = EnergyProjHitNone2
EnergyProjHitProp2 = EnergyProjHitUnit2
EnergyProjHitUnderWater2 = EnergyProjHitUnit2

--------------------------------------------------------------------------
--  Nomad Energy bomb (for SACU death mainly)
--------------------------------------------------------------------------

EnergyBombSurface = {
    EmtBpPathNomad .. 'nomad_energybomb_01_emit.bp',  -- large circular effect at ground
    EmtBpPathNomad .. 'nomad_energybomb_02_emit.bp',  -- sparkles
    EmtBpPathNomad .. 'nomad_energybomb_03_emit.bp',  -- heat refraction
    EmtBpPathNomad .. 'nomad_energybomb_04_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_energybomb_05_emit.bp',  -- slow flash
    EmtBpPathNomad .. 'nomad_energybomb_06_emit.bp',  -- rays
    EmtBpPathNomad .. 'nomad_energybomb_07_emit.bp',  -- cloud 1
    EmtBpPathNomad .. 'nomad_energybomb_08_emit.bp',  -- cloud 2
    EmtBpPathNomad .. 'nomad_energybomb_09_emit.bp',  -- expanding flames
}

EnergyBombUnderWater = {
    EmtBpPathNomad .. 'nomad_energybomb_01_emit.bp',  -- large circular effect at ground
    EmtBpPathNomad .. 'nomad_energybomb_02_emit.bp',  -- sparkles
    EmtBpPathNomad .. 'nomad_energybomb_03_emit.bp',  -- heat refraction
    EmtBpPathNomad .. 'nomad_energybomb_04_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_energybomb_05_emit.bp',  -- slow flash
    EmtBpPathNomad .. 'nomad_energybomb_06_emit.bp',  -- rays
--    EmtBpPathNomad .. 'nomad_energybomb_07_emit.bp',  -- cloud 1
--    EmtBpPathNomad .. 'nomad_energybomb_08_emit.bp',  -- cloud 2
    EmtBpPathNomad .. 'nomad_energybomb_09_emit.bp',  -- expanding flames
}

EnergyBombResidualFlames_Var1 = {
    EmtBpPath .. 'destruction_explosion_smoke_01_emit.bp',
}

EnergyBombResidualFlames_Var2 = {
    EmtBpPath .. 'destruction_explosion_smoke_04_emit.bp',
}

EnergyBombResidualFlames_Var3 = {
    EmtBpPath .. 'destruction_explosion_smoke_05_emit.bp',
}

EnergyBombResidualFlames_Var4 = {
    EmtBpPath .. 'destruction_explosion_smoke_11_emit.bp',
}


--------------------------------------------------------------------------
--  Nomad Nuke missile
--------------------------------------------------------------------------

NukeMissileInitialEffects = {
    EmtBpPath .. 'nuke_munition_launch_trail_02_emit.bp',
}

NukeMissileLaunchEffects = {
    EmtBpPath .. 'nuke_munition_launch_trail_03_emit.bp',
    EmtBpPath .. 'nuke_munition_launch_trail_05_emit.bp',
    EmtBpPath .. 'nuke_munition_launch_trail_07_emit.bp',
}

NukeMissileThrustEffects = {
    EmtBpPath .. 'nuke_munition_launch_trail_04_emit.bp',
    EmtBpPath .. 'nuke_munition_launch_trail_06_emit.bp',
}

NukeMissileBeam = EmtBpPath .. 'missile_exhaust_fire_beam_01_emit.bp'

--------------------------------------------------------------------------
--  Nomad Nuke Blackhole
--------------------------------------------------------------------------

NukeBlackholeFlash = {
    EmtBpPathNomad .. 'nomad_blackhole_06_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_blackhole_11_emit.bp',  -- shockwave ring
    EmtBpPathNomad .. 'nomad_blackhole_18_emit.bp',  -- big flash
}

NukeBlackholeCore = {
--    EmtBpPathNomad .. 'nomad_blackhole_01_emit.bp',  -- large shrinking circle
--    EmtBpPathNomad .. 'nomad_blackhole_02_emit.bp',  -- electric discharges
    EmtBpPathNomad .. 'nomad_blackhole_03_emit.bp',  -- black core
    EmtBpPathNomad .. 'nomad_blackhole_04_emit.bp',  -- refract light stripes inwards
    EmtBpPathNomad .. 'nomad_blackhole_05_emit.bp',  -- refract center core
--    EmtBpPathNomad .. 'nomad_blackhole_07_emit.bp',  -- electric discharges 2
--    EmtBpPathNomad .. 'nomad_blackhole_08_emit.bp',  -- flat distorting ring
    EmtBpPathNomad .. 'nomad_blackhole_09_emit.bp',  -- flat refraction ring
--    EmtBpPathNomad .. 'nomad_blackhole_10_emit.bp',  -- flat ring
--    EmtBpPathNomad .. 'nomad_blackhole_17_emit.bp',  -- fast dark stripe rings
    EmtBpPathNomad .. 'nomad_blackhole_19_emit.bp',  -- rotating cloud rings big
    EmtBpPathNomad .. 'nomad_blackhole_21_emit.bp',  -- rotating cloud rings small
}

NukeBlackholeRadiationBeams = {  -- if changed be sure to update the length and thickness tables below!!
    EmtBpPathNomad .. 'nomad_blackhole_radiationbeam1.bp',
    EmtBpPathNomad .. 'nomad_blackhole_radiationbeam2.bp',
}

NukeBlackholeRadiationBeamLengths = {  -- the length parameter of each beam blueprint
    -50,
    50,
}

NukeBlackholeRadiationBeamThickness = {  -- the thickness parameter of each beam blueprint
    2,
    2,
}

NukeBlackholeGeneric = {
--    EmtBpPathNomad .. 'nomad_blackhole_16_emit.bp',  -- inward stripes
}

NukeBlackholeEnergyBeam1 = EmtBpPath .. 'seraphim_othuy_beam_01_emit.bp'
NukeBlackholeEnergyBeam2 = EmtBpPath .. 'seraphim_othuy_beam_02_emit.bp'
NukeBlackholeEnergyBeam3 = EmtBpPath .. 'seraphim_othuy_beam_03_emit.bp'
NukeBlackholeEnergyBeamEnd = EmtBpPath .. 'seraphim_othuy_hit_01_emit.bp'

NukeBlackholeDissipating = {
    EmtBpPathNomad .. 'nomad_blackhole_22_emit.bp',  -- star and glowing core
}

NukeBlackholeDissipated = {  -- used when the black hole effects are removed
    EmtBpPathNomad .. 'nomad_blackhole_11_emit.bp',  -- shockwave ring
    EmtBpPathNomad .. 'nomad_blackhole_12_emit.bp',  -- smoke cloud
    EmtBpPathNomad .. 'nomad_blackhole_13_emit.bp',  -- large barely visible smoke cloud
    EmtBpPathNomad .. 'nomad_blackhole_14_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_blackhole_15_emit.bp',  -- circle
--    EmtBpPathNomad .. 'nomad_blackhole_20_emit.bp',  -- rotating cloud rings inward
    EmtBpPath .. 'destruction_explosion_concussion_ring_03_emit.bp',
}

NukeBlackholeDustCloud01 = {
    EmtBpPathNomad .. 'nomad_blackhole_dustcloud01_emit.bp',
}

NukeBlackholeDustCloud02 = {
    EmtBpPathNomad .. 'nomad_blackhole_dustcloud02_emit.bp',
}

NukeBlackholeFireball = {
    EmtBpPathNomad .. 'nomad_blackhole_fireball01_emit.bp',
}

NukeBlackholeFireballHit = {
    EmtBpPathNomad .. 'nomad_blackhole_fireball_hit01_emit.bp',
    EmtBpPathNomad .. 'nomad_blackhole_fireball_hit02_emit.bp',
}

NukeBlackholeFireballTrail = {
    EmtBpPathNomad .. 'nomad_blackhole_fireballtrail.bp',
}

NukeBlackholeFireballPolyTrail = EmtBpPathNomad .. 'nomad_blackhole_fireballpolytrail.bp'

NukeBlackholeFireArmSegment1 = {
    EmtBpPathNomad .. 'nomad_blackhole_fireline05_emit.bp',
}

NukeBlackholeFireArmSegment2 = {
    EmtBpPathNomad .. 'nomad_blackhole_fireline04_emit.bp',
}

NukeBlackholeFireArmSegment3 = {
    EmtBpPathNomad .. 'nomad_blackhole_fireline03_emit.bp',
}

NukeBlackholeFireArmSegment4 = {
    EmtBpPathNomad .. 'nomad_blackhole_fireline02_emit.bp',
}

NukeBlackholeFireArmSegment5 = {
    EmtBpPathNomad .. 'nomad_blackhole_fireline01_emit.bp',
}

NukeBlackholeFireArmCenter1 = {
    EmtBpPathNomad .. 'nomad_blackhole_firecenter01_emit.bp',
    EmtBpPathNomad .. 'nomad_blackhole_firecenter03_emit.bp',
    EmtBpPathNomad .. 'nomad_blackhole_firesparks01_emit.bp',
    EmtBpPathNomad .. 'nomad_blackhole_firesparks02_emit.bp',
}

NukeBlackholeFireArmCenter2 = {
    EmtBpPathNomad .. 'nomad_blackhole_firecenter02_emit.bp',
}

ACUDeathBlackholeFlash = NukeBlackholeFlash
ACUDeathBlackholeCore = NukeBlackholeCore
ACUDeathBlackholeGeneric = NukeBlackholeGeneric
ACUDeathBlackholeDissipated = NukeBlackholeDissipated

BlackholeLeftoverPerm = {
    EmtBpPathNomad .. 'nomad_blackhole_leftover_01_emit.bp',  -- fog
    EmtBpPathNomad .. 'nomad_blackhole_leftover_02_emit.bp',  -- ball
    EmtBpPathNomad .. 'nomad_blackhole_leftover_03_emit.bp',  -- ambient fire
}

BlackholePropEffects = {
    EmtBpPathNomad .. 'nomad_blackhole_propeffect01_emit.bp', -- yellow particles
    EmtBpPathNomad .. 'nomad_blackhole_propeffect02_emit.bp', -- brown particles
    EmtBpPathNomad .. 'nomad_blackhole_propeffect03_emit.bp', -- white particles
    EmtBpPathNomad .. 'nomad_blackhole_propeffect04_emit.bp', -- grey particles
--    EmtBpPathNomad .. 'nomad_blackhole_propeffect05_emit.bp', -- dirt chunks
}

--------------------------------------------------------------------------
--  Nomad Construction effects
--------------------------------------------------------------------------

ConstructionBeamsPerBuildBone = 2
ConstructionBeams = {
    EmtBpPathNomad .. 'nomad_construction_beam01.bp',
}

ConstructionBeamStartPoint = {
    EmtBpPathNomad .. 'nomad_construction_beamstart01_emit.bp',  -- flashing orange
}

ConstructionBeamEndPoints = {
    EmtBpPathNomad .. 'nomad_construction_beamend01_emit.bp',  -- flashing orange
    EmtBpPathNomad .. 'nomad_construction_beamend02_emit.bp',  -- the sparks at the end of a build beam
}

ConstructionPulsingFlash = {
    EmtBpPathNomad .. 'nomad_construction_beingbuilt_pulsingflash01_emit.bp',
}

ConstructionDefaultBeingBuiltEffect = {
    EmtBpPathNomad .. 'nomad_construction_beingbuilt01_emit.bp',  -- build plates normal height
}

ConstructionDefaultBeingBuiltEffectHigh = {
    EmtBpPathNomad .. 'nomad_construction_beingbuilt02_emit.bp',  -- build plates extra high
}

ConstructionDefaultBeingBuiltEffectStretched = {
    EmtBpPathNomad .. 'nomad_construction_beingbuilt03_emit.bp',  -- build plates stretched (for long buildings)
}

ConstructionDefaultBeingBuiltEffectsMobile = {
    EmtBpPathNomad .. 'nomad_construction_beingbuiltmobile01_emit.bp'
}

FactoryConstructionField = {
--    EmtBpPathNomad .. 'nomad_factory_constructionplane01_emit.bp',  -- particles moving inwards
--    EmtBpPathNomad .. 'nomad_factory_constructionplane02_emit.bp',  -- flashing orange
    EmtBpPathNomad .. 'nomad_factory_constructionplane03_emit.bp',  -- particles moving inwards, offset 1
    EmtBpPathNomad .. 'nomad_factory_constructionplane04_emit.bp',  -- particles moving inwards, offset 2
}

SCUFactoryBeam = EmtBpPathNomad .. 'nomad_construction_beam01.bp'
SCUFactoryBeamOrigin = {}
SCUFactoryBeamEnd = {}

RepairSelf = ConstructionBeamEndPoints

-----------------------------------------------------------------
-- Reclaim Effects
-----------------------------------------------------------------

ReclaimBeams = {
--    EmtBpPath .. 'reclaim_beam_01_emit.bp',
--    EmtBpPath .. 'reclaim_beam_02_emit.bp',
--    EmtBpPath .. 'reclaim_beam_03_emit.bp',
    EmtBpPathNomad .. 'nomad_reclaim_beam01.bp',
}

ReclaimBeamStartPoint = {
    EmtBpPathNomad .. 'nomad_construction_beamstart01_emit.bp',  -- flashing orange
}

ReclaimBeamEndPoints = {
    EmtBpPathNomad .. 'nomad_reclaim_beamend01_emit.bp',  -- flashing green
    EmtBpPathNomad .. 'nomad_reclaim_beamend02_emit.bp',  -- green stripes inward
    EmtBpPathNomad .. 'nomad_reclaim_beamend03_emit.bp',  -- white stripes inward
    EmtBpPath .. 'reclaim_02_emit.bp',
}

ReclaimObjectAOE = {
    EmtBpPath .. 'reclaim_01_emit.bp',
}

--------------------------------------------------------------------------
--  Dropship
--------------------------------------------------------------------------

DropshipThruster = {
    EmtBpPathNomad .. 'Nomad_dropship_thruster.bp',
    EmtBpPath      .. 'nuke_munition_launch_trail_06_emit.bp',
}

DropshipThrusterBig = {
    EmtBpPathNomad .. 'Nomad_dropship_thruster_big.bp',
    EmtBpPath      .. 'nuke_munition_launch_trail_06_emit.bp',
}

AcuDropshipGroundFire = {
    EmtBpPathNomad .. 'Nomad_surfacefire1.bp',
    EmtBpPathNomad .. 'Nomad_surfacefire2.bp',
    EmtBpPathNomad .. 'Nomad_surfacefire3.bp',
}

--------------------------------------------------------------------------
--  Unit additional effects
--------------------------------------------------------------------------

TankBusterWeaponFired = {
    EmtBpPathNomad .. 'nomad_tankbuster_weaponfired01_emit.bp',  -- shell
    EmtBpPathNomad .. 'nomad_tankbuster_weaponfired02_emit.bp',  -- dark smoke
}

--------------------------------------------------------------------------
--  Shield emitters
--------------------------------------------------------------------------

ShieldDamagedBeams = {
--    EmtBpPathNomad .. 'nomad_shield_beam01.bp',
--    EmtBpPathNomad .. 'nomad_shield_beam02.bp',
--    EmtBpPathNomad .. 'nomad_shield_beam03.bp',
    EmtBpPathNomad .. 'nomad_shield_beam11.bp',
    EmtBpPathNomad .. 'nomad_shield_beam12.bp',
    EmtBpPathNomad .. 'nomad_shield_beam13.bp',
}

ShieldDamagedBeamStartPointEffects = {
--    EmtBpPathNomad .. 'nomad_shield_beamstart01_emit.bp',
    EmtBpPathNomad .. 'nomad_shield_beamstart02_emit.bp',
}

ShieldDamagedBeamEndPointEffects = {
    EmtBpPathNomad .. 'nomad_shield_beamend10_emit.bp', -- blue stars
    EmtBpPathNomad .. 'nomad_shield_beamend11_emit.bp', -- yellow stars
    EmtBpPathNomad .. 'nomad_shield_beamend13_emit.bp', -- red stars

--    EmtBpPathNomad .. 'nomad_shield_beamend12_emit.bp', -- large star effect
    EmtBpPathNomad .. 'nomad_shield_beamend20_emit.bp', -- large star effect

--    EmtBpPathNomad .. 'nomad_shield_beamend01_emit.bp',
--    EmtBpPathNomad .. 'nomad_shield_beamend02_emit.bp',
--    EmtBpPathNomad .. 'nomad_shield_beamend03_emit.bp',
--    EmtBpPathNomad .. 'nomad_shield_beamend04_emit.bp',
}

ShieldEffects = {
    EmtBpPathNomad .. 'nomad_shield_generator_T2_01_emit.bp',
    EmtBpPathNomad .. 'nomad_shield_generator_T2_02_emit.bp',
}

ShieldAmbientEffectBeams = {
    EmtBpPathNomad .. 'nomad_shield_ambientbeam01.bp',
}

ShieldAmbientEffects_NumSimultanious = 3
ShieldAmbientEffects_AvgInterval = 5

StealthShieldEffects = {
    EmtBpPathNomad .. 'nomad_shield_generator_T2_02_emit.bp',
    EmtBpPathNomad .. 'nomad_stealth_generator_T2_01_emit.bp',
    EmtBpPathNomad .. 'nomad_stealth_generator_T2_02_emit.bp',
    EmtBpPathNomad .. 'nomad_stealth_generator_T2_03_emit.bp',
}

--------------------------------------------------------------------------
--  Nomad Orbital Strike Effects
--------------------------------------------------------------------------

OrbitalStrikeMissile_AtmosphereTrail = {
    EmtBpPath .. 'destruction_underwater_sinking_wash_01_emit.bp',
}

--------------------------------------------------------------------------
-- Artillery Support Ability
--------------------------------------------------------------------------

ArtillerySupportActive = {
    EmtBpPathNomad .. 'nomad_artillerysupport01_emit.bp',  -- red ring
}

ArtillerySupportAtTargetLocation = {
    EmtBpPathNomad .. 'targeted_effect_02_emit.bp',  -- red target marker, blinks 5 times
}

--------------------------------------------------------------------------
-- Nomad movement effects
--------------------------------------------------------------------------

-- These 2 are hardcoded in terraintypes.lua
--HoverEffect_Idle = {
--    EmtBpPathNomad .. 'nomad_hover_idle01_emit.bp',
--}
--HoverEffect_Moving = {
--    EmtBpPathNomad .. 'nomad_hover_moving01_emit.bp',
--}

HoverEffect_Moving_Smoke = {
    EmtBpPathNomad .. 'nomad_hover_moving_smoke01_emit.bp',
}

HoverEffect_Stopping_Smoke = {
    EmtBpPathNomad .. 'nomad_hover_stopping_smoke01_emit.bp',
}

HoverEffect_Stopped_Smoke = {
    EmtBpPathNomad .. 'nomad_hover_stopped_smoke01_emit.bp',
}

AirThrusterCruisingBeam = EmtBpPathNomad .. 'nomad_airthruster_cruising01_emit.bp'
AirThrusterIdlingBeam = EmtBpPathNomad .. 'nomad_airthruster_cruising02_emit.bp'

AirThrusterLargeCruisingBeam = EmtBpPathNomad .. 'nomad_airthruster_cruising_large01_emit.bp'
AirThrusterLargeIdlingBeam = EmtBpPathNomad .. 'nomad_airthruster_cruising_large02_emit.bp'

RailgunBoat_Moving_Smoke = {
    EmtBpPathNomad .. 'nomad_hover_moving_smoke01_emit.bp',
}

RailgunBoat_Stopping_Smoke = {
    EmtBpPathNomad .. 'nomad_hover_stopping_smoke01_emit.bp',
}

RailgunBoat_Stopped_Smoke = {
    EmtBpPathNomad .. 'nomad_hover_stopped_smoke01_emit.bp',
}

T2TransportThrusters = {
    EmtBpPathNomad .. 'nomad_t2transport_thruster01_emit.bp',  -- normal thruster
    EmtBpPathNomad .. 'nomad_t2transport_thruster05_emit.bp',  -- thruster heat refraction
}

T2TransportThrusterBurn = {  -- played when the t2 transport descents to pick up or drop off units
    EmtBpPathNomad .. 'nomad_t2transport_thruster02_emit.bp',  -- larger thruster
    EmtBpPathNomad .. 'nomad_t2transport_thruster05_emit.bp',  -- thruster heat refraction
}

T2TransportThrusterBurnSurfaceEffect = {
    EmtBpPathNomad .. 'nomad_t2transport_thruster03_emit.bp',  -- fire ring at surface
    EmtBpPathNomad .. 'nomad_t2transport_thruster05_emit.bp',  -- surface heat refraction
}

T2TransportThrusterBurnWaterSurfaceEffect = {
    EmtBpPathNomad .. 'nomad_t2transport_thruster03_emit.bp',  -- fire ring at surface
    EmtBpPathNomad .. 'nomad_t2transport_thruster05_emit.bp',  -- surface heat refraction
    EmtBpPathNomad .. 'nomad_t2transport_thruster06_emit.bp',  -- water ripples / steam
}

ExpTransportThrusters = {
    EmtBpPathNomad .. 'nomad_exptransport_thruster01_emit.bp',  -- normal thruster
    EmtBpPathNomad .. 'nomad_exptransport_thruster05_emit.bp',  -- thruster heat refraction
}

ExpTransportThrusterBurn = {  -- played when the experimental transport descents to pick up or drop off units
    EmtBpPathNomad .. 'nomad_exptransport_thruster02_emit.bp',  -- larger thruster
    EmtBpPathNomad .. 'nomad_exptransport_thruster05_emit.bp',  -- thruster heat refraction
}

ExpTransportThrusterBurnSurfaceEffect = {
    EmtBpPathNomad .. 'nomad_exptransport_thruster03_emit.bp',  -- fire ring at surface
    EmtBpPathNomad .. 'nomad_exptransport_thruster05_emit.bp',  -- surface heat refraction
}

ExpTransportThrusterBurnWaterSurfaceEffect = {
    EmtBpPathNomad .. 'nomad_exptransport_thruster03_emit.bp',  -- fire ring at surface
    EmtBpPathNomad .. 'nomad_exptransport_thruster05_emit.bp',  -- surface heat refraction
    EmtBpPathNomad .. 'nomad_exptransport_thruster06_emit.bp',  -- water ripples / steam
}

--------------------------------------------------------------------------
--  Nomad Destruction effects
--------------------------------------------------------------------------

ExpTransportDestruction = {
    EmtBpPath .. 'destruction_explosion_concussion_ring_03_emit.bp',
    EmtBpPath .. 'explosion_fire_sparks_02_emit.bp',
--    EmtBpPath .. 'distortion_ring_01_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_01_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_02_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_03_emit.bp',
    EmtBpPathNomad .. 'Nomad_surfacefire1.bp',
    EmtBpPathNomad .. 'Nomad_surfacefire2.bp',
    EmtBpPathNomad .. 'Nomad_surfacefire3.bp',
}

SCUDestructionRegularSurface = {
    EmtBpPath .. 'destruction_explosion_concussion_ring_01_emit.bp',
    EmtBpPath .. 'destruction_explosion_cloud_01_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
    EmtBpPathNomad .. 'nomad_SCUDestruction01_emit.bp',
}

SCUDestructionRegularUnderWater = {
    EmtBpPathNomad .. 'nomad_SCUDestruction02_emit.bp',  -- bubbles
    EmtBpPathNomad .. 'nomad_SCUDestruction03_emit.bp',  -- water effect 1 (looks like a cloud)
    EmtBpPathNomad .. 'nomad_SCUDestruction04_emit.bp',  -- water effect 2
    EmtBpPathNomad .. 'nomad_SCUDestruction05_emit.bp',  -- a few flashes
}

SCUDestructionSmallExplosionsSurface = {
    EmtBpPath .. 'destruction_explosion_fire_plume_02_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
}

SCUDestructionSmallExplosionsUnderWater = {
    EmtBpPathNomad .. 'nomad_SCUDestruction07_emit.bp',  -- smaller version of water effect 1 (looks like a cloud)
    EmtBpPathNomad .. 'nomad_SCUDestruction06_emit.bp',  -- smaller flashes
}

--------------------------------------------------------------------------
--  NOMAD CAPACITOR
--------------------------------------------------------------------------

CapacitorBeingUsed = {
    EmtBpPathNomad .. 'nomad_capacitor02_emit.bp',
}

CapacitorCharging = {
    EmtBpPathNomad .. 'nomad_capacitor01_emit.bp',
}

CapacitorEmpty = {
    EmtBpPathNomad .. 'nomad_capacitor01_emit.bp',
}

CapacitorFull = {
    EmtBpPathNomad .. 'nomad_capacitor03_emit.bp',
}

--------------------------------------------------------------------------
--  Nomad Buoys
--------------------------------------------------------------------------

BuoyMuzzleFx = {}

BuoyTrail = {
    EmtBpPath .. 'nomad_buoy_light01_emit.bp',  -- flashing orange light
}
BuoyPolyTrail = EmtBpPath .. 'default_polytrail_01_emit.bp'

-- no buoy created if projectile collides with anything other than land, unit or prop
BuoyHitNone1 = {}

BuoyHitLand1 = TableCat( BuoyHitNone1, {
    EmtBpPath .. 'buoy_impact01_emit.bp',
    EmtBpPath .. 'buoy_impact02_emit.bp',
    EmtBpPath .. 'buoy_impact03_emit.bp',
    EmtBpPath .. 'buoy_impact04_emit.bp',
    EmtBpPath .. 'buoy_impact05_emit.bp',
    EmtBpPath .. 'buoy_impact06_emit.bp',
    EmtBpPath .. 'buoy_impact07_emit.bp',
})

BuoyHitAirUnit1 = BuoyHitNone1
BuoyHitShield1 = BuoyHitNone1
BuoyHitProjectile1 = BuoyHitNone1
BuoyHitProp1 = BuoyHitNone1
BuoyHitWater1 = BuoyHitLand1
BuoyHitUnit1 = BuoyHitNone1
BuoyHitUnderWater1 = BuoyHitNone1

-- specific case templates

BuoyLights = {  -- emitters that play when the buoy is on the ground (permanent effect, until destroyed)
    EmtBpPathNomad .. 'nomad_buoy_light01_emit.bp',  -- flashing orange light
}

BuoyActive = {  -- emitters for when buoy is activated
    EmtBpPathNomad .. 'nomad_buoy_light02_emit.bp',  -- red flashing star light
}

BuoyDestroyed = {  -- emitters that play when the buoy is destroyed
}

IntelProbeSurfaceActive = BuoyActive
IntelProbeSurfaceDestroyed = BuoyDestroyed
IntelProbeSurfaceLights = BuoyLights

--------------------------------------------------------------------------
--  NOMAD AMBIENT UNIT EMITTERS
--------------------------------------------------------------------------

NavalAntennaeLights_Left = {
--    EmtBpPathNomad .. 'nomad_navallight01_emit.bp',  -- constant green light
--    EmtBpPathNomad .. 'nomad_navallight02_emit.bp',  -- constant red light
--    EmtBpPathNomad .. 'nomad_navallight03_emit.bp',  -- flashing green light morse
    EmtBpPathNomad .. 'nomad_navallight04_emit.bp',  -- flashing red light morse
--    EmtBpPathNomad .. 'nomad_navallight05_emit.bp',  -- constant blue light
--    EmtBpPathNomad .. 'nomad_navallight06_emit.bp',  -- flashing blue light
--    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}

NavalAntennaeLights_Right = {
    EmtBpPathNomad .. 'nomad_navallight04_emit.bp',  -- flashing red light morse
}

NavalAntennaeLights_Left_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}

NavalAntennaeLights_Right_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}

AntennaeLights1 = {
    EmtBpPathNomad .. 'nomad_light01_emit.bp',  -- chase light 1
    EmtBpPathNomad .. 'nomad_light02_emit.bp',  -- chase light 2
}
AntennaeLights2 = {
    EmtBpPathNomad .. 'nomad_light02_emit.bp',  -- chase light 2
    EmtBpPathNomad .. 'nomad_light03_emit.bp',  -- chase light 3
}
AntennaeLights3 = {
    EmtBpPathNomad .. 'nomad_light03_emit.bp',  -- chase light 3
    EmtBpPathNomad .. 'nomad_light04_emit.bp',  -- chase light 4
}
AntennaeLights4 = {
    EmtBpPathNomad .. 'nomad_light04_emit.bp',  -- chase light 4
    EmtBpPathNomad .. 'nomad_light05_emit.bp',  -- chase light 5
}
AntennaeLights5 = {
    EmtBpPathNomad .. 'nomad_light05_emit.bp',  -- chase light 5
    EmtBpPathNomad .. 'nomad_light06_emit.bp',  -- chase light 6
}
AntennaeLights6 = {
    EmtBpPathNomad .. 'nomad_light06_emit.bp',  -- chase light 6
    EmtBpPathNomad .. 'nomad_light07_emit.bp',  -- chase light 7
}
AntennaeLights7 = {
    EmtBpPathNomad .. 'nomad_light07_emit.bp',  -- chase light 7
    EmtBpPathNomad .. 'nomad_light08_emit.bp',  -- chase light 8
}
AntennaeLights8 = {
    EmtBpPathNomad .. 'nomad_light08_emit.bp',  -- chase light 8
    EmtBpPathNomad .. 'nomad_light09_emit.bp',  -- chase light 9
}
AntennaeLights9 = {
    EmtBpPathNomad .. 'nomad_light09_emit.bp',  -- chase light 9
    EmtBpPathNomad .. 'nomad_light10_emit.bp',  -- chase light 10
}
AntennaeLights10 = {
    EmtBpPathNomad .. 'nomad_light10_emit.bp',  -- chase light 10
    EmtBpPathNomad .. 'nomad_light01_emit.bp',  -- chase light 1
}

AntennaeLights_1_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_2_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_3_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_4_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_5_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_6_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_7_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_8_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_9_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_10_Bombard = {
    EmtBpPathNomad .. 'nomad_navallight07_emit.bp',  -- flashing purple light
}

--------------------------------------------------------------------------
--  NOMAD AMBIENT STRUCTURE EMITTERS
--------------------------------------------------------------------------

T1HydroPowerPlantSurface1 = {
    EmtBpPath .. 'hydrocarbon_smoke_01_emit.bp',  -- thick smoke
    EmtBpPathNomad .. 'nomad_t1hpg_ambient03.bp',  -- sparkles (bigger)
}

T1HydroPowerPlantSurface2 = {
    EmtBpPathNomad .. 'nomad_t1hpg_ambient02.bp',  -- sparkles
}

T1HydroPowerPlantSubmerged1 = {
    EmtBpPath .. 'nomad_t1hpg_ambient01.bp',  -- bubbles
}

T1HydroPowerPlantSubmerged2 = {
    EmtBpPath .. 'nomad_t1hpg_ambient01.bp',  -- bubbles
}

T2MFAmbient = {
    EmtBpPathNomad .. 'nomad_t2mf_ambient01_emit.bp',  -- heat refraction
}

T3MFAmbient = {
    EmtBpPathNomad .. 'nomad_t3mf_ambient01_emit.bp',  -- heat refraction
    EmtBpPathNomad .. 'nomad_t3mf_ambient02_emit.bp',  -- emit effect at core
}

T1PGAmbient = {
    EmtBpPathNomad .. 'nomad_t1pg_ambient01_emit.bp',
}

T2PGAmbient = {
    EmtBpPathNomad .. 'nomad_t2pg_ambient01_emit.bp',
--    EmtBpPathNomad .. 'nomad_t2pg_ambient02_emit.bp',
}

T3PGAmbient = {
    EmtBpPathNomad .. 'nomad_t3pg_ambient01_emit.bp',
}

T2PGAmbientDischargeBeam = EmtBpPathNomad .. 'nomad_t2pg_ambientbeam.bp'

T3MassExtractorActiveEffects = {
    EmtBpPathNomad .. 'nomad_t3mex_active01_emit.bp',
    EmtBpPathNomad .. 'nomad_t3mex_active02_emit.bp',
    EmtBpPathNomad .. 'nomad_t3mex_active03_emit.bp',
}

T3MassExtractorActiveBeams = {
    EmtBpPathNomad .. 'nomad_t3mex_active_beam01.bp',
}

T2TacticalMissileDefenseTargetAcquired = {
    EmtBpPathNomad .. 'nomad_tmd_active01_emit.bp',
}

T2MobileTacticalMissileDefenseTargetAcquired = {
    EmtBpPathNomad .. 'nomad_tmd_active01_emit.bp',
}

--------------------------------------------------------------------------
-- Intelligence overcharge effects
--------------------------------------------------------------------------

T1RadarOvercharge = {
    EmtBpPathNomad .. 'nomad_intelboost_active01_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_active02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T1RadarOverchargeRecovery = {}

T1RadarOverchargeCharging = {
    EmtBpPathNomad .. 'nomad_intelboost_charging02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T1RadarOverchargeExplosion = {
    EmtBpPathNomad .. 'nomad_intelboost_empblast01_emit.bp',  -- light blue effect at ground
    EmtBpPathNomad .. 'nomad_intelboost_empblast02_emit.bp',  -- electricity effect at ground
    EmtBpPathNomad .. 'nomad_intelboost_empblast03_emit.bp',  -- short expanding large electricity effect
    EmtBpPathNomad .. 'nomad_intelboost_empblast04_emit.bp',  -- short flash
    EmtBpPathNomad .. 'nomad_intelboost_empblast05_emit.bp',  -- short flat flash
}

T2RadarOvercharge = {
    EmtBpPathNomad .. 'nomad_intelboost_active01_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_active02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T2RadarOverchargeRecovery = {}

T2RadarOverchargeCharging = {
    EmtBpPathNomad .. 'nomad_intelboost_charging02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T2RadarOverchargeExplosion = T1RadarOverchargeExplosion

T3RadarOvercharge = {
    EmtBpPathNomad .. 'nomad_intelboost_active01_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_active02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T3RadarOverchargeRecovery = {}

T3RadarOverchargeCharging = {
    EmtBpPathNomad .. 'nomad_intelboost_charging02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T3RadarOverchargeExplosion = T1RadarOverchargeExplosion

T1SonarOvercharge = {
    EmtBpPathNomad .. 'nomad_intelboost_active01_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_active02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T1SonarOverchargeRecovery = {}

T1SonarOverchargeCharging = {
    EmtBpPathNomad .. 'nomad_intelboost_charging02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T1SonarOverchargeExplosion = T1RadarOverchargeExplosion

T2SonarOvercharge = {
    EmtBpPathNomad .. 'nomad_intelboost_active01_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_active02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T2SonarOverchargeRecovery = {}

T2SonarOverchargeCharging = {
    EmtBpPathNomad .. 'nomad_intelboost_charging02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T2SonarOverchargeExplosion = T1RadarOverchargeExplosion

T3SonarOvercharge = {
    EmtBpPathNomad .. 'nomad_intelboost_active01_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_active02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T3SonarOverchargeRecovery = {}

T3SonarOverchargeCharging = {
    EmtBpPathNomad .. 'nomad_intelboost_charging02_emit.bp',
    EmtBpPathNomad .. 'nomad_intelboost_charging03_emit.bp',
}

T3SonarOverchargeExplosion = T1RadarOverchargeExplosion

--------------------------------------------------------------------------
--  Meteor Fx
--------------------------------------------------------------------------

MeteorLandImpact = {
    EmtBpPathNomad .. 'MeteorImpact01.bp',  -- flash
    EmtBpPathNomad .. 'MeteorImpact02.bp',  -- fire rings
    EmtBpPathNomad .. 'MeteorImpact03.bp',  -- circular dust cloud
--    EmtBpPathNomad .. 'MeteorImpact04.bp',  -- black stripes outwards
    EmtBpPathNomad .. 'MeteorImpact05.bp',  -- expelled stars
--    EmtBpPathNomad .. 'MeteorImpact06.bp',  -- expelled dirt chunks
    EmtBpPathNomad .. 'MeteorImpact10.bp',  -- residual smoke plumes
    EmtBpPathNomad .. 'MeteorImpact11.bp',  -- residual smoke / brightish afterglow
    EmtBpPathNomad .. 'MeteorImpact12.bp',  -- residual smoke upwards (like other ACUs have)
}

MeteorSeabedImpact = {
    EmtBpPathNomad .. 'MeteorImpact01.bp',
--    EmtBpPathNomad .. 'MeteorImpact02.bp',
--    EmtBpPathNomad .. 'MeteorImpact03.bp',
--    EmtBpPathNomad .. 'MeteorImpact04.bp',
--    EmtBpPathNomad .. 'MeteorImpact05.bp',
    EmtBpPathNomad .. 'MeteorImpact06.bp',
    EmtBpPathNomad .. 'MeteorImpact09.bp',  -- under water flash
}

MeteorWaterImpact = {
--    EmtBpPathNomad .. 'MeteorImpact01.bp',
--    EmtBpPathNomad .. 'MeteorImpact02.bp',
    EmtBpPathNomad .. 'MeteorImpact03.bp',
--    EmtBpPathNomad .. 'MeteorImpact04.bp',
--    EmtBpPathNomad .. 'MeteorImpact05.bp',
    EmtBpPathNomad .. 'MeteorImpact06.bp',
    EmtBpPathNomad .. 'MeteorImpact07.bp',  -- water plume
    EmtBpPathNomad .. 'MeteorImpact08.bp',  -- water ripples / ring
}


MeteorResidualSmoke01 = {
    EmtBpPathNomad .. 'MeteorResidualSmoke01.bp',
}

MeteorResidualSmoke02 = {
    EmtBpPathNomad .. 'MeteorResidualSmoke02.bp',
}

MeteorResidualSmoke03 = {
    EmtBpPathNomad .. 'MeteorResidualSmoke03.bp',
}

MeteorSmokeRing = {
    EmtBpPathNomad .. 'MeteorSmokeRing01.bp',
}

MeteorTrail = {
    EmtBpPathNomad .. 'MeteorTrail01.bp',  -- thick dark smoke
    EmtBpPathNomad .. 'MeteorTrail02.bp',  -- fireball
    EmtBpPathNomad .. 'MeteorTrail03.bp',  -- grey smoke
--    EmtBpPathNomad .. 'MeteorTrail04.bp',  -- blueish smoke
}

MeteorUnderWaterTrail = {
--    EmtBpPathNomad .. 'MeteorTrail01.bp',  -- thick dark smoke
    EmtBpPathNomad .. 'MeteorTrail02.bp',  -- fireball
    EmtBpPathNomad .. 'MeteorTrail03.bp',  -- grey smoke
    EmtBpPathNomad .. 'MeteorTrail04.bp',  -- blueish smoke
}

ACUMeteorLandImpact = TableCat(MeteorLandImpact, {
})

ACUMeteorSeabedImpact = TableCat(MeteorSeabedImpact, {
})

ACUMeteorWaterImpact = TableCat(MeteorWaterImpact, {
})

ACUMeteorResidualSmoke01 = TableCat(MeteorResidualSmoke01, {
})

ACUMeteorResidualSmoke02 = TableCat(MeteorResidualSmoke02, {
})

ACUMeteorResidualSmoke03 = TableCat(MeteorResidualSmoke03, {
})

ACUMeteorSmokeRing = TableCat(MeteorSmokeRing, {
})

ACUMeteorTrail = TableCat(MeteorTrail, {
})

ACUMeteorUnderWaterTrail = TableCat(MeteorUnderWaterTrail, {
})

ACUMeteorCoverOpen = {
    EmtBpPathNomad .. 'nomad_meteorcover_openingsteam01_emit.bp',  -- Smoke rings slowly rising
}

ACUMeteorCoverLaunch = {
    EmtBpPathNomad .. 'nomad_meteorcover_launch01_emit.bp',  -- several small flashes
}

ACUMeteorCoverExplode = {
    EmtBpPathNomad .. 'nomad_meteorcover_explode01_emit.bp',  -- flash
    EmtBpPathNomad .. 'nomad_meteorcover_explode03_emit.bp',  -- fast explosion
    EmtBpPathNomad .. 'nomad_meteorcover_explode04_emit.bp',  -- fire cloud
    EmtBpPathNomad .. 'nomad_meteorcover_explode05_emit.bp',  -- smoke
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    EmtBpPath .. 'destruction_explosion_sparks_02_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
    EmtBpPath .. 'dust_cloud_02_emit.bp',
    EmtBpPath .. 'dust_cloud_04_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_04_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_05_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_04_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_05_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_04_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_05_emit.bp',
}

ACUMeteorCoverExplodeLand = TableCat( ACUMeteorCoverExplode, {
    EmtBpPathNomad .. 'nomad_meteorcover_explode07_emit.bp',  -- shockwave rings
})

ACUMeteorCoverExplodeWater = TableCat( ACUMeteorCoverExplode, {
    EmtBpPathNomad .. 'nomad_meteorcover_explode07_emit.bp',  -- shockwave rings
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

ACUMeteorCoverExplodeUnit = TableCat( ACUMeteorCoverExplode, {
    EmtBpPath .. 'destruction_explosion_sparks_02_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

ACUMeteorCoverExplodeAirUnit = ACUMeteorCoverExplodeUnit
ACUMeteorCoverExplodeShield = ACUMeteorCoverExplode
ACUMeteorCoverExplodeProjectile = ACUMeteorCoverExplodeUnit
ACUMeteorCoverExplodeProp = ACUMeteorCoverExplodeUnit
ACUMeteorCoverExplodeUnderWater = ACUMeteorCoverExplodeLand

--------------------------------------------------------------------------
--  Generic ambient effects
--------------------------------------------------------------------------

TreeFire = {
    EmtBpPathNomad .. 'tree_fire01_emit.bp',
    EmtBpPath .. 'destruction_damaged_fire_distort_01_emit.bp',
    EmtBpPath .. 'forest_fire_smoke_01_emit.bp',
}

FallenTreeFire = TreeFire

TreeBigFire = {
    EmtBpPathNomad .. 'tree_bigfire01_emit.bp',  -- flames
    EmtBpPathNomad .. 'tree_bigfire02_emit.bp',  -- heat effect
    EmtBpPathNomad .. 'tree_bigfire03_emit.bp',  -- low ground effect
    EmtBpPath .. 'destruction_damaged_smoke_02_emit.bp',
}

FallenTreeBigFire = TreeBigFire

TreeAfterFireEffects = {
    EmtBpPath .. 'tree_afterfiresmoke01_emit.bp',
}

TreeDisintegrate = {
    EmtBpPathNomad .. 'tree_disintegrate01_emit.bp',
}

FallenTreeDisintegrate = TreeDisintegrate

--------------------------------------------------------------------------
--  NOMAD PLASMAFLAMETHROWER-EMITTERS
--------------------------------------------------------------------------

NPlasmaFlameThrowerHitLand01 = {
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_flash_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_thick_smoke_emit.bp',
    --EmtBpPath .. 'Plasmaflamethrower/plasmaflame_fire_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_thin_smoke_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_01_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_02_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_03_emit.bp',
}
NPlasmaFlameThrowerHitWater01 = {
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_waterflash_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_water_smoke_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_oilslick_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_lines_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_water_ripples_emit.bp',
    EmtBpPath .. 'Plasmaflamethrower/plasmaflame_water_dots_emit.bp',    
}
