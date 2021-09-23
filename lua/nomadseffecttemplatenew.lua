local EffectTemplate = import('/lua/EffectTemplates.lua')
local EmtBpPath = '/effects/emitters/'
local EmtBpPathNomads = '/effects/emitters/nomads'
local TableCat = import('/lua/utilities.lua').TableCat

-- McChaffee: New Effects Start 
--------------------------------------------------------------------------
--  Nomads Plamsa Cannon Small
--------------------------------------------------------------------------
-- Used on T1/T2 Heavy Tank

NomadsPlamsaCannonSmallFlash = {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
}

NomadsPlamsaCannonSmallTrail = {
    EmtBpPathNomads .. 'N/A',
}

NomadsPlamsaCannonSmallPolyTrail = EmtBpPathNomads .. 'N/A'

NomadsPlasmaCannonSmallHitNone1 = {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
}

NomadsPlasmaCannonSmallHitLand1 = TableCat( NomadsPlasmaCannonSmallHitNone1, {
    EmtBpPathNomads .. 'N/A', 
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonSmallHitWater1 = TableCat( NomadsPlasmaCannonSmallHitNone1, {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonSmallHitUnit1 = TableCat( NomadsPlasmaCannonSmallHitNone1, {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonSmallHitAirUnit1 = NomadsPlasmaCannonSmallHitUnit1
NomadsPlasmaCannonSmallHitShield1 = NomadsPlasmaCannonSmallHitNone1
NomadsPlasmaCannonSmallHitProjectile1 = NomadsPlasmaCannonSmallHitUnit1
NomadsPlasmaCannonSmallHitProp1 = NomadsPlasmaCannonSmallHitUnit1
NomadsPlasmaCannonSmallHitUnderWater1 = NomadsPlasmaCannonSmallHitLand1

--------------------------------------------------------------------------
--  Nomads Plamsa Cannon Medium
--------------------------------------------------------------------------
-- Used on T3 Heavy Tank, T3 Gunship, T2 Destroyer

NomadsPlamsaCannonMediumFlash = {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
}

NomadsPlamsaCannonMediumTrail = {
    EmtBpPathNomads .. 'N/A',
}

NomadsPlamsaCannonMediumPolyTrail = EmtBpPathNomads .. 'N/A'

NomadsPlasmaCannonMediumHitNone1 = {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
}

NomadsPlasmaCannonMediumHitLand1 = TableCat( NomadsPlasmaCannonMediumHitNone1, {
    EmtBpPathNomads .. 'N/A', 
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonMediumHitWater1 = TableCat( NomadsPlasmaCannonMediumHitNone1, {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonMediumHitUnit1 = TableCat( NomadsPlasmaCannonMediumHitNone1, {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonMediumHitAirUnit1 = NomadsPlasmaCannonMediumHitUnit1
NomadsPlasmaCannonMediumHitShield1 = NomadsPlasmaCannonMediumHitNone1
NomadsPlasmaCannonMediumHitProjectile1 = NomadsPlasmaCannonMediumHitUnit1
NomadsPlasmaCannonMediumHitProp1 = NomadsPlasmaCannonMediumHitUnit1
NomadsPlasmaCannonMediumHitUnderWater1 = NomadsPlasmaCannonMediumHitLand1

--------------------------------------------------------------------------
--  Nomads Plamsa Cannon Large
--------------------------------------------------------------------------
-- Used on T2 Artillery, T3 Mobile Artillery, T3 Battleship

NomadsPlamsaCannonLargeFlash = {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
}

NomadsPlamsaCannonLargeTrail = {
    EmtBpPathNomads .. 'N/A',
}

NomadsPlamsaCannonLargePolyTrail = EmtBpPathNomads .. 'N/A'

NomadsPlasmaCannonLargeHitNone1 = {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
}

NomadsPlasmaCannonLargeHitLand1 = TableCat( NomadsPlasmaCannonLargeHitNone1, {
    EmtBpPathNomads .. 'N/A', 
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonLargeHitWater1 = TableCat( NomadsPlasmaCannonLargeHitNone1, {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonLargeHitUnit1 = TableCat( NomadsPlasmaCannonLargeHitNone1, {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonLargeHitAirUnit1 = NomadsPlasmaCannonLargeHitUnit1
NomadsPlasmaCannonLargeHitShield1 = NomadsPlasmaCannonLargeHitNone1
NomadsPlasmaCannonLargeHitProjectile1 = NomadsPlasmaCannonLargeHitUnit1
NomadsPlasmaCannonLargeHitProp1 = NomadsPlasmaCannonLargeHitUnit1
NomadsPlasmaCannonLargeHitUnderWater1 = NomadsPlasmaCannonLargeHitLand1

--------------------------------------------------------------------------
--  Nomads Plamsa Artillery
--------------------------------------------------------------------------
-- Used on T3 Artillery

NomadsPlamsaCannonArtilleryFlash = {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
}

NomadsPlamsaCannonArtilleryTrail = {
    EmtBpPathNomads .. 'N/A',
}

NomadsPlamsaCannonArtilleryPolyTrail = EmtBpPath .. 'N/A'

NomadsPlasmaCannonArtilleryHitNone1 = {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
}

NomadsPlasmaCannonArtilleryHitLand1 = TableCat( NomadsPlasmaCannonSmallHitNone1, {
    EmtBpPathNomads .. 'N/A', 
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonArtilleryHitWater1 = TableCat( NomadsPlasmaCannonSmallHitNone1, {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonArtilleryHitUnit1 = TableCat( NomadsPlasmaCannonSmallHitNone1, {
    EmtBpPathNomads .. 'N/A',
    EmtBpPathNomads .. 'N/A',
})

NomadsPlasmaCannonArtilleryHitAirUnit1 = NomadsPlasmaCannonArtilleryHitUnit1
NomadsPlasmaCannonArtilleryHitShield1 = NomadsPlasmaCannonArtilleryHitNone1
NomadsPlasmaCannonArtilleryHitProjectile1 = NomadsPlasmaCannonArtilleryHitUnit1
NomadsPlasmaCannonArtilleryHitProp1 = NomadsPlasmaCannonArtilleryHitUnit1
NomadsPlasmaCannonArtilleryHitUnderWater1 = NomadsPlasmaCannonArtilleryHitLand1





-- McChaffee: Stuff I'm keeping around until I see what it does. 
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
    --EmtBpPathNomads .. 'nomads_blackhole_13_emit.bp',  -- large barely visible smoke cloud
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
    EmtBpPathNomads .. 'nomads_blackhole_leftover_04_emit.bp',  -- ambient fire upward
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
--    EmtBpPathNomads .. 'MeteorImpact11.bp',  -- residual smoke / brightish afterglow
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
--    EmtBpPathNomads .. 'MeteorTrail01.bp',  -- thick dark smoke
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
