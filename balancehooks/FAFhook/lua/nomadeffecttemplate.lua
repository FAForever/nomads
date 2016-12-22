local EmtBpPath = '/effects/emitters/'
local TableCat = import('/lua/utilities.lua').TableCat

ACUMeteorCoverExplode = {
    EmtBpPathNomad .. 'nomad_meteorcover_explode01_emit.bp',  # flash
    EmtBpPathNomad .. 'nomad_meteorcover_explode03_emit.bp',  # fast explosion
    EmtBpPathNomad .. 'nomad_meteorcover_explode04_emit.bp',  # fire cloud
    EmtBpPathNomad .. 'nomad_meteorcover_explode05_emit.bp',  # smoke
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
    EmtBpPathNomad .. 'nomad_meteorcover_explode07_emit.bp',  # shockwave rings
})

ACUMeteorCoverExplodeWater = TableCat( ACUMeteorCoverExplode, {
    EmtBpPathNomad .. 'nomad_meteorcover_explode07_emit.bp',  # shockwave rings
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
