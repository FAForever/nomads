local EffectTemplate = import('/lua/EffectTemplates.lua')
local EmtBpPath = '/effects/emitters/'
local EmtBpPathNomads = '/effects/emitters/'
local TableCat = import('/lua/utilities.lua').TableCat


--------------------------------------------------------------------------
--  Nomads Kinetic Cannon
--------------------------------------------------------------------------
-- Used on ACU, T1 tank destroyer, Crawler

KineticCannonMuzzleFlash = {
    EmtBpPath .. 'cannon_artillery_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_07_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_10_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_03_emit.bp',
}

KineticCannonTrail = {
    EmtBpPathNomads .. 'nomads_kineticcannon_trail02_emit.bp',
}

KineticCannonPolyTrail = EmtBpPath .. 'default_polytrail_04_emit.bp'

KineticCannonHitNone1 = {
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_01_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_03_emit.bp',  -- fast explosion
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_05_emit.bp',  -- smoke
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_06_emit.bp',  -- long explosion
}

KineticCannonHitLand1 = TableCat( KineticCannonHitNone1, {
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_07_emit.bp',  -- shockwave rings
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

KineticCannonHitWater1 = TableCat( KineticCannonHitNone1, {
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_07_emit.bp',  -- shockwave rings
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

KineticCannonPolyTrail2 = EmtBpPath .. 'nomads_kineticcannon_polytrail01.bp'

KineticCannonHitNone2 = TableCat( KineticCannonHitNone1, {
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_04_emit.bp',  -- short flames
})

KineticCannonHitLand2 = TableCat( KineticCannonHitLand1, {
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_04_emit.bp',  -- short flames
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_07_emit.bp',  -- shockwave rings
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

KineticCannonHitWater2 = KineticCannonHitWater1

KineticCannonHitUnit2 = TableCat( KineticCannonHitUnit1, {
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_04_emit.bp',  -- short flames
})

KineticCannonHitAirUnit2 = KineticCannonHitUnit2
KineticCannonHitShield2 = KineticCannonHitNone2
KineticCannonHitProjectile2 = KineticCannonHitUnit2
KineticCannonHitProp2 = KineticCannonHitUnit2
KineticCannonHitUnderWater2 = KineticCannonHitLand2

--------------------------------------------------------------------------
--  Nomads AP Cannon weapon
--------------------------------------------------------------------------
-- Used by ACU and SCU

APCannonMuzzleFlash = {
    EmtBpPath .. 'nomads_apcannon_muzzle_flash_01_emit.bp',
	EmtBpPath .. 'nomads_apcannon_muzzle_flash_02_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_07_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_10_emit.bp',
}

APCannonTrail = {
    EmtBpPathNomads .. 'nomads_apcannon_trail01_emit.bp',
}

APCannonPolyTrail = EmtBpPath .. 'nomads_apcannon_polytrail01_emit.bp'

APCannonHitNone1 = {
    EmtBpPathNomads .. 'nomads_apcannon_hit_02_emit.bp',  -- small explosion
    EmtBpPathNomads .. 'nomads_apcannon_hit_04_emit.bp',  -- fire
    EmtBpPathNomads .. 'nomads_apcannon_hit_05_emit.bp',  -- color changing fast shockwave
}

APCannonHitLand1 = TableCat( APCannonHitNone1, {
    EmtBpPathNomads .. 'nomads_apcannon_hit_03_emit.bp',  -- shockwave rings
--    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

APCannonHitWater1 = TableCat( APCannonHitNone1, {
    EmtBpPathNomads .. 'nomads_apcannon_hit_03_emit.bp',  -- shockwave rings
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

--------------------------------------------------------------------- a version with a DoT effect (only visuals)
APCannonMuzzleFlash2 = {
    EmtBpPath .. 'cannon_artillery_muzzle_flash_01_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_07_emit.bp',
    EmtBpPath .. 'cannon_muzzle_smoke_10_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_03_emit.bp',
}

APCannonTrail2 = {
    EmtBpPathNomads .. 'nomads_apcannon_trail02_emit.bp', -- whitish effect
}

APCannonPolyTrail2 = EmtBpPath .. 'nomads_apcannon_polytrail02_emit.bp'

APCannonHitNone2 = {
    EmtBpPathNomads .. 'nomads_apcannon_hit_07_emit.bp',  -- small explosion
    EmtBpPathNomads .. 'nomads_apcannon_hit_06_emit.bp',  -- fire
    EmtBpPathNomads .. 'nomads_apcannon_hit_09_emit.bp',  -- color changing fast shockwave
}

APCannonHitLand2 = TableCat( APCannonHitNone2, {
    EmtBpPathNomads .. 'nomads_apcannon_hit_03_emit.bp',  -- shockwave rings
    EmtBpPathNomads .. 'nomads_apcannon_hit_08_emit.bp',  -- glow
})

APCannonHitWater2 = TableCat( APCannonHitNone2, {
    EmtBpPathNomads .. 'nomads_apcannon_hit_03_emit.bp',  -- shockwave rings
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
--  Nomads Dark Matter weapon
--------------------------------------------------------------------------
-- Used by T1 light tank and scout

DarkMatterWeaponMuzzleFlash = {
    EmtBpPath .. 'machinegun_muzzle_fire_01_emit.bp',
    EmtBpPath .. 'machinegun_muzzle_fire_02_emit.bp',
}

DarkMatterWeaponTrail = {}

DarkMatterWeaponPolyTrails = {
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_polytrail_01_emit.bp',
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_polytrail_02_emit.bp',
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_polytrail_03_emit.bp',
}

DarkMatterWeaponHitNone1 = {
--    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_hit_01_emit.bp', -- splashes
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_hit_02_emit.bp', -- 'explosions'
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

DarkMatterWeaponBeam2 = EmtBpPathNomads .. 'nomads_DarkMatterWeapon_beam02_emit.bp'

DarkMatterWeaponHitNone2 = {
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_hit_01_emit.bp', -- splashes
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_hit_02_emit.bp', -- black 'explosions'
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_hit_03_emit.bp',
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

-- T1 inty weapon

DarkMatterAirWeaponMuzzleFlash = {
	EmtBpPath .. 'nomads_DarkMatterWeapon_muzzle_flash_01_emit_air.bp',
	EmtBpPath .. 'nomads_DarkMatterWeapon_muzzle_flash_02_emit_air.bp',
	EmtBpPath .. 'nomads_DarkMatterWeapon_muzzle_flash_03_emit_air.bp',
}

DarkMatterAirWeaponTrail = {}

DarkMatterAirWeaponPolyTrails = {
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_polytrail_01_emit_air.bp',
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_polytrail_02_emit_air.bp',
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_polytrail_03_emit_air.bp',
}

DarkMatterAirWeaponHitNone1 = {
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_hit_01_emit_air.bp', -- splashes
    EmtBpPathNomads .. 'nomads_DarkMatterWeapon_hit_02_emit_air.bp', -- explosions
	EmtBpPathNomads .. 'nomads_DarkMatterWeapon_hit_03_emit_air.bp', -- idk
}

DarkMatterAirWeaponHitLand1 = TableCat( DarkMatterAirWeaponHitNone1, {
})

DarkMatterAirWeaponHitUnit1 = TableCat( DarkMatterAirWeaponHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

DarkMatterAirWeaponHitAirUnit1 = DarkMatterAirWeaponHitNone1
DarkMatterAirWeaponHitShield1 = DarkMatterAirWeaponHitNone1
DarkMatterAirWeaponHitProjectile1 = DarkMatterAirWeaponHitUnit1
DarkMatterAirWeaponHitProp1 = DarkMatterAirWeaponHitUnit1
DarkMatterAirWeaponHitWater1 = DarkMatterAirWeaponHitLand1
DarkMatterAirWeaponHitUnderWater1 = DarkMatterAirWeaponHitNone1

--------------------------------------------------------------------------
--  Nomads Ion blast
--------------------------------------------------------------------------
-- Used on AA guns

IonBlastMuzzleFlash = {
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

IonBlastTrail = {
    EmtBpPathNomads .. 'nomads_ionblast_trail_01_emit.bp',
}

IonBlastPolyTrail = EmtBpPathNomads .. 'nomads_ionblast_polytrail_01_emit.bp'

IonBlastHitNone1 = {
    EmtBpPathNomads .. 'nomads_ionblast_hit_01_emit.bp',  -- red/purple dot
    EmtBpPathNomads .. 'nomads_ionblast_hit_02_emit.bp',  -- discharge blue
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

IonBlastHitLand1 = TableCat( IonBlastHitNone1, {
    EmtBpPathNomads .. 'nomads_ionblast_hit_03_emit.bp',  -- small red disk
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
--  Nomads Particle blast
--------------------------------------------------------------------------
-- Used on T1 tank

ParticleBlastMuzzleFlash = {
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

ParticleBlastTrail = {
    EmtBpPathNomads .. 'nomads_particleblast_trail_01_emit.bp',
    EmtBpPathNomads .. 'nomads_particleblast_trail_02_emit.bp',
}

ParticleBlastPolyTrail = EmtBpPathNomads .. 'nomads_particleblast_polytrail_01_emit.bp'

ParticleBlastHitNone1 = {
    EmtBpPathNomads .. 'nomads_particleblast_hit_02_emit.bp',  -- discharge effect
    EmtBpPathNomads .. 'nomads_particleblast_hit_04_emit.bp',  -- discharge purple
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

ParticleBlastHitLand1 = TableCat( ParticleBlastHitNone1, {
    EmtBpPathNomads .. 'nomads_particleblast_hit_01_emit.bp',  -- stripes on the ground that slowly expand
--    EmtBpPathNomads .. 'nomads_particleblast_hit_03_emit.bp',  -- rings
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
    EmtBpPath .. 'nomads_gattling_polytrail_01_emit.bp',
    EmtBpPath .. 'nomads_gattling_polytrail_02_emit.bp',
}

GattlingHitNone2 = {
    EmtBpPathNomads .. 'nomads_gattling_hit_01_emit.bp',
    EmtBpPathNomads .. 'nomads_gattling_hit_02_emit.bp',
    EmtBpPathNomads .. 'nomads_gattling_hit_03_emit.bp',
    EmtBpPathNomads .. 'nomads_gattling_hit_04_emit.bp',
    EmtBpPathNomads .. 'nomads_gattling_hit_05_emit.bp',
    EmtBpPathNomads .. 'nomads_gattling_hit_06_emit.bp',
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
--  Nomads Annihilator weapon
--------------------------------------------------------------------------

AnnihilatorMuzzleFlash = {
--    EmtBpPath .. 'cannon_artillery_muzzle_flash_01_emit.bp',
--    EmtBpPath .. 'cannon_muzzle_smoke_07_emit.bp',
--    EmtBpPath .. 'cannon_muzzle_smoke_10_emit.bp',
--    EmtBpPath .. 'cannon_muzzle_flash_03_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

AnnihilatorTrail = {
    EmtBpPathNomads .. 'nomads_annihilator_trail_01_emit.bp',
}

AnnihilatorPolyTrail = EmtBpPath .. 'nomads_annihilator_polytrail01_emit.bp'

AnnihilatorHitNone1 = {
    EmtBpPathNomads .. 'nomads_annihilator_hit_11_emit.bp',  -- circular effect
    EmtBpPathNomads .. 'nomads_annihilator_hit_12_emit.bp',  -- star effect
--    EmtBpPathNomads .. 'nomads_annihilator_hit_13_emit.bp',  -- glow effect
    EmtBpPathNomads .. 'nomads_annihilator_hit_04_emit.bp',  -- flash
}

AnnihilatorHitLand1 = TableCat( AnnihilatorHitNone1, {
    EmtBpPathNomads .. 'nomads_annihilator_hit_01_emit.bp',  -- flat circular effect
    EmtBpPathNomads .. 'nomads_annihilator_hit_02_emit.bp',  -- flat star effect
--    EmtBpPathNomads .. 'nomads_annihilator_hit_03_emit.bp',  -- flat glow effect
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
--  Nomads Particle blast Artillery
--------------------------------------------------------------------------

ParticleBlastArtilleryMuzzleFx = {
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

ParticleBlastArtilleryTrail = {
    EmtBpPathNomads .. 'nomads_particleblast_trail_01_emit.bp',
    EmtBpPathNomads .. 'nomads_particleblast_trail_02_emit.bp',
}

ParticleBlastArtilleryPolyTrail = EmtBpPathNomads .. 'nomads_particleblast_large_polytrail_01_emit.bp'

ParticleBlastArtilleryHitNone1 = {
    EmtBpPathNomads .. 'nomads_particleblast_large_hit02_emit.bp',  -- discharge effect
    EmtBpPathNomads .. 'nomads_particleblast_large_hit04_emit.bp',  -- discharge purple
    EmtBpPathNomads .. 'nomads_particleblast_large_hit05_emit.bp',  -- circular expanding effect
    EmtBpPathNomads .. 'nomads_particleblast_large_hit07_emit.bp',  -- sparks
    EmtBpPathNomads .. 'nomads_particleblast_large_hit08_emit.bp',  -- flash
--    EmtBpPath .. 'antimatter_hit_14_emit.bp',  -- dark clouds short duration
}

ParticleBlastArtilleryHitLand1 = TableCat( ParticleBlastArtilleryHitNone1, {
    EmtBpPathNomads .. 'nomads_particleblast_large_hit01_emit.bp',  -- stripes on the ground that slowly expand
--    EmtBpPathNomads .. 'nomads_particleblast_large_hit03_emit.bp',  -- rings
    EmtBpPathNomads .. 'nomads_particleblast_large_hit06_emit.bp',  -- flash flat
    EmtBpPath .. 'destruction_explosion_debris_04_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_01_emit.bp',
    EmtBpPath .. 'dust_cloud_04_emit.bp',
})

ParticleBlastArtilleryHitWater1 = TableCat( ParticleBlastArtilleryHitNone1, {
    EmtBpPathNomads .. 'nomads_particleblast_large_hit01_emit.bp',  -- stripes on the ground that slowly expand
--    EmtBpPathNomads .. 'nomads_particleblast_large_hit03_emit.bp',  -- rings
    EmtBpPathNomads .. 'nomads_particleblast_large_hit06_emit.bp',  -- flash flat
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
})

ParticleBlastArtilleryHitUnit1 = {
    EmtBpPathNomads .. 'nomads_particleblast_large_hit01_emit.bp',  -- stripes on the ground that slowly expand
--    EmtBpPathNomads .. 'nomads_particleblast_large_hit03_emit.bp',  -- rings
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
}

ParticleBlastArtilleryHitAirUnit1 = ParticleBlastArtilleryHitUnit1
ParticleBlastArtilleryHitShield1 = ParticleBlastArtilleryHitNone1
ParticleBlastArtilleryHitProjectile1 = ParticleBlastArtilleryHitNone1
ParticleBlastArtilleryHitProp1 = ParticleBlastArtilleryHitLand1
ParticleBlastArtilleryHitUnderWater1 = ParticleBlastArtilleryHitNone1

--------------------------------------------------------------------------
--  Nomads Artillery
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
    EmtBpPathNomads .. 'nomads_artillery_hit01_emit.bp',  -- black hole effect (vortex)
    EmtBpPathNomads .. 'nomads_artillery_hit02_emit.bp',  -- white thick lightning in center
    EmtBpPathNomads .. 'nomads_artillery_hit03_emit.bp',  -- black stripes moving inwards
    EmtBpPathNomads .. 'nomads_artillery_hit04_emit.bp',  -- refraction stripes inwards
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
--  Nomads Railgun
--------------------------------------------------------------------------

RailgunMuzzleFx = {
    EmtBpPath .. 'flash_01_emit.bp',
    EmtBpPathNomads .. 'nomads_railgun_muzzle01_emit.bp',
}

RailgunBeam = ''
RailgunPolyTrail = EmtBpPath .. 'nomads_railgun_polytrail01_emit.bp'  -- white line
RailgunTrail = {
    EmtBpPathNomads .. 'nomads_railgun_trail01_emit.bp',  -- bolt
    EmtBpPathNomads .. 'nomads_railgun_trail02_emit.bp',  -- longer bolt
    EmtBpPathNomads .. 'nomads_railgun_trail03_emit.bp',  -- slight distortion effect
}

RailgunHitNone1 = {
--    EmtBpPathNomads .. 'nomads_railgun_hit01_emit.bp',  -- quick star effect
    EmtBpPathNomads .. 'nomads_railgun_hit02_emit.bp',  -- small circular effect
    EmtBpPathNomads .. 'nomads_railgun_hit03_emit.bp',  -- sparks
    EmtBpPathNomads .. 'nomads_railgun_hit04_emit.bp',  -- circular effect
    EmtBpPathNomads .. 'nomads_railgun_hit05_emit.bp',  -- flash
--    EmtBpPathNomads .. 'nomads_railgun_hit06_emit.bp',  -- logn lasting electric effect
--    EmtBpPathNomads .. 'nomads_railgun_hit07_emit.bp',  -- circular electric effect
}

RailgunHitLand1 = TableCat( RailgunHitNone1, {
    EmtBpPathNomads .. 'nomads_railgun_hit08_emit.bp',  -- small shockwave
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

RailgunHitWater1 = TableCat( RailgunHitNone1, {
    EmtBpPathNomads .. 'nomads_railgun_hit08_emit.bp',  -- small shockwave
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
})

RailgunHitUnit1 = TableCat( RailgunHitNone1, {
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

RailgunHitUnderWater1 = {
    EmtBpPathNomads .. 'nomads_railgun_hit02_emit.bp',  -- small circular effect
    EmtBpPathNomads .. 'nomads_railgun_hit04_emit.bp',  -- circular effect
    EmtBpPathNomads .. 'nomads_railgun_hit05_emit.bp',  -- flash
}

RailgunHitAirUnit1 = RailgunHitUnit1
RailgunHitShield1 = RailgunHitNone1
RailgunHitProjectile1 = RailgunHitUnit1
RailgunHitProp1 = RailgunHitUnit1

--------------------------------------------------------------------------
--  Nomads Under water Railgun
--------------------------------------------------------------------------

UnderWaterRailgunMuzzleFx = {
    EmtBpPathNomads .. 'nomads_underwaterrailgun_muzzle01_emit.bp',
    EmtBpPathNomads .. 'nomads_railgun_muzzle02_emit.bp',
}

UnderWaterRailgunBeam = ''
UnderWaterRailgunPolyTrail = EmtBpPath .. 'nomads_railgun_polytrail01_emit.bp'  -- white line
UnderWaterRailgunTrail = {
    EmtBpPathNomads .. 'nomads_railgun_trail01_emit.bp',  -- bolt
    EmtBpPathNomads .. 'nomads_railgun_trail02_emit.bp',  -- longer bolt
    EmtBpPathNomads .. 'nomads_railgun_trail03_emit.bp',  -- slight distortion effect
--    EmtBpPath .. 'torpedo_underwater_wake_01_emit.bp',
--    EmtBpPath .. 'torpedo_underwater_wake_02_emit.bp',
--    EmtBpPath .. 'destruction_underwater_sinking_wash_01_emit.bp',
}

UnderWaterRailgunHitNone1 = {
    EmtBpPathNomads .. 'nomads_railgun_hit02_emit.bp',  -- small circular effect
    EmtBpPathNomads .. 'nomads_railgun_hit04_emit.bp',  -- circular effect
    EmtBpPathNomads .. 'nomads_railgun_hit05_emit.bp',  -- flash
}

UnderWaterRailgunHitLand1 = TableCat( UnderWaterRailgunHitNone1, {
    EmtBpPathNomads .. 'nomads_railgun_hit08_emit.bp',  -- small shockwave
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

UnderWaterRailgunHitWater1 = TableCat( UnderWaterRailgunHitNone1, {
    EmtBpPathNomads .. 'nomads_railgun_hit08_emit.bp',  -- small shockwave
    EmtBpPath .. 'destruction_water_splash_ripples_01_emit.bp',
})

UnderWaterRailgunHitUnit1 = TableCat( UnderWaterRailgunHitNone1, {
    EmtBpPathNomads .. 'nomads_railgun_hit03_emit.bp',  -- sparks
})

UnderWaterRailgunHitAirUnit1 = UnderWaterRailgunHitNone1
UnderWaterRailgunHitShield1 = UnderWaterRailgunHitNone1
UnderWaterRailgunHitProjectile1 = UnderWaterRailgunHitNone1
UnderWaterRailgunHitProp1 = UnderWaterRailgunHitUnit1
UnderWaterRailgunHitUnderWater1 = UnderWaterRailgunHitNone1

--------------------------------------------------------------------------
--  Nomads Depth Charge
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
    EmtBpPathNomads .. 'water_surface_ripple.bp',
}

DepthChargeBombHitNone1 = {
    EmtBpPathNomads .. 'nomads_depthchargebomb_01_emit.bp',  -- small flash
    EmtBpPathNomads .. 'nomads_depthchargebomb_03_emit.bp',  -- star effect
}

DepthChargeBombHitLand1 = TableCat( DepthChargeBombHitNone1, {
    EmtBpPathNomads .. 'nomads_depthchargebomb_02_emit.bp',  -- flat star effect
    EmtBpPathNomads .. 'nomads_depthchargebomb_04_emit.bp',  -- shockwave (refraction)
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
    EmtBpPathNomads .. 'nomads_depthchargebomb_02_emit.bp',  -- flat star effect
    EmtBpPathNomads .. 'nomads_depthchargebomb_04_emit.bp',  -- shockwave (refraction)
})

DepthChargeBombHitAirUnit1 = TableCat( DepthChargeBombHitNone1, {
    EmtBpPathNomads .. 'nomads_depthchargebomb_04_emit.bp',  -- shockwave (refraction)
})

DepthChargeBombHitShield1 = DepthChargeBombHitNone1
DepthChargeBombHitProjectile1 = DepthChargeBombHitNone1
DepthChargeBombHitProp1 = DepthChargeBombHitUnit1

DepthChargeBombDeepWaterExplosion = TableCat( DepthChargeBombHitNone1, {
})

--------------------------------------------------------------------------
--  Nomads EMP gun
--------------------------------------------------------------------------
-- used by T2 emp tank and T2 cruiser

EMPGunMuzzleFlash = {
--    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
    EmtBpPathNomads .. 'nomads_EMP_gun_muzzle_flash_03_emit.bp',
}

EMPGunMuzzleFlash_Tank = {
--    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
    EmtBpPathNomads .. 'nomads_EMP_gun_muzzle_flash_01_emit.bp',
    EmtBpPathNomads .. 'nomads_EMP_gun_muzzle_flash_02_emit.bp',
}

EMPGunTrail = {
    EmtBpPathNomads .. 'nomads_EMP_gun_trail_01_emit.bp', -- green haze
    EmtBpPathNomads .. 'nomads_EMP_gun_trail_02_emit.bp', -- bolt
    EmtBpPathNomads .. 'nomads_EMP_gun_trail_03_emit.bp', -- electricity
    EmtBpPathNomads .. 'nomads_EMP_gun_trail_04_emit.bp', -- bolt
}

EMPGunPolyTrail = EmtBpPathNomads .. 'nomads_EMP_gun_polytrail_03_emit.bp'

EMPGunElectricityEffect = {
    EmtBpPathNomads .. 'nomads_EMP_gun_hit_03_emit.bp',
    EmtBpPathNomads .. 'nomads_EMP_gun_hit_04_emit.bp',
}
EMPGunElectricityEffectDurationMulti = 2.5

EMPGunHitNone1 = {
    EmtBpPathNomads .. 'nomads_EMP_gun_hit_01_emit.bp',
    EmtBpPathNomads .. 'nomads_EMP_gun_hit_02_emit.bp',
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
-- Nomads Stingray Emitters
-------------------------------------------------------------------------------------------

StingrayMuzzleFx = {
    EmtBpPathNomads .. 'nomads_stingray_muzzle01_emit.bp',  -- orange effect following projectile
    EmtBpPathNomads .. 'nomads_stingray_muzzle02_emit.bp',  -- flash effect stars
    EmtBpPathNomads .. 'nomads_stingray_muzzle03_emit.bp',  -- flash effect
}

StingrayTrail= {
    EmtBpPathNomads .. 'nomads_stingray_trail01_emit.bp',  -- still rings
}
StingrayPolyTrails = {
    EmtBpPathNomads .. 'nomads_stingray_polytrail01_emit.bp',  -- yellow trail short
    EmtBpPathNomads .. 'nomads_stingray_polytrail02_emit.bp',  -- yellow trail long
}

StingrayHitNone1 = {
    EmtBpPathNomads .. 'nomads_stingray_hit01_emit.bp',  -- basic explosive effect
    EmtBpPathNomads .. 'nomads_stingray_hit03_emit.bp',  -- "long" flames effect
    EmtBpPathNomads .. 'nomads_stingray_hit04_emit.bp',  -- short flames effect
}

StingrayHitLand1 = TableCat(StingrayHitNone1, {
    EmtBpPathNomads .. 'nomads_stingray_hit02_emit.bp',  -- expanding ring at ground
})

StingrayHitWater1 = TableCat(StingrayHitNone1, {
    EmtBpPathNomads .. 'nomads_stingray_hit02_emit.bp',  -- expanding ring at ground
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
    EmtBpPathNomads .. 'nomads_aamflare_trail01_emit.bp', -- stars
    EmtBpPathNomads .. 'nomads_aamflare_trail02_emit.bp', -- stars
    EmtBpPathNomads .. 'nomads_aamflare_trail03_emit.bp', -- trails
    EmtBpPathNomads .. 'nomads_navallight01_emit.bp',  -- constant green light
}

FlarePolyTrail =  EmtBpPath .. 'default_polytrail_01_emit.bp'

FlareHitNone1 = {  -- default impact effect, if impacting with ground or a unit. No damage is dealt, no big FX needed
    EmtBpPathNomads .. 'nomads_aamflare_impact01_emit.bp',
}

FlareHitLand1 = TableCat(FlareHitNone1, {
})

FlareHitWater1 = TableCat(FlareHitNone1, {
})

FlareHitProjectile1 = TableCat(FlareHitNone1, { 
-- TODO: the flare impacts with a missile projectile. Should be a little bigger eplosion
    EmtBpPathNomads .. 'nomads_aamflare_impact01_emit.bp',
})

FlareHitUnit1 = FlareHitProjectile1
FlareHitAirUnit1 = FlareHitNone1
FlareHitShield1 = FlareHitNone1
FlareHitProp1 = FlareHitProjectile1
FlareHitUnderWater1 = FlareHitNone1

--------------------------------------------------------------------------
--  Nomads Small Missile (guided)
--------------------------------------------------------------------------
-- Used by a lot of units

MissileMuzzleFx = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
}

MissileMuzzleFx2 = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp', -- smoke out back
}

MissileBeam = EmtBpPathNomads .. 'nomads_missilebeam01_emit.bp'
MissileTrail = {}
MissilePolyTrail = EmtBpPath .. 'nomads_missile_polytrail_01_emit.bp'

MissileHitNone1 = {
    EmtBpPathNomads .. 'nomads_missile_hit_01_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_missile_hit_02_emit.bp',  -- yellow core
    EmtBpPathNomads .. 'nomads_missile_hit_03_emit.bp',  -- orange ring
}

MissileHitLand1 = TableCat( MissileHitNone1, {
    EmtBpPathNomads .. 'nomads_missile_hit_11_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_missile_hit_12_emit.bp',  -- yellow core
    EmtBpPathNomads .. 'nomads_missile_hit_13_emit.bp',  -- orange ring
    EmtBpPathNomads .. 'nomads_missile_hit_14_emit.bp',  -- shockwave ring
})

MissileHitWater1 = TableCat( MissileHitNone1, {
    EmtBpPathNomads .. 'nomads_missile_hit_14_emit.bp',  -- shockwave ring
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
    EmtBpPathNomads .. 'nomads_missile_hit_07_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_missile_hit_02_emit.bp',  -- yellow core
    EmtBpPathNomads .. 'nomads_missile_hit_03_emit.bp',  -- orange ring
    EmtBpPathNomads .. 'nomads_missile_hit_05_emit.bp',  -- orange star/flare
    EmtBpPathNomads .. 'nomads_missile_hit_06_emit.bp',  -- sparks
}

MissileHitLand2 = TableCat( MissileHitNone2, {
    EmtBpPathNomads .. 'nomads_missile_hit_17_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_missile_hit_12_emit.bp',  -- yellow core
    EmtBpPathNomads .. 'nomads_missile_hit_13_emit.bp',  -- orange ring
    EmtBpPathNomads .. 'nomads_missile_hit_14_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

MissileHitWater2 = TableCat( MissileHitNone2, {
    EmtBpPathNomads .. 'nomads_missile_hit_14_emit.bp',  -- shockwave ring
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

MissileBeam = EmtBpPathNomads .. 'nomads_missilebeam01_emit.bp'
MissileTrail = {}
MissilePolyTrail = EmtBpPath .. 'nomads_missile_polytrail_01_emit.bp'

--------------------------------------------------------------------------
--  Nomads Small rocket (unguided)
--------------------------------------------------------------------------
-- Used by a lot of units

RocketMuzzleFx = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
}

RocketMuzzleFx2 = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp', -- smoke out back
}

RocketBeam = EmtBpPathNomads .. 'nomads_rocket_beam01_emit.bp'
RocketTrail = {
    EmtBpPathNomads .. 'nomads_rocket_trail01_emit.bp',
}
RocketPolyTrail = EmtBpPath .. 'nomads_rocket_polytrail_01_emit.bp'

RocketHitNone1 = {
    EmtBpPathNomads .. 'nomads_rocket_hit_01_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_rocket_hit_02_emit.bp',  -- orange electricity
    EmtBpPathNomads .. 'nomads_rocket_hit_03_emit.bp',  -- black electricity
}

RocketHitLand1 = TableCat( RocketHitNone1, {
    EmtBpPathNomads .. 'nomads_rocket_hit_05_emit.bp',  -- dark smoke
    EmtBpPathNomads .. 'nomads_rocket_hit_04_emit.bp',  -- shockwave ring
})

RocketHitWater1 = TableCat( RocketHitNone1, {
    EmtBpPathNomads .. 'nomads_rocket_hit_05_emit.bp',  -- dark smoke
    EmtBpPathNomads .. 'nomads_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
})

RocketHitUnit1 = TableCat( RocketHitNone1, {
    EmtBpPathNomads .. 'nomads_rocket_hit_05_emit.bp',  -- dark smoke
})

RocketHitAirUnit1 = TableCat( RocketHitNone1, {
})

RocketHitShield1 = RocketHitNone1
RocketHitProjectile1 = RocketHitNone1
RocketHitProp1 = RocketHitUnit1
RocketHitUnderWater1 = RocketHitUnit1

-- longer lasting effect and shaky trail
RocketHitNone2 = {
    EmtBpPathNomads .. 'nomads_rocket_hit_01_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_rocket_hit_12_emit.bp',  -- white->red electricity
    EmtBpPathNomads .. 'nomads_rocket_hit_13_emit.bp',  -- black electricity
}

RocketHitLand2 = TableCat( RocketHitNone2, {
    EmtBpPathNomads .. 'nomads_rocket_hit_15_emit.bp',  -- dark smoke
    EmtBpPathNomads .. 'nomads_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

RocketHitWater2 = TableCat( RocketHitNone2, {
    EmtBpPathNomads .. 'nomads_rocket_hit_15_emit.bp',  -- dark smoke
    EmtBpPathNomads .. 'nomads_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
    EmtBpPath .. 'water_splash_plume_01_emit.bp',
})

RocketHitUnit2 = TableCat( RocketHitNone2, {
    EmtBpPathNomads .. 'nomads_rocket_hit_15_emit.bp',  -- dark smoke
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

RocketHitAirUnit2 = TableCat( RocketHitNone2, {
})

RocketHitShield2 = RocketHitNone2
RocketHitProjectile2 = RocketHitNone2
RocketHitProp2 = RocketHitUnit2
RocketHitUnderWater2 = RocketHitNone2

RocketBeam2 = EmtBpPathNomads .. 'nomads_rocket_beam01_emit.bp'
RocketTrail2 = {
    EmtBpPathNomads .. 'nomads_rocket_trail01_emit.bp',
}
RocketPolyTrail2 = EmtBpPath .. 'nomads_rocket_polytrail_02_emit.bp'


RocketMuzzleFx2 = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
}

RocketMuzzleFx2 = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',  -- smoke on front
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp', -- smoke out back
}

-- Slightly different visuals

RocketBeam3 = EmtBpPathNomads .. 'nomads_rocket_beam03_emit.bp'
RocketTrail3 = {
    EmtBpPathNomads .. 'nomads_rocket_trail03_emit.bp',
}
RocketPolyTrail3 = EmtBpPath .. 'nomads_rocket_polytrail_03_emit.bp'

RocketHitNone3 = {
    EmtBpPathNomads .. 'nomads_rocket_hit_08_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_rocket_hit_09_emit.bp',  -- star effect on ground
}

RocketHitLand3 = TableCat( RocketHitNone3, {
    EmtBpPathNomads .. 'nomads_rocket_hit_05_emit.bp',  -- dark smoke
    EmtBpPathNomads .. 'nomads_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
})

RocketHitWater3 = TableCat( RocketHitNone3, {
    EmtBpPathNomads .. 'nomads_rocket_hit_05_emit.bp',  -- dark smoke
    EmtBpPathNomads .. 'nomads_rocket_hit_04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'water_splash_ripples_ring_01_emit.bp',
})

RocketHitUnit3 = TableCat( RocketHitNone3, {
    EmtBpPathNomads .. 'nomads_rocket_hit_05_emit.bp',  -- dark smoke
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

RocketBeam4 = EmtBpPathNomads .. 'nomads_rocket_beam04_emit.bp'
RocketTrail4 = {
    EmtBpPathNomads .. 'nomads_rocket_trail04_emit.bp',
}
RocketPolyTrail4 = EmtBpPath .. 'nomads_rocket_polytrail_04_emit.bp'

RocketHitNone4 = {
    EmtBpPathNomads .. 'nomads_rocket_hit_20_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_rocket_hit_23_emit.bp',  -- blue smoke effect
    EmtBpPathNomads .. 'nomads_rocket_hit_24_emit.bp',  -- blue star effect
}

RocketHitLand4 = {
    EmtBpPathNomads .. 'nomads_rocket_hit_20_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_rocket_hit_21_emit.bp',  -- blue smoke effect slightly above impact
    EmtBpPathNomads .. 'nomads_rocket_hit_22_emit.bp',  -- blue star effect slightly above impact
    EmtBpPathNomads .. 'nomads_rocket_hit_04_emit.bp',  -- shockwave ring
}

RocketHitWater4 = {
    EmtBpPathNomads .. 'nomads_rocket_hit_20_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_rocket_hit_21_emit.bp',  -- blue smoke effect slightly above impact
    EmtBpPathNomads .. 'nomads_rocket_hit_22_emit.bp',  -- blue star effect slightly above impact
    EmtBpPathNomads .. 'nomads_rocket_hit_04_emit.bp',  -- shockwave ring
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
RocketBeam5 = EmtBpPathNomads .. 'nomads_rocket_beam05_emit.bp'
RocketTrail5 = {
    EmtBpPathNomads .. 'nomads_rocket_trail05_emit.bp',
}
RocketPolyTrail5 = EmtBpPath .. 'nomads_rocket_polytrail_05_emit.bp'

RocketHitNone5 = {
    EmtBpPathNomads .. 'nomads_rocket_hit_26_emit.bp',  -- flash
}

RocketHitLand5 = TableCat( RocketHitNone5, {
    EmtBpPathNomads .. 'nomads_rocket_hit_27_emit.bp',  -- very short blue smoke effect (flat)
    EmtBpPathNomads .. 'nomads_rocket_hit_06_emit.bp',  -- shockwave ring
})

RocketHitWater5 = TableCat( RocketHitNone5, {
    EmtBpPathNomads .. 'nomads_rocket_hit_27_emit.bp',  -- very short blue smoke effect (flat)
    EmtBpPathNomads .. 'nomads_rocket_hit_06_emit.bp',  -- shockwave ring
})

RocketHitUnit5 = TableCat( RocketHitNone5, {
    EmtBpPathNomads .. 'nomads_rocket_hit_25_emit.bp',  -- very short blue smoke effect
})

RocketHitAirUnit5 = TableCat( RocketHitNone5, {
    EmtBpPathNomads .. 'nomads_rocket_hit_25_emit.bp',  -- very short blue smoke effect
})

RocketHitShield5 = RocketHitNone5
RocketHitProjectile5 = RocketHitNone5
RocketHitProp5 = RocketHitUnit5
RocketHitUnderWater5 = RocketHitUnit5

--------------------------------------------------------------------------
--  NOMADS FUSION MISSILE EMITTERS
--------------------------------------------------------------------------
FusionMissileMuzzleFx = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp',
}

FusionMissile_DroppedActivation = {
    EmtBpPathNomads .. 'nomads_fusionmissile_dropped_activation01_emit.bp',
}

FusionMissileBeam = ''
FusionMissilePolyTrail = ''
FusionMissileTrail = {
    EmtBpPathNomads .. 'nomads_fusionmissile_trail01_emit.bp',
    EmtBpPathNomads .. 'nomads_fusionmissile_trail02_emit.bp',
}

FusionMissileHitNone1 = {
    EmtBpPathNomads .. 'nomads_fusionmissile_hit01_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_fusionmissile_hit02_emit.bp',  -- fire effect
    EmtBpPathNomads .. 'nomads_fusionmissile_hit03_emit.bp',  -- brown smoke
}

FusionMissileHitLand1 = TableCat( FusionMissileHitNone1, {
    EmtBpPathNomads .. 'nomads_fusionmissile_hit04_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_explosion_debris_04_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

FusionMissileHitWater1 = TableCat( FusionMissileHitNone1, {
    EmtBpPathNomads .. 'nomads_fusionmissile_hit04_emit.bp',  -- shockwave ring
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
--  NOMADS EMP MISSILE EMITTERS
--------------------------------------------------------------------------
EMPMissileMuzzleFx = {
    EmtBpPath .. 'terran_sam_launch_smoke_emit.bp',
    EmtBpPath .. 'terran_sam_launch_smoke2_emit.bp',
}

EMPMissileBeam = ''
EMPMissilePolyTrail = ''
EMPMissileTrail = {
    EmtBpPathNomads .. 'nomads_empmissile_trail01_emit.bp',
    EmtBpPathNomads .. 'nomads_empmissile_trail02_emit.bp',
    EmtBpPathNomads .. 'nomads_empmissile_trail03_emit.bp',
}

EMPMissileHitNone1 = {
    EmtBpPathNomads .. 'nomads_empmissile_hit05_emit.bp',  
	EmtBpPathNomads .. 'nomads_empmissile_hit07_emit.bp',  
    -- EmtBpPath .. 'destruction_explosion_debris_04_emit.bp',
    -- EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
}

EMPMissileElectricityEffect = {
    EmtBpPathNomads .. 'nomads_empmissile_hit03_emit.bp', 
    EmtBpPathNomads .. 'nomads_empmissile_hit04_emit.bp',  
}
EMPMissileElectricityEffectDurationMulti = 0.5

EMPMissileHitLand1 = TableCat( EMPMissileHitNone1, {
})

EMPMissileHitWater1 = TableCat( EMPMissileHitNone1, {
    EmtBpPathNomads .. 'nomads_empmissile_hit05_emit.bp',  -- shockwave ring
})

EMPMissileHitUnit1 = TableCat( EMPMissileHitNone1, {
    EmtBpPathNomads .. 'nomads_empmissile_hit05_emit.bp',  -- shockwave ring
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

EMPMissileHitAirUnit1 = EMPMissileHitUnit1
EMPMissileHitShield1 = EMPMissileHitNone1
EMPMissileHitProjectile1 = EMPMissileHitNone1
EMPMissileHitProp1 = EMPMissileHitUnit1
EMPMissileHitUnderWater1 = EMPMissileHitUnit1

--------------------------------------------------------------------------
--  Nomads Tactical Missiles
--------------------------------------------------------------------------
-- Used by the TML and Crawler

TacticalMissileMuzzleFx = {
    EmtBpPathNomads .. 'nomads_tacticalmissilelaunch01_emit.bp',
    EmtBpPathNomads .. 'nomads_tacticalmissilelaunch02_emit.bp',
    EmtBpPathNomads .. 'nomads_tacticalmissilelaunch03_emit.bp',
}

TacticalMissileMuzzleFxUnderWaterAddon = { 
    -- only use if unit is under water sufficiently, like 3 - 4 units under water, or you'll see air bubbles above the water
    EmtBpPath .. 'terran_cruise_missile_sublaunch_01_emit.bp',
}

TacticalMissileBeam = EmtBpPath .. 'nomads_missilebeam01_emit.bp'
TacticalMissilePolyTrail = EmtBpPath .. 'nomads_missile_polytrail_01_emit.bp'
TacticalMissileTrail = {
	EmtBpPathNomads .. 'nomads_small_lense_flare_emit.bp',
    EmtBpPathNomads .. 'nomads_tacticalmissile_trail01_emit.bp',
}
TacticalMissileTrailFxUnderWaterAddon = {
    -- Adds bubbles to the previous entry. Only use if unit is under water, remove this trail when exiting water
    EmtBpPath .. 'destruction_underwater_sinking_wash_01_emit.bp',
}

TacticalMissileHitNone1 = {
	EmtBpPathNomads .. 'smoke_black_small.bp',  -- smoke
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit01_emit.bp',  -- orange flames
	EmtBpPathNomads .. 'nomads_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit03_emit.bp',  -- red lightning
}

TacticalMissileHitLand1 = TableCat( TacticalMissileHitNone1, {
    -- EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    -- EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

TacticalMissileHitWater1 = TableCat( TacticalMissileHitNone1, {
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit02_emit.bp',  -- shockwave
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
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit01_emit.bp',  -- orange flames
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit03_emit.bp',  -- red lightning
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit04_emit.bp',  -- red flash
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit05_emit.bp',  -- brown smoke
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit06_emit.bp',  -- residual flame cloud
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit14_emit.bp',  -- ground sparks
}

TacticalMissileHitLand2 = TableCat( TacticalMissileHitNone2, {
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
    EmtBpPath .. 'dust_cloud_04_emit.bp',
})

TacticalMissileHitWater2 = TableCat( TacticalMissileHitNone2, {
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit02_emit.bp',  -- shockwave
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
--  Nomads Artillery rockets
--------------------------------------------------------------------------
-- Used by T2 MML and T3 rocket artillery

ArcingTacticalMissileBeam = TacticalMissileBeam
ArcingTacticalMissileTrail = TacticalMissileTrail
ArcingTacticalMissilePolyTrail = TacticalMissilePolyTrail

ArcingTacticalMissileHitNone1 = {
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit01_emit.bp',  -- orange flames
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit03_emit.bp',  -- red lightning
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit04_emit.bp',  -- red flash
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit05_emit.bp',  -- brown smoke
}

ArcingTacticalMissileHitLand1 = TableCat( ArcingTacticalMissileHitNone1, {
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

ArcingTacticalMissileHitWater1 = TableCat( ArcingTacticalMissileHitNone1, {
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit02_emit.bp',  -- shockwave
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
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit10_emit.bp',  -- yellow sparks fountain
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit11_emit.bp',  -- ground ring
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit12_emit.bp',  -- flash
}

ArcingTacticalMissileHitLand2 = TableCat( ArcingTacticalMissileHitNone2, {
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit02_emit.bp',  -- shockwave
    EmtBpPath .. 'destruction_explosion_debris_01_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
    EmtBpPath .. 'dust_cloud_04_emit.bp',
})

ArcingTacticalMissileHitWater2 = TableCat( ArcingTacticalMissileHitNone2, {
    EmtBpPathNomads .. 'nomads_tacticalmissile_hit02_emit.bp',  -- shockwave
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
    EmtBpPathNomads .. 'nomads_tacticalmissile_speedup01_emit.bp',  -- flash
	EmtBpPathNomads .. 'nomads_tacticalmissile_speedup02_emit.bp',  -- lense
	EmtBpPathNomads .. 'smoke_white_small.bp',  -- smoke
	EmtBpPathNomads .. 'split_shockwave.bp',  -- shockwave 
}

--------------------------------------------------------------------------
-- Nomads Torpedoes
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
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_01_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_03_emit.bp',  -- fast explosion
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_05_emit.bp',  -- smoke
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_06_emit.bp',  -- long explosion
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_04_emit.bp',  -- short flames
}

ConventionalBombHitLand1 = TableCat( ConventionalBombHitNone1, {
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_07_emit.bp',  -- shockwave rings
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_08_emit.bp',  -- long shockwave rings
    EmtBpPath .. 'destruction_explosion_debris_06_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

ConventionalBombHitWater1 = TableCat( ConventionalBombHitNone1, {
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_07_emit.bp',  -- shockwave rings
    EmtBpPathNomads .. 'nomads_kineticcannon_hit_08_emit.bp',  -- long shockwave rings
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
    EmtBpPathNomads .. 'nomads_concussionbomb_trail01_emit.bp',  -- the 'bomb'
    EmtBpPathNomads .. 'nomads_concussionbomb_trail02_emit.bp',  -- orange trail
}
ConcussionBombPolyTrail = '/effects/emitters/default_polytrail_01_emit.bp'

ConcussionBombSplit = {
    EmtBpPath .. 'terran_fragmentation_bomb_split_01_emit.bp',
    EmtBpPath .. 'terran_fragmentation_bomb_split_02_emit.bp',
}

ConcussionBombHitNone1 = {
    EmtBpPath .. 'flash_01_emit.bp',
    EmtBpPathNomads .. 'nomads_concussionbomb_hit01_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_concussionbomb_hit02_emit.bp',  -- orange sparks large
    EmtBpPathNomads .. 'nomads_concussionbomb_hit05_emit.bp',  -- circular effect at ground
--    EmtBpPathNomads .. 'nomads_concussionbomb_hit07_emit.bp',  -- refraction ring
}

ConcussionBombHitLand1 = TableCat( ConcussionBombHitNone1, {
    EmtBpPathNomads .. 'nomads_concussionbomb_hit03_emit.bp',  -- orange ring shrinking
--    EmtBpPathNomads .. 'nomads_concussionbomb_hit04_emit.bp',  -- chunks
--    EmtBpPathNomads .. 'nomads_concussionbomb_hit06_emit.bp',  -- flat refraction effect
})

ConcussionBombHitWater1 = TableCat( ConcussionBombHitNone1, {
    EmtBpPathNomads .. 'nomads_concussionbomb_hit03_emit.bp',  -- orange ring shrinking
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
    EmtBpPathNomads .. 'nomads_plasmabolt_muzzle01_emit.bp',
    EmtBpPathNomads .. 'nomads_plasmabolt_muzzle02_emit.bp',
    EmtBpPathNomads .. 'nomads_plasmabolt_muzzle03_emit.bp',
    EmtBpPathNomads .. 'nomads_plasmabolt_muzzle04_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

PlasmaBoltBeam = EmtBpPathNomads .. 'nomads_plasmacannon_beam01.bp'

PlasmaBoltTrail = {
--    EmtBpPathNomads .. 'nomads_plasmabolt_trail01_emit.bp',  -- smaller projectile
    EmtBpPathNomads .. 'nomads_plasmabolt_trail02_emit.bp',  -- smoke
    EmtBpPathNomads .. 'nomads_plasmabolt_trail03_emit.bp',  -- larger projectile
}

PlasmaBoltPolyTrail = EmtBpPath .. 'default_polytrail_04_emit.bp'
--PlasmaBoltPolyTrail = ''

PlasmaBoltHitNone1 = {
    EmtBpPathNomads .. 'nomads_plasmabolt_hit02.bp',  -- flash
    EmtBpPathNomads .. 'nomads_plasmabolt_hit03.bp',  -- fountain
}

PlasmaBoltHitLand1 = TableCat( PlasmaBoltHitNone1, {
    EmtBpPathNomads .. 'nomads_plasmabolt_hit01.bp',  -- shock wave
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

PlasmaBoltHitWater1 = TableCat( PlasmaBoltHitNone1, {
    EmtBpPathNomads .. 'nomads_plasmabolt_hit01.bp',  -- shock wave
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
    EmtBpPathNomads .. 'nomads_plasmabolt_muzzle01_emit_rcktarty.bp',
    EmtBpPathNomads .. 'nomads_plasmabolt_muzzle02_emit_rcktarty.bp',
    EmtBpPathNomads .. 'nomads_plasmabolt_muzzle03_emit_rcktarty.bp',
    EmtBpPathNomads .. 'nomads_plasmabolt_muzzle04_emit_rcktarty.bp',
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

RcktArtyPlasmaBoltBeam = EmtBpPathNomads .. 'nomads_plasmacannon_beam01_rcktarty.bp'

RcktArtyPlasmaBoltTrail = {
--    EmtBpPathNomads .. 'nomads_plasmabolt_trail01_emit.bp',  -- smaller projectile
    EmtBpPathNomads .. 'nomads_plasmabolt_trail02_emit_rcktarty.bp',  -- smoke
    EmtBpPathNomads .. 'nomads_plasmabolt_trail03_emit_rcktarty.bp',  -- larger projectile
}

RcktArtyPlasmaBoltPolyTrail = EmtBpPath .. 'default_polytrail_04_emit.bp'
--PlasmaBoltPolyTrail = ''

RcktArtyPlasmaBoltHitNone1 = {
    -- EmtBpPathNomads .. 'nomads_plasmabolt_hit02_rcktarty.bp',  -- flash
	EmtBpPathNomads .. 'nomads_plasmabolt_hit04_rcktarty.bp',  -- flames
    EmtBpPathNomads .. 'smoke_black_arty.bp',  -- smoke
	EmtBpPathNomads .. 'nomads_plasmabolt_hit03_rcktarty.bp',  -- fountain
	EmtBpPathNomads .. 'nomads_plasmabolt_hit01_rcktarty.bp',  -- shock wave
}

RcktArtyPlasmaBoltHitLand1 = TableCat( RcktArtyPlasmaBoltHitNone1, {
    EmtBpPath .. 'destruction_explosion_debris_07_emit.bp',
})

RcktArtyPlasmaBoltHitWater1 = TableCat( RcktArtyPlasmaBoltHitNone1, {
    EmtBpPathNomads .. 'nomads_plasmabolt_hit01_rcktarty.bp',  -- shock wave
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
--  Nomads Phase-Ray emitters
--------------------------------------------------------------------------
-- Used by beamer

PhaseRayChargeUpFxStart = {
    EmtBpPath .. 'nomads_phaseray_charge01_emit.bp',  -- a series of flashes
}

PhaseRayChargeUpFxPerm = {
    EmtBpPath .. 'nomads_phaseray_charge02_emit.bp',  -- constant flashing
}

PhaseRayBeam = {
    EmtBpPathNomads .. 'nomads_phaseray_beam01_emit.bp',
}

PhaseRayMuzzle = {
    EmtBpPathNomads .. 'nomads_phaseray_muzzle01_emit.bp',  -- sparks
    EmtBpPathNomads .. 'nomads_phaseray_muzzle02_emit.bp',  -- circular effect shrinking
    EmtBpPathNomads .. 'nomads_phaseray_muzzle03_emit.bp',  -- emitter to the right
    EmtBpPathNomads .. 'nomads_phaseray_muzzle04_emit.bp',  -- emitter to the left
    EmtBpPathNomads .. 'nomads_phaseray_muzzle05_emit.bp',  -- glowing stars effect
    EmtBpPathNomads .. 'nomads_phaseray_muzzle06_emit.bp',  -- faint star effect
    EmtBpPathNomads .. 'nomads_phaseray_muzzle07_emit.bp',  -- glow effect
}

PhaseRayBeamEnd = {
    EmtBpPathNomads .. 'nomads_phaseray_hit01_emit.bp',  -- spark flower
    EmtBpPathNomads .. 'nomads_phaseray_hit03_emit.bp',  -- core, 'fire'
    EmtBpPathNomads .. 'nomads_phaseray_hit04_emit.bp',  -- extra fire effects, random
}

PhaseRayFakeBeam = PhaseRayBeam

PhaseRayFakeBeamMuzzle = {
    EmtBpPathNomads .. 'nomads_phaseray_muzzle02_emit.bp',  -- circular effect shrinking
    EmtBpPathNomads .. 'nomads_phaseray_muzzle05_emit.bp',  -- glowing stars effect
    EmtBpPathNomads .. 'nomads_phaseray_muzzle07_emit.bp',  -- glow effect
    EmtBpPathNomads .. 'nomads_phaseray_muzzle08_emit.bp',  -- flash
}

PhaseRayFakeBeamMuzzleBeamingStopped = {
    EmtBpPathNomads .. 'nomads_phaseray_muzzle08_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_phaseray_muzzle09_emit.bp',  -- glow fading away
    EmtBpPathNomads .. 'nomads_phaseray_muzzle10_emit.bp',  -- star glow fading away
}

PhaseRayHitNone1 = {
}

PhaseRayHitLand1 = TableCat( PhaseRayHitNone1, {
    EmtBpPathNomads .. 'nomads_phaseray_hit02_emit.bp',  -- circle effect at ground
    EmtBpPathNomads .. 'nomads_phaseray_hit05_emit.bp',  -- sparks
})

PhaseRayHitWater1 = PhaseRayHitLand1

PhaseRayHitUnit1 = TableCat( PhaseRayHitNone1, {
    EmtBpPathNomads .. 'nomads_phaseray_hit05_emit.bp',  -- sparks
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

PhaseRayHitAirUnit1 = PhaseRayHitUnit1
PhaseRayHitShield1 = PhaseRayHitNone1
PhaseRayHitProjectile1 = PhaseRayHitUnit1
PhaseRayHitProp1 = PhaseRayHitUnit1
PhaseRayHitUnderWater1 = PhaseRayHitUnit1


-- Used by T3 tank
PhaseRayBeamCannon = {
    EmtBpPathNomads .. 'nomads_phaseray_beam02_emit.bp',
}

PhaseRayCannonMuzzle = {
--    EmtBpPathNomads .. 'nomads_phaseray_muzzle01_emit.bp',  -- sparks
    EmtBpPathNomads .. 'nomads_phaseray_muzzle02_emit.bp',  -- circular effect shrinking
    EmtBpPathNomads .. 'nomads_phaseray_muzzle03_emit.bp',  -- emitter to the right
    EmtBpPathNomads .. 'nomads_phaseray_muzzle04_emit.bp',  -- emitter to the left
    EmtBpPathNomads .. 'nomads_phaseray_muzzle05_emit.bp',  -- glowing stars effect
    EmtBpPathNomads .. 'nomads_phaseray_muzzle06_emit.bp',  -- faint star effect
    EmtBpPathNomads .. 'nomads_phaseray_muzzle07_emit.bp',  -- glow effect
}

PhaseRayCannonBeamEnd = {
    EmtBpPathNomads .. 'nomads_phaseray_hit01_emit.bp',  -- spark flower
    EmtBpPathNomads .. 'nomads_phaseray_hit03_emit.bp',  -- core, 'fire'
    EmtBpPathNomads .. 'nomads_phaseray_hit04_emit.bp',  -- extra fire effects, random
}

PhaseRayCannonHitNone1 = {
    EmtBpPathNomads .. 'nomads_phaseray_hit06_emit.bp',  -- flash
}

PhaseRayCannonHitLand1 = TableCat( PhaseRayCannonHitNone1, {
--    EmtBpPathNomads .. 'nomads_phaseray_hit02_emit.bp',  -- circle effect at ground
    EmtBpPathNomads .. 'nomads_phaseray_hit05_emit.bp',  -- sparks
})

PhaseRayCannonHitWater1 = PhaseRayCannonHitLand1

PhaseRayCannonHitUnit1 = TableCat( PhaseRayCannonHitNone1, {
    EmtBpPathNomads .. 'nomads_phaseray_hit05_emit.bp',  -- sparks
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
})

PhaseRayCannonHitAirUnit1 = PhaseRayCannonHitUnit1
PhaseRayCannonHitShield1 = PhaseRayCannonHitNone1
PhaseRayCannonHitProjectile1 = PhaseRayCannonHitUnit1
PhaseRayCannonHitProp1 = PhaseRayCannonHitUnit1
PhaseRayCannonHitUnderWater1 = PhaseRayCannonHitUnit1

--------------------------------------------------------------------------
--  Nomads Energy projectile
--------------------------------------------------------------------------
-- used on T2 destroyer and T2 static artillery and t3 bomber

EnergyProjMuzzleFlash = {
    EmtBpPathNomads .. 'nomads_energyproj_muzzleflash01_emit.bp',
    EmtBpPath .. 'cannon_muzzle_flash_01_emit.bp',
}

EnergyProjTrail = {
    EmtBpPathNomads .. 'nomads_energyproj_trail01_emit.bp',  -- red projectile
    EmtBpPathNomads .. 'nomads_energyproj_trail02_emit.bp',  -- star effect
}
EnergyProjPolyTrail = EmtBpPathNomads .. 'nomads_energyproj_polytrail02_emit.bp'  -- white long line

EnergyProjHitNone1 = {
    EmtBpPathNomads .. 'nomads_energyproj_hit02_emit.bp',  -- short star effect large
    EmtBpPathNomads .. 'nomads_energyproj_hit07_emit.bp',  -- short flash
}

EnergyProjHitLand1 = {  -- no dirt emitters on purpuse
    EmtBpPathNomads .. 'nomads_energyproj_hit01_emit.bp',  -- slow flash
    EmtBpPathNomads .. 'nomads_energyproj_hit02_emit.bp',  -- short star effect large
    EmtBpPathNomads .. 'nomads_energyproj_hit03_emit.bp',  -- circular effect at ground
    EmtBpPathNomads .. 'nomads_energyproj_hit04_emit.bp',  -- sparks moving up
    EmtBpPathNomads .. 'nomads_energyproj_hit05_emit.bp',  -- flames
    EmtBpPathNomads .. 'nomads_energyproj_hit06_emit.bp',  -- flame refraction effect
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
    EmtBpPathNomads .. 'nomads_energyproj_large_hit02_emit.bp',  -- short star effect large
    EmtBpPathNomads .. 'nomads_energyproj_large_hit07_emit.bp',   -- short flash
}

EnergyProjHitLand2 = {
    EmtBpPathNomads .. 'nomads_energyproj_large_hit01_emit.bp',  -- slow flash
    EmtBpPathNomads .. 'nomads_energyproj_large_hit02_emit.bp',  -- short star effect large
	EmtBpPathNomads .. 'nomads_energyproj_large_hit02_secondary_emit.bp',  -- even shorter star effect large, imitates flash
    EmtBpPathNomads .. 'nomads_energyproj_large_hit02_tertiary_emit.bp',  -- longer star effect giving illusion of expansion
	EmtBpPathNomads .. 'nomads_energyproj_large_hit03_emit.bp',  -- circular effect at ground
    EmtBpPathNomads .. 'nomads_energyproj_large_hit04_emit.bp',  -- sparks moving up
    EmtBpPathNomads .. 'nomads_energyproj_large_hit05_emit.bp',  -- flames
    EmtBpPathNomads .. 'nomads_energyproj_large_hit06_emit.bp',  -- flame refraction effect
}

EnergyProjHitWater2 = EnergyProjHitLand2

EnergyProjHitUnit2 = EnergyProjHitLand2

EnergyProjHitAirUnit2 = EnergyProjHitUnit2
EnergyProjHitShield2 = EnergyProjHitNone2
EnergyProjHitProjectile2 = EnergyProjHitNone2
EnergyProjHitProp2 = EnergyProjHitUnit2
EnergyProjHitUnderWater2 = EnergyProjHitUnit2

--------------------------------------------------------------------------
--  Nomads Energy bomb (for SACU death mainly)
--------------------------------------------------------------------------

EnergyBombSurface = {
    EmtBpPathNomads .. 'nomads_energybomb_01_emit.bp',  -- large circular effect at ground
    EmtBpPathNomads .. 'nomads_energybomb_02_emit.bp',  -- sparkles
    EmtBpPathNomads .. 'nomads_energybomb_03_emit.bp',  -- heat refraction
    EmtBpPathNomads .. 'nomads_energybomb_04_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_energybomb_05_emit.bp',  -- slow flash
    EmtBpPathNomads .. 'nomads_energybomb_06_emit.bp',  -- rays
    EmtBpPathNomads .. 'nomads_energybomb_07_emit.bp',  -- cloud 1
    EmtBpPathNomads .. 'nomads_energybomb_08_emit.bp',  -- cloud 2
    EmtBpPathNomads .. 'nomads_energybomb_09_emit.bp',  -- expanding flames
}

EnergyBombUnderWater = {
    EmtBpPathNomads .. 'nomads_energybomb_01_emit.bp',  -- large circular effect at ground
    EmtBpPathNomads .. 'nomads_energybomb_02_emit.bp',  -- sparkles
    EmtBpPathNomads .. 'nomads_energybomb_03_emit.bp',  -- heat refraction
    EmtBpPathNomads .. 'nomads_energybomb_04_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_energybomb_05_emit.bp',  -- slow flash
    EmtBpPathNomads .. 'nomads_energybomb_06_emit.bp',  -- rays
--    EmtBpPathNomads .. 'nomads_energybomb_07_emit.bp',  -- cloud 1
--    EmtBpPathNomads .. 'nomads_energybomb_08_emit.bp',  -- cloud 2
    EmtBpPathNomads .. 'nomads_energybomb_09_emit.bp',  -- expanding flames
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
--  Nomads Nuke missile
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
--  Nomads Nuke Blackhole
--------------------------------------------------------------------------

NukeBlackholeFlash = {
    EmtBpPathNomads .. 'nomads_blackhole_06_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_blackhole_11_emit.bp',  -- shockwave ring
    EmtBpPathNomads .. 'nomads_blackhole_18_emit.bp',  -- big flash
}

NukeBlackholeCore = {
--    EmtBpPathNomads .. 'nomads_blackhole_01_emit.bp',  -- large shrinking circle
--    EmtBpPathNomads .. 'nomads_blackhole_02_emit.bp',  -- electric discharges
    EmtBpPathNomads .. 'nomads_blackhole_03_emit.bp',  -- black core
    EmtBpPathNomads .. 'nomads_blackhole_04_emit.bp',  -- refract light stripes inwards
    EmtBpPathNomads .. 'nomads_blackhole_05_emit.bp',  -- refract center core
--    EmtBpPathNomads .. 'nomads_blackhole_07_emit.bp',  -- electric discharges 2
--    EmtBpPathNomads .. 'nomads_blackhole_08_emit.bp',  -- flat distorting ring
    EmtBpPathNomads .. 'nomads_blackhole_09_emit.bp',  -- flat refraction ring
--    EmtBpPathNomads .. 'nomads_blackhole_10_emit.bp',  -- flat ring
--    EmtBpPathNomads .. 'nomads_blackhole_17_emit.bp',  -- fast dark stripe rings
    EmtBpPathNomads .. 'nomads_blackhole_19_emit.bp',  -- rotating cloud rings big
    EmtBpPathNomads .. 'nomads_blackhole_21_emit.bp',  -- rotating cloud rings small
}

NukeBlackholeRadiationBeams = {  -- if changed be sure to update the length and thickness tables below!!
    EmtBpPathNomads .. 'nomads_blackhole_radiationbeam1.bp',
    EmtBpPathNomads .. 'nomads_blackhole_radiationbeam2.bp',
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
--    EmtBpPathNomads .. 'nomads_blackhole_16_emit.bp',  -- inward stripes
}

NukeBlackholeEnergyBeam1 = EmtBpPath .. 'seraphim_othuy_beam_01_emit.bp'
NukeBlackholeEnergyBeam2 = EmtBpPath .. 'seraphim_othuy_beam_02_emit.bp'
NukeBlackholeEnergyBeam3 = EmtBpPath .. 'seraphim_othuy_beam_03_emit.bp'
NukeBlackholeEnergyBeamEnd = EmtBpPath .. 'seraphim_othuy_hit_01_emit.bp'

NukeBlackholeDissipating = {
    EmtBpPathNomads .. 'nomads_blackhole_22_emit.bp',  -- star and glowing core
}

NukeBlackholeDissipated = {  -- used when the black hole effects are removed
    EmtBpPathNomads .. 'nomads_blackhole_11_emit.bp',  -- shockwave ring
    EmtBpPathNomads .. 'nomads_blackhole_12_emit.bp',  -- smoke cloud
    EmtBpPathNomads .. 'nomads_blackhole_13_emit.bp',  -- large barely visible smoke cloud
    EmtBpPathNomads .. 'nomads_blackhole_14_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_blackhole_15_emit.bp',  -- circle
--    EmtBpPathNomads .. 'nomads_blackhole_20_emit.bp',  -- rotating cloud rings inward
    EmtBpPath .. 'destruction_explosion_concussion_ring_03_emit.bp',
}

NukeBlackholeDustCloud01 = {
    EmtBpPathNomads .. 'nomads_blackhole_dustcloud01_emit.bp',
}

NukeBlackholeDustCloud02 = {
    EmtBpPathNomads .. 'nomads_blackhole_dustcloud02_emit.bp',
}

NukeBlackholeFireball = {
    EmtBpPathNomads .. 'nomads_blackhole_fireball01_emit.bp',
}

NukeBlackholeFireballHit = {
    EmtBpPathNomads .. 'nomads_blackhole_fireball_hit01_emit.bp',
    EmtBpPathNomads .. 'nomads_blackhole_fireball_hit02_emit.bp',
}

NukeBlackholeFireballTrail = {
    EmtBpPathNomads .. 'nomads_blackhole_fireballtrail.bp',
}

NukeBlackholeFireballPolyTrail = EmtBpPathNomads .. 'nomads_blackhole_fireballpolytrail.bp'

NukeBlackholeFireArmSegment1 = {
    EmtBpPathNomads .. 'nomads_blackhole_fireline05_emit.bp',
}

NukeBlackholeFireArmSegment2 = {
    EmtBpPathNomads .. 'nomads_blackhole_fireline04_emit.bp',
}

NukeBlackholeFireArmSegment3 = {
    EmtBpPathNomads .. 'nomads_blackhole_fireline03_emit.bp',
}

NukeBlackholeFireArmSegment4 = {
    EmtBpPathNomads .. 'nomads_blackhole_fireline02_emit.bp',
}

NukeBlackholeFireArmSegment5 = {
    EmtBpPathNomads .. 'nomads_blackhole_fireline01_emit.bp',
}

NukeBlackholeFireArmCenter1 = {
    EmtBpPathNomads .. 'nomads_blackhole_firecenter01_emit.bp',
    EmtBpPathNomads .. 'nomads_blackhole_firecenter03_emit.bp',
    EmtBpPathNomads .. 'nomads_blackhole_firesparks01_emit.bp',
    EmtBpPathNomads .. 'nomads_blackhole_firesparks02_emit.bp',
}

NukeBlackholeFireArmCenter2 = {
    EmtBpPathNomads .. 'nomads_blackhole_firecenter02_emit.bp',
}

ACUDeathBlackholeFlash = NukeBlackholeFlash
ACUDeathBlackholeCore = NukeBlackholeCore
ACUDeathBlackholeGeneric = NukeBlackholeGeneric
ACUDeathBlackholeDissipated = NukeBlackholeDissipated

BlackholeLeftoverPerm = {
    EmtBpPathNomads .. 'nomads_blackhole_leftover_01_emit.bp',  -- fog
    EmtBpPathNomads .. 'nomads_blackhole_leftover_02_emit.bp',  -- ball
    EmtBpPathNomads .. 'nomads_blackhole_leftover_03_emit.bp',  -- ambient fire
}

BlackholePropEffects = {
    EmtBpPathNomads .. 'nomads_blackhole_propeffect01_emit.bp', -- yellow particles
    EmtBpPathNomads .. 'nomads_blackhole_propeffect02_emit.bp', -- brown particles
    EmtBpPathNomads .. 'nomads_blackhole_propeffect03_emit.bp', -- white particles
    EmtBpPathNomads .. 'nomads_blackhole_propeffect04_emit.bp', -- grey particles
--    EmtBpPathNomads .. 'nomads_blackhole_propeffect05_emit.bp', -- dirt chunks
}

--------------------------------------------------------------------------
--  Nomads Construction effects
--------------------------------------------------------------------------

ConstructionBeamsPerBuildBone = 2
ConstructionBeams = {
    EmtBpPathNomads .. 'nomads_construction_beam01.bp',
}

ConstructionBeamStartPoint = {
    EmtBpPathNomads .. 'nomads_construction_beamstart01_emit.bp',  -- flashing orange
}

ConstructionBeamEndPoints = {
    EmtBpPathNomads .. 'nomads_construction_beamend01_emit.bp',  -- flashing orange
    EmtBpPathNomads .. 'nomads_construction_beamend02_emit.bp',  -- the sparks at the end of a build beam
}

ConstructionPulsingFlash = {
    EmtBpPathNomads .. 'nomads_construction_beingbuilt_pulsingflash01_emit.bp',
}

ConstructionDefaultBeingBuiltEffect = {
    EmtBpPathNomads .. 'nomads_construction_beingbuilt01_emit.bp',  -- build plates normal height
}

ConstructionDefaultBeingBuiltEffectHigh = {
    EmtBpPathNomads .. 'nomads_construction_beingbuilt02_emit.bp',  -- build plates extra high
}

ConstructionDefaultBeingBuiltEffectStretched = {
    EmtBpPathNomads .. 'nomads_construction_beingbuilt03_emit.bp',  -- build plates stretched (for long buildings)
}

ConstructionDefaultBeingBuiltEffectsMobile = {
    EmtBpPathNomads .. 'nomads_construction_beingbuiltmobile01_emit.bp'
}

FactoryConstructionField = {
--    EmtBpPathNomads .. 'nomads_factory_constructionplane01_emit.bp',  -- particles moving inwards
--    EmtBpPathNomads .. 'nomads_factory_constructionplane02_emit.bp',  -- flashing orange
    EmtBpPathNomads .. 'nomads_factory_constructionplane03_emit.bp',  -- particles moving inwards, offset 1
    EmtBpPathNomads .. 'nomads_factory_constructionplane04_emit.bp',  -- particles moving inwards, offset 2
}

SCUFactoryBeam = EmtBpPathNomads .. 'nomads_construction_beam01.bp'
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
    EmtBpPathNomads .. 'nomads_reclaim_beam01.bp',
}

ReclaimBeamStartPoint = {
    EmtBpPathNomads .. 'nomads_construction_beamstart01_emit.bp',  -- flashing orange
}

ReclaimBeamEndPoints = {
    EmtBpPathNomads .. 'nomads_reclaim_beamend01_emit.bp',  -- flashing green
    EmtBpPathNomads .. 'nomads_reclaim_beamend02_emit.bp',  -- green stripes inward
    EmtBpPathNomads .. 'nomads_reclaim_beamend03_emit.bp',  -- white stripes inward
    EmtBpPath .. 'reclaim_02_emit.bp',
}

ReclaimObjectAOE = {
    EmtBpPath .. 'reclaim_01_emit.bp',
}

--------------------------------------------------------------------------
--  Dropship
--------------------------------------------------------------------------

DropshipThruster = {
    EmtBpPathNomads .. 'Nomads_dropship_thruster.bp',
    EmtBpPath      .. 'nuke_munition_launch_trail_06_emit.bp',
}

DropshipThrusterBig = {
    EmtBpPathNomads .. 'Nomads_dropship_thruster_big.bp',
    EmtBpPath      .. 'nuke_munition_launch_trail_06_emit.bp',
}

AcuDropshipGroundFire = {
    EmtBpPathNomads .. 'Nomads_surfacefire1.bp',
    EmtBpPathNomads .. 'Nomads_surfacefire2.bp',
    EmtBpPathNomads .. 'Nomads_surfacefire3.bp',
}

--------------------------------------------------------------------------
--  Unit additional effects
--------------------------------------------------------------------------

TankBusterWeaponFired = {
    EmtBpPathNomads .. 'nomads_tankbuster_weaponfired01_emit.bp',  -- shell
    EmtBpPathNomads .. 'nomads_tankbuster_weaponfired02_emit.bp',  -- dark smoke
}

--------------------------------------------------------------------------
--  Shield emitters
--------------------------------------------------------------------------

ShieldDamagedBeams = {
--    EmtBpPathNomads .. 'nomads_shield_beam01.bp',
--    EmtBpPathNomads .. 'nomads_shield_beam02.bp',
--    EmtBpPathNomads .. 'nomads_shield_beam03.bp',
    EmtBpPathNomads .. 'nomads_shield_beam11.bp',
    EmtBpPathNomads .. 'nomads_shield_beam12.bp',
    EmtBpPathNomads .. 'nomads_shield_beam13.bp',
}

ShieldDamagedBeamStartPointEffects = {
--    EmtBpPathNomads .. 'nomads_shield_beamstart01_emit.bp',
    EmtBpPathNomads .. 'nomads_shield_beamstart02_emit.bp',
}

ShieldDamagedBeamEndPointEffects = {
    EmtBpPathNomads .. 'nomads_shield_beamend10_emit.bp', -- blue stars
    EmtBpPathNomads .. 'nomads_shield_beamend11_emit.bp', -- yellow stars
    EmtBpPathNomads .. 'nomads_shield_beamend13_emit.bp', -- red stars

--    EmtBpPathNomads .. 'nomads_shield_beamend12_emit.bp', -- large star effect
    EmtBpPathNomads .. 'nomads_shield_beamend20_emit.bp', -- large star effect

--    EmtBpPathNomads .. 'nomads_shield_beamend01_emit.bp',
--    EmtBpPathNomads .. 'nomads_shield_beamend02_emit.bp',
--    EmtBpPathNomads .. 'nomads_shield_beamend03_emit.bp',
--    EmtBpPathNomads .. 'nomads_shield_beamend04_emit.bp',
}

ShieldEffects = {
    EmtBpPathNomads .. 'nomads_shield_generator_T2_01_emit.bp',
    EmtBpPathNomads .. 'nomads_shield_generator_T2_02_emit.bp',
}

ShieldAmbientEffectBeams = {
    EmtBpPathNomads .. 'nomads_shield_ambientbeam01.bp',
}

ShieldAmbientEffects_NumSimultanious = 3
ShieldAmbientEffects_AvgInterval = 5

StealthShieldEffects = {
    EmtBpPathNomads .. 'nomads_shield_generator_T2_02_emit.bp',
    EmtBpPathNomads .. 'nomads_stealth_generator_T2_01_emit.bp',
    EmtBpPathNomads .. 'nomads_stealth_generator_T2_02_emit.bp',
    EmtBpPathNomads .. 'nomads_stealth_generator_T2_03_emit.bp',
}

--------------------------------------------------------------------------
--  Nomads Orbital Strike Effects
--------------------------------------------------------------------------

OrbitalStrikeMissile_AtmosphereTrail = {
    EmtBpPath .. 'destruction_underwater_sinking_wash_01_emit.bp',
}

--------------------------------------------------------------------------
-- Artillery Support Ability
--------------------------------------------------------------------------

ArtillerySupportActive = {
    EmtBpPathNomads .. 'nomads_artillerysupport01_emit.bp',  -- red ring
}

ArtillerySupportAtTargetLocation = {
    EmtBpPathNomads .. 'targeted_effect_02_emit.bp',  -- red target marker, blinks 5 times
}

--------------------------------------------------------------------------
-- Nomads movement effects
--------------------------------------------------------------------------

-- These 2 are hardcoded in terraintypes.lua
--HoverEffect_Idle = {
--    EmtBpPathNomads .. 'nomads_hover_idle01_emit.bp',
--}
--HoverEffect_Moving = {
--    EmtBpPathNomads .. 'nomads_hover_moving01_emit.bp',
--}

HoverEffect_Moving_Smoke = {
    EmtBpPathNomads .. 'nomads_hover_moving_smoke01_emit.bp',
}

HoverEffect_Stopping_Smoke = {
    EmtBpPathNomads .. 'nomads_hover_stopping_smoke01_emit.bp',
}

HoverEffect_Stopped_Smoke = {
    EmtBpPathNomads .. 'nomads_hover_stopped_smoke01_emit.bp',
}

AirThrusterCruisingBeam = EmtBpPathNomads .. 'nomads_airthruster_cruising01_emit.bp'
AirThrusterIdlingBeam = EmtBpPathNomads .. 'nomads_airthruster_cruising02_emit.bp'

AirThrusterLargeCruisingBeam = EmtBpPathNomads .. 'nomads_airthruster_cruising_large01_emit.bp'
AirThrusterLargeIdlingBeam = EmtBpPathNomads .. 'nomads_airthruster_cruising_large02_emit.bp'

RailgunBoat_Moving_Smoke = {
    EmtBpPathNomads .. 'nomads_hover_moving_smoke01_emit.bp',
}

RailgunBoat_Stopping_Smoke = {
    EmtBpPathNomads .. 'nomads_hover_stopping_smoke01_emit.bp',
}

RailgunBoat_Stopped_Smoke = {
    EmtBpPathNomads .. 'nomads_hover_stopped_smoke01_emit.bp',
}

T2TransportThrusters = {
    EmtBpPathNomads .. 'nomads_t2transport_thruster01_emit.bp',  -- normal thruster
    EmtBpPathNomads .. 'nomads_t2transport_thruster05_emit.bp',  -- thruster heat refraction
}

T2TransportThrusterBurn = {  -- played when the t2 transport descents to pick up or drop off units
    EmtBpPathNomads .. 'nomads_t2transport_thruster02_emit.bp',  -- larger thruster
    EmtBpPathNomads .. 'nomads_t2transport_thruster05_emit.bp',  -- thruster heat refraction
}

T2TransportThrusterBurnSurfaceEffect = {
    EmtBpPathNomads .. 'nomads_t2transport_thruster03_emit.bp',  -- fire ring at surface
    EmtBpPathNomads .. 'nomads_t2transport_thruster05_emit.bp',  -- surface heat refraction
}

T2TransportThrusterBurnWaterSurfaceEffect = {
    EmtBpPathNomads .. 'nomads_t2transport_thruster03_emit.bp',  -- fire ring at surface
    EmtBpPathNomads .. 'nomads_t2transport_thruster05_emit.bp',  -- surface heat refraction
    EmtBpPathNomads .. 'nomads_t2transport_thruster06_emit.bp',  -- water ripples / steam
}

ExpTransportThrusters = {
    EmtBpPathNomads .. 'nomads_exptransport_thruster01_emit.bp',  -- normal thruster
    EmtBpPathNomads .. 'nomads_exptransport_thruster05_emit.bp',  -- thruster heat refraction
}

ExpTransportThrusterBurn = {  -- played when the experimental transport descents to pick up or drop off units
    EmtBpPathNomads .. 'nomads_exptransport_thruster02_emit.bp',  -- larger thruster
    EmtBpPathNomads .. 'nomads_exptransport_thruster05_emit.bp',  -- thruster heat refraction
}

ExpTransportThrusterBurnSurfaceEffect = {
    EmtBpPathNomads .. 'nomads_exptransport_thruster03_emit.bp',  -- fire ring at surface
    EmtBpPathNomads .. 'nomads_exptransport_thruster05_emit.bp',  -- surface heat refraction
}

ExpTransportThrusterBurnWaterSurfaceEffect = {
    EmtBpPathNomads .. 'nomads_exptransport_thruster03_emit.bp',  -- fire ring at surface
    EmtBpPathNomads .. 'nomads_exptransport_thruster05_emit.bp',  -- surface heat refraction
    EmtBpPathNomads .. 'nomads_exptransport_thruster06_emit.bp',  -- water ripples / steam
}

--------------------------------------------------------------------------
--  Nomads Destruction effects
--------------------------------------------------------------------------

ExpTransportDestruction = {
    EmtBpPath .. 'destruction_explosion_concussion_ring_03_emit.bp',
    EmtBpPath .. 'explosion_fire_sparks_02_emit.bp',
--    EmtBpPath .. 'distortion_ring_01_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_01_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_02_emit.bp',
    EmtBpPath .. 'destruction_explosion_debris_03_emit.bp',
    EmtBpPathNomads .. 'Nomads_surfacefire1.bp',
    EmtBpPathNomads .. 'Nomads_surfacefire2.bp',
    EmtBpPathNomads .. 'Nomads_surfacefire3.bp',
}

SCUDestructionRegularSurface = {
    EmtBpPath .. 'destruction_explosion_concussion_ring_01_emit.bp',
    EmtBpPath .. 'destruction_explosion_cloud_01_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
    EmtBpPathNomads .. 'nomads_SCUDestruction01_emit.bp',
}

SCUDestructionRegularUnderWater = {
    EmtBpPathNomads .. 'nomads_SCUDestruction02_emit.bp',  -- bubbles
    EmtBpPathNomads .. 'nomads_SCUDestruction03_emit.bp',  -- water effect 1 (looks like a cloud)
    EmtBpPathNomads .. 'nomads_SCUDestruction04_emit.bp',  -- water effect 2
    EmtBpPathNomads .. 'nomads_SCUDestruction05_emit.bp',  -- a few flashes
}

SCUDestructionSmallExplosionsSurface = {
    EmtBpPath .. 'destruction_explosion_fire_plume_02_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
    EmtBpPath .. 'destruction_unit_hit_shrapnel_01_emit.bp',
}

SCUDestructionSmallExplosionsUnderWater = {
    EmtBpPathNomads .. 'nomads_SCUDestruction07_emit.bp',  -- smaller version of water effect 1 (looks like a cloud)
    EmtBpPathNomads .. 'nomads_SCUDestruction06_emit.bp',  -- smaller flashes
}

--------------------------------------------------------------------------
--  NOMADS CAPACITOR
--------------------------------------------------------------------------

CapacitorBeingUsed = {
    EmtBpPathNomads .. 'nomads_capacitor02_emit.bp',
}

CapacitorCharging = {
    EmtBpPathNomads .. 'nomads_capacitor01_emit.bp',
}

CapacitorEmpty = {
    EmtBpPathNomads .. 'nomads_capacitor01_emit.bp',
}

CapacitorFull = {
    EmtBpPathNomads .. 'nomads_capacitor03_emit.bp',
}

--------------------------------------------------------------------------
--  Nomads Buoys
--------------------------------------------------------------------------

BuoyMuzzleFx = {}

BuoyTrail = {
    EmtBpPath .. 'nomads_buoy_light01_emit.bp',  -- flashing orange light
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
    EmtBpPathNomads .. 'nomads_buoy_light01_emit.bp',  -- flashing orange light
}

BuoyActive = {  -- emitters for when buoy is activated
    EmtBpPathNomads .. 'nomads_buoy_light02_emit.bp',  -- red flashing star light
}

BuoyDestroyed = {  -- emitters that play when the buoy is destroyed
}

IntelProbeSurfaceActive = BuoyActive
IntelProbeSurfaceDestroyed = BuoyDestroyed
IntelProbeSurfaceLights = BuoyLights

--------------------------------------------------------------------------
--  NOMADS AMBIENT UNIT EMITTERS
--------------------------------------------------------------------------

NavalAntennaeLights_Left = {
--    EmtBpPathNomads .. 'nomads_navallight01_emit.bp',  -- constant green light
--    EmtBpPathNomads .. 'nomads_navallight02_emit.bp',  -- constant red light
--    EmtBpPathNomads .. 'nomads_navallight03_emit.bp',  -- flashing green light morse
    EmtBpPathNomads .. 'nomads_navallight04_emit.bp',  -- flashing red light morse
--    EmtBpPathNomads .. 'nomads_navallight05_emit.bp',  -- constant blue light
--    EmtBpPathNomads .. 'nomads_navallight06_emit.bp',  -- flashing blue light
--    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}

NavalAntennaeLights_Right = {
    EmtBpPathNomads .. 'nomads_navallight04_emit.bp',  -- flashing red light morse
}

NavalAntennaeLights_Left_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}

NavalAntennaeLights_Right_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}

AntennaeLights1 = {
    EmtBpPathNomads .. 'nomads_light01_emit.bp',  -- chase light 1
    EmtBpPathNomads .. 'nomads_light02_emit.bp',  -- chase light 2
}
AntennaeLights2 = {
    EmtBpPathNomads .. 'nomads_light02_emit.bp',  -- chase light 2
    EmtBpPathNomads .. 'nomads_light03_emit.bp',  -- chase light 3
}
AntennaeLights3 = {
    EmtBpPathNomads .. 'nomads_light03_emit.bp',  -- chase light 3
    EmtBpPathNomads .. 'nomads_light04_emit.bp',  -- chase light 4
}
AntennaeLights4 = {
    EmtBpPathNomads .. 'nomads_light04_emit.bp',  -- chase light 4
    EmtBpPathNomads .. 'nomads_light05_emit.bp',  -- chase light 5
}
AntennaeLights5 = {
    EmtBpPathNomads .. 'nomads_light05_emit.bp',  -- chase light 5
    EmtBpPathNomads .. 'nomads_light06_emit.bp',  -- chase light 6
}
AntennaeLights6 = {
    EmtBpPathNomads .. 'nomads_light06_emit.bp',  -- chase light 6
    EmtBpPathNomads .. 'nomads_light07_emit.bp',  -- chase light 7
}
AntennaeLights7 = {
    EmtBpPathNomads .. 'nomads_light07_emit.bp',  -- chase light 7
    EmtBpPathNomads .. 'nomads_light08_emit.bp',  -- chase light 8
}
AntennaeLights8 = {
    EmtBpPathNomads .. 'nomads_light08_emit.bp',  -- chase light 8
    EmtBpPathNomads .. 'nomads_light09_emit.bp',  -- chase light 9
}
AntennaeLights9 = {
    EmtBpPathNomads .. 'nomads_light09_emit.bp',  -- chase light 9
    EmtBpPathNomads .. 'nomads_light10_emit.bp',  -- chase light 10
}
AntennaeLights10 = {
    EmtBpPathNomads .. 'nomads_light10_emit.bp',  -- chase light 10
    EmtBpPathNomads .. 'nomads_light01_emit.bp',  -- chase light 1
}

AntennaeLights_1_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_2_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_3_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_4_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_5_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_6_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_7_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_8_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_9_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}
AntennaeLights_10_Bombard = {
    EmtBpPathNomads .. 'nomads_navallight07_emit.bp',  -- flashing purple light
}

--------------------------------------------------------------------------
--  NOMADS AMBIENT STRUCTURE EMITTERS
--------------------------------------------------------------------------

T1HydroPowerPlantSurface1 = {
    EmtBpPath .. 'hydrocarbon_smoke_01_emit.bp',  -- thick smoke
    EmtBpPathNomads .. 'nomads_t1hpg_ambient03.bp',  -- sparkles (bigger)
}

T1HydroPowerPlantSurface2 = {
    EmtBpPathNomads .. 'nomads_t1hpg_ambient02.bp',  -- sparkles
}

T1HydroPowerPlantSubmerged1 = {
    EmtBpPath .. 'nomads_t1hpg_ambient01.bp',  -- bubbles
}

T1HydroPowerPlantSubmerged2 = {
    EmtBpPath .. 'nomads_t1hpg_ambient01.bp',  -- bubbles
}

T2MFAmbient = {
    EmtBpPathNomads .. 'nomads_t2mf_ambient01_emit.bp',  -- heat refraction
}

T3MFAmbient = {
    EmtBpPathNomads .. 'nomads_t3mf_ambient01_emit.bp',  -- heat refraction
    EmtBpPathNomads .. 'nomads_t3mf_ambient02_emit.bp',  -- emit effect at core
}

T1PGAmbient = {
    EmtBpPathNomads .. 'nomads_t1pg_ambient01_emit.bp',
}

T2PGAmbient = {
    EmtBpPathNomads .. 'nomads_t2pg_ambient01_emit.bp',
--    EmtBpPathNomads .. 'nomads_t2pg_ambient02_emit.bp',
}

T3PGAmbient = {
    EmtBpPathNomads .. 'nomads_t3pg_ambient01_emit.bp',
}

T2PGAmbientDischargeBeam = EmtBpPathNomads .. 'nomads_t2pg_ambientbeam.bp'

T3MassExtractorActiveEffects = {
    EmtBpPathNomads .. 'nomads_t3mex_active01_emit.bp',
    EmtBpPathNomads .. 'nomads_t3mex_active02_emit.bp',
    EmtBpPathNomads .. 'nomads_t3mex_active03_emit.bp',
}

T3MassExtractorActiveBeams = {
    EmtBpPathNomads .. 'nomads_t3mex_active_beam01.bp',
}

T2TacticalMissileDefenseTargetAcquired = {
    EmtBpPathNomads .. 'nomads_tmd_active01_emit.bp',
}

T2MobileTacticalMissileDefenseTargetAcquired = {
    EmtBpPathNomads .. 'nomads_tmd_active01_emit.bp',
}

--------------------------------------------------------------------------
-- Intelligence overcharge effects
--------------------------------------------------------------------------

T1RadarOvercharge = {
    EmtBpPathNomads .. 'nomads_intelboost_active01_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_active02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T1RadarOverchargeRecovery = {}

T1RadarOverchargeCharging = {
    EmtBpPathNomads .. 'nomads_intelboost_charging02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T1RadarOverchargeExplosion = {
    EmtBpPathNomads .. 'nomads_intelboost_empblast01_emit.bp',  -- light blue effect at ground
    EmtBpPathNomads .. 'nomads_intelboost_empblast02_emit.bp',  -- electricity effect at ground
    EmtBpPathNomads .. 'nomads_intelboost_empblast03_emit.bp',  -- short expanding large electricity effect
    EmtBpPathNomads .. 'nomads_intelboost_empblast04_emit.bp',  -- short flash
    EmtBpPathNomads .. 'nomads_intelboost_empblast05_emit.bp',  -- short flat flash
}

T2RadarOvercharge = {
    EmtBpPathNomads .. 'nomads_intelboost_active01_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_active02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T2RadarOverchargeRecovery = {}

T2RadarOverchargeCharging = {
    EmtBpPathNomads .. 'nomads_intelboost_charging02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T2RadarOverchargeExplosion = T1RadarOverchargeExplosion

T3RadarOvercharge = {
    EmtBpPathNomads .. 'nomads_intelboost_active01_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_active02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T3RadarOverchargeRecovery = {}

T3RadarOverchargeCharging = {
    EmtBpPathNomads .. 'nomads_intelboost_charging02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T3RadarOverchargeExplosion = T1RadarOverchargeExplosion

T1SonarOvercharge = {
    EmtBpPathNomads .. 'nomads_intelboost_active01_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_active02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T1SonarOverchargeRecovery = {}

T1SonarOverchargeCharging = {
    EmtBpPathNomads .. 'nomads_intelboost_charging02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T1SonarOverchargeExplosion = T1RadarOverchargeExplosion

T2SonarOvercharge = {
    EmtBpPathNomads .. 'nomads_intelboost_active01_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_active02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T2SonarOverchargeRecovery = {}

T2SonarOverchargeCharging = {
    EmtBpPathNomads .. 'nomads_intelboost_charging02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T2SonarOverchargeExplosion = T1RadarOverchargeExplosion

T3SonarOvercharge = {
    EmtBpPathNomads .. 'nomads_intelboost_active01_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_active02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T3SonarOverchargeRecovery = {}

T3SonarOverchargeCharging = {
    EmtBpPathNomads .. 'nomads_intelboost_charging02_emit.bp',
    EmtBpPathNomads .. 'nomads_intelboost_charging03_emit.bp',
}

T3SonarOverchargeExplosion = T1RadarOverchargeExplosion

--------------------------------------------------------------------------
--  Meteor Fx
--------------------------------------------------------------------------

MeteorLandImpact = {
    EmtBpPathNomads .. 'MeteorImpact01.bp',  -- flash
    EmtBpPathNomads .. 'MeteorImpact02.bp',  -- fire rings
    EmtBpPathNomads .. 'MeteorImpact03.bp',  -- circular dust cloud
--    EmtBpPathNomads .. 'MeteorImpact04.bp',  -- black stripes outwards
    EmtBpPathNomads .. 'MeteorImpact05.bp',  -- expelled stars
--    EmtBpPathNomads .. 'MeteorImpact06.bp',  -- expelled dirt chunks
    EmtBpPathNomads .. 'MeteorImpact10.bp',  -- residual smoke plumes
    EmtBpPathNomads .. 'MeteorImpact11.bp',  -- residual smoke / brightish afterglow
    EmtBpPathNomads .. 'MeteorImpact12.bp',  -- residual smoke upwards (like other ACUs have)
}

MeteorSeabedImpact = {
    EmtBpPathNomads .. 'MeteorImpact01.bp',
--    EmtBpPathNomads .. 'MeteorImpact02.bp',
--    EmtBpPathNomads .. 'MeteorImpact03.bp',
--    EmtBpPathNomads .. 'MeteorImpact04.bp',
--    EmtBpPathNomads .. 'MeteorImpact05.bp',
    EmtBpPathNomads .. 'MeteorImpact06.bp',
    EmtBpPathNomads .. 'MeteorImpact09.bp',  -- under water flash
}

MeteorWaterImpact = {
--    EmtBpPathNomads .. 'MeteorImpact01.bp',
--    EmtBpPathNomads .. 'MeteorImpact02.bp',
    EmtBpPathNomads .. 'MeteorImpact03.bp',
--    EmtBpPathNomads .. 'MeteorImpact04.bp',
--    EmtBpPathNomads .. 'MeteorImpact05.bp',
    EmtBpPathNomads .. 'MeteorImpact06.bp',
    EmtBpPathNomads .. 'MeteorImpact07.bp',  -- water plume
    EmtBpPathNomads .. 'MeteorImpact08.bp',  -- water ripples / ring
}


MeteorResidualSmoke01 = {
    EmtBpPathNomads .. 'MeteorResidualSmoke01.bp',
}

MeteorResidualSmoke02 = {
    EmtBpPathNomads .. 'MeteorResidualSmoke02.bp',
}

MeteorResidualSmoke03 = {
    EmtBpPathNomads .. 'MeteorResidualSmoke03.bp',
}

MeteorSmokeRing = {
    EmtBpPathNomads .. 'MeteorSmokeRing01.bp',
}

MeteorTrail = {
    EmtBpPathNomads .. 'MeteorTrail01.bp',  -- thick dark smoke
    EmtBpPathNomads .. 'MeteorTrail02.bp',  -- fireball
    EmtBpPathNomads .. 'MeteorTrail03.bp',  -- grey smoke
--    EmtBpPathNomads .. 'MeteorTrail04.bp',  -- blueish smoke
}

MeteorUnderWaterTrail = {
--    EmtBpPathNomads .. 'MeteorTrail01.bp',  -- thick dark smoke
    EmtBpPathNomads .. 'MeteorTrail02.bp',  -- fireball
    EmtBpPathNomads .. 'MeteorTrail03.bp',  -- grey smoke
    EmtBpPathNomads .. 'MeteorTrail04.bp',  -- blueish smoke
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
    EmtBpPathNomads .. 'nomads_meteorcover_openingsteam01_emit.bp',  -- Smoke rings slowly rising
}

ACUMeteorCoverLaunch = {
    EmtBpPathNomads .. 'nomads_meteorcover_launch01_emit.bp',  -- several small flashes
}

ACUMeteorCoverExplode = {
    EmtBpPathNomads .. 'nomads_meteorcover_explode01_emit.bp',  -- flash
    EmtBpPathNomads .. 'nomads_meteorcover_explode03_emit.bp',  -- fast explosion
    EmtBpPathNomads .. 'nomads_meteorcover_explode04_emit.bp',  -- fire cloud
    EmtBpPathNomads .. 'nomads_meteorcover_explode05_emit.bp',  -- smoke
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
    EmtBpPathNomads .. 'nomads_meteorcover_explode07_emit.bp',  -- shockwave rings
})

ACUMeteorCoverExplodeWater = TableCat( ACUMeteorCoverExplode, {
    EmtBpPathNomads .. 'nomads_meteorcover_explode07_emit.bp',  -- shockwave rings
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
    EmtBpPathNomads .. 'tree_fire01_emit.bp',
    EmtBpPath .. 'destruction_damaged_fire_distort_01_emit.bp',
    EmtBpPath .. 'forest_fire_smoke_01_emit.bp',
}

FallenTreeFire = TreeFire

TreeBigFire = {
    EmtBpPathNomads .. 'tree_bigfire01_emit.bp',  -- flames
    EmtBpPathNomads .. 'tree_bigfire02_emit.bp',  -- heat effect
    EmtBpPathNomads .. 'tree_bigfire03_emit.bp',  -- low ground effect
    EmtBpPath .. 'destruction_damaged_smoke_02_emit.bp',
}

FallenTreeBigFire = TreeBigFire

TreeAfterFireEffects = {
    EmtBpPath .. 'tree_afterfiresmoke01_emit.bp',
}

TreeDisintegrate = {
    EmtBpPathNomads .. 'tree_disintegrate01_emit.bp',
}

FallenTreeDisintegrate = TreeDisintegrate

--------------------------------------------------------------------------
--  NOMADS PLASMAFLAMETHROWER-EMITTERS
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
