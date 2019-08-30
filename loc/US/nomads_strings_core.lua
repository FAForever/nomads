---- US LOCALIZATION FILE B58 ----


--------------------------------------------------------
----  GENERIC STUFF
--------------------------------------------------------

ability_artillery = "Artillery"
ability_bombardarea = "Area bombardment"
ability_orbitalstrike = "Orbital strike"
ability_orbitalstrikebuoy = "Orbital strike Buoy"
ability_orbitalstrikewreck = "Orbital strike on wreck"
ability_orbitalprotection = "Orbital protection"
ability_artillerysupport = "Artillery Support"
ability_supportedartillerygun = "Supported Artillery Gun"
ability_flares = "Flares"
ability_firecontrol = "Fire Control"
ability_radarboost = "Radar Boost"
ability_sonarboost = "Sonar Boost"
ability_visionboost = "Vision Boost"
ability_omniboost = "Omni Boost"
ability_limitedlifetime = "Limited Lifetime"
ability_underwater_railgun = "Submerged Railgun"
ability_transport_expbeamer = "Transports Beamer Experimentals"
ability_transport_experimental = "Transports Experimentals"
ability_transportable = "Transportable"
ability_submergedsurfaceattack = "Attacks from under water"
ability_accuratewhenstill = "Accurate weapon when still"
ability_inaccuratewhenmoving = "Inaccurate weapon when moving"
ability_unstunable = "Immune to EMP"
ability_capacitor = "Capacitor Booster"
ability_lessdmgvsexp = "Reduced damage versus experimentals"


_HideMenu = "Hide menu"
_CreditsNomads = "Nomads Credits"
restricted_units_Nomads = "No Nomads"
NomadsCampaign = "Nomads campaign"
NomadsCampaignSubtitle = ""
NomadsCampaignDescription = "Nomads campaign"
SeraphimCampaign = "Seraphim campaign"
SeraphimCampaignDescription = "Seraphim campaign"


NomadsNewOptions0001 = "Unit selection sounds"
NomadsNewOptions0002 = "None"
NomadsNewOptions0003 = "Simple"
NomadsNewOptions0004 = "Full"
NomadsNewOptions0005 = "Sets the audio response level when selecting units"
NomadsNewOptions0006 = "Unit selection sounds"
NomadsNewOptions0011 = "Unit command acknowledge sounds"
NomadsNewOptions0012 = "None"
NomadsNewOptions0013 = "Simple"
NomadsNewOptions0014 = "Full"
NomadsNewOptions0015 = "Sets the audio response level when giving commands to units"
NomadsNewOptions0016 = "Unit command acknowledge sounds"


--------------------------------------------------------
---- TOOLTIPS
--------------------------------------------------------

tooltip_lobby_nomadsfaction_title = "Nomads"
tooltip_lobby_nomadsfaction_desc = ""
tooltip_lobby_unit_restriction_nonomads_title = "No Nomads"
tooltip_lobby_unit_restriction_nonomads_desc = ""

tooltip_radar_boost_title = "Radar Boost Toggle"
tooltip_radar_boost_desc = "Starts/stops charging radar boosting for the selection units. When finished charging up radar boost initiates automatically. Charging up requires energy."
tooltip_bombardmode_title = "Bombard Mode Toggle"
tooltip_bombardmode_desc = "Bombardment mode decreases the reload time by 50% but increases the fireing randomness."
tooltip_no_air_title = "Anti-Air Toggle"
tooltip_no_air_desc ="Turn the selection units anti-air attack on/off"
tooltip_snipermode_title = "Sniper Mode Toggle"
tooltip_snipermode_desc = "Turn sniper mode on/off"
tooltip_usecapacitor_title = "Capacitor Toggle"
tooltip_usecapacitor_desc = "Boost unit temporarily (firepower, build power, regeneration) using the capacitor ability"
tooltip_anchor_title = "Anchor Toggle"
tooltip_anchor_desc = "Immobilizes the unit and increases weapon range, vision, radar and build rate by 30%."
tooltip_stealthshield_title = "Stealth Shield Toggle"
tooltip_stealthshield_desc = "Turn the select units shield and stealth field on/off"

SpecAbil_LaunchNuke_title = "Quick nuke launch"
SpecAbil_LaunchNuke_desc = "Launch a nuke. Single click to launch a nuke from 1 launcher, double click to launch a nuke from all available launchers in a wide spread pattern. The attack can be adjusted by clicking the middle mouse button."

SpecAbil_LaunchTacMissile_title = "Quick tactical missile launch"
SpecAbil_LaunchTacMissile_desc = "Launch a tactical missile. Single click to launch a missile from 1 launcher, double click to launch a tactical missile from all available launchers. The attack can be adjusted by clicking the middle mouse button."

SpecAbil_IntelOvercharge_title = "Intel Boost"
SpecAbil_IntelOvercharge_desc = "Start intel boost. Single click to start intel boost on the radar or sonar nearest to the specified position, double click to have all available radars and sonars in range of the specified position start intel boost."

SpecAbil_AreaBombardment_title = "Area bombardment"
SpecAbil_AreaBombardment_desc = "Bombards an area with missiles from orbit. Double click to use a wide spread pattern. The attack can be adjusted by clicking the middle mouse button."

SpecAbil_AreaReinforcement_title = "Area reinforcement"
SpecAbil_AreaReinforcement_desc = "Reinforces an area from orbit."
SpecAbil_AreaReinforcement2_title = "Area reinforcement"
SpecAbil_AreaReinforcement2_desc = "Reinforces an area from orbit."

SpecAbil_IntelProbe_title = "Intel Probe"
SpecAbil_IntelProbe_desc = "Launches a probe to the designated destination."

SpecAbil_RemoteViewing_title = "Scry"
SpecAbil_RemoteViewing_desc = "View an area of the map using all (selected) scrying capable units. Double click to use a wide spread pattern. Use the middle mouse button to adjust the pattern."

tooltipui0496="Scry"
tooltipui0497="View an area of the map"

-- TODO: import items from CEP used in Nomads, such as the campaign manager

--------------------------------------------------------
---- ENHANCEMENTS
--------------------------------------------------------

-- ACU
NomadsACUEnh_DisruptiveField_Description = "Creates a disruptive field around the ACU that damages all enemy units within range."
NomadsACUEnh_DisruptiveField_Help = "Disruptor Field"
NomadsACUEnh_DisruptiveField_Remove = "Remove Disruptor Field"

NomadsACUEnh_OrbitalStrike_Description = "Adds a device that coordinates attacks from orbit on enemy units near the ACU."
NomadsACUEnh_OrbitalStrike_Help = "Orbital Strike"
NomadsACUEnh_OrbitalStrike_Remove = "Remove Orbital Strike"

NomadsACUEnh_OrbitalBombardment_Description = "Adds the ability to bombard a limited area from orbit. Only an area around the ACU and SCU's can be bombarded."
NomadsACUEnh_OrbitalBombardment_Help = "Light Orbital Bombardment"
NomadsACUEnh_OrbitalBombardment_Remove = "Remove Light Orbital Bombardment"

NomadsACUEnh_HeavyOrbitalBombardment_Description = "Increases the number of missiles in the bombardment, as well as the area."
NomadsACUEnh_HeavyOrbitalBombardment_Help = "Heavy Orbital Bombardment"
NomadsACUEnh_HeavyOrbitalBombardment_Remove = "Remove Heavy Orbital Bombardment"

NomadsACUEnh_FlameThrower_Description = "Upgrades the main weapon to a flamethrower that damages all units in a line. Perfect against large groups of small to medium units."
NomadsACUEnh_FlameThrower_Help = "Flamethrower"
NomadsACUEnh_FlameThrower_Remove = "Remove Flamethrower"

NomadsACUEnh_AreaReinforcement_Description = "Allows deploying stationary reinforcements launched from orbit anywhere on the battlefield."
NomadsACUEnh_AreaReinforcement_Help = "Orbital Reinforcement"
NomadsACUEnh_AreaReinforcement_Remove = "Remove Orbital Reinforcement"

NomadsACUEnh_AreaReinforcement2_Description = "Allows deploying stationary reinforcements launched from orbit anywhere on the battlefield."
NomadsACUEnh_AreaReinforcement2_Help = "Orbital Reinforcement"
NomadsACUEnh_AreaReinforcement2_Remove = "Remove Orbital Reinforcement"

NomadsACUEnh_GunUpgrade_Description = "Increases the Kinetic Cannon's damage output by several factors. Also increases range of the Kinetic Cannon and Overcharge."
NomadsACUEnh_GunUpgrade_Help = "Antimatter Rounds"
NomadsACUEnh_GunUpgrade_Remove = "Remove Antimatter Rounds"

NomadsACUEnh_DoubleGuns_Description = "All Kinetic Cannon damage (excluding Overcharge) doubled by installing a second gun barrel next to the main gun."
NomadsACUEnh_DoubleGuns_Help = "Extra Barrel"
NomadsACUEnh_DoubleGuns_Remove = "Remove Extra Barrel"

NomadsACUEnh_RapidRepair_Description = "Increases health and adds a Rapid Repair device to the ACU, repairing the ACU automatically at no cost. There is a delay before repairs start, and the device must reinitialise each time the ACU is damaged or fires a weapon."
NomadsACUEnh_RapidRepair_Help = "Rapid Repair"
NomadsACUEnh_RapidRepair_Remove = "Remove Rapid Repair"

NomadsACUEnh_PowerArmor_Description = "Greatly increases the max health of the ACU."
NomadsACUEnh_PowerArmor_Help = "Powered Armor"
NomadsACUEnh_PowerArmor_Remove = "Remove Powered Armor"

NomadsACUEnh_SniperMode_Description = "Allows the ACU to enable and disable sniper mode at will. Sniper mode increases the range and damage of the ACU's main weapon but disables overcharge. Stacks with the gun enhancements."
NomadsACUEnh_SniperMode_Help = "Sniper Mode"
NomadsACUEnh_SniperMode_Remove = "Remove Sniper Mode"

NomadsACUEnh_IntelProbe_Description = "Intel Probes provide temporary radar and sonar coverage at an area on the map."
NomadsACUEnh_IntelProbe_Help = "Intel Probe"
NomadsACUEnh_IntelProbe_Remove = "Remove Intel Probe"

NomadsACUEnh_IntelProbeAdv_Description = "Upgrades the Intel Probe with enhanced sensors for better intelligence gathering."
NomadsACUEnh_IntelProbeAdv_Help = "Advanced Intel Probe"
NomadsACUEnh_IntelProbeAdv_Remove = "Remove Advanced Intel Probe"

NomadsACUEnh_MovementSpeedIncrease_Description = "Greatly improves the ACU's movement speed."
NomadsACUEnh_MovementSpeedIncrease_Help = "Improved Locomotor"
NomadsACUEnh_MovementSpeedIncrease_Remove = "Remove Improved Locomotor"

NomadsACUEnh_Capacitor_Description = "Allows the ACU to temporarily boost its stats with the capacitor ability for an appropriate energy cost."
NomadsACUEnh_Capacitor_Help = "Capacitor"
NomadsACUEnh_Capacitor_Remove = "Remove Capacitor"

NomadsACUEnh_AddCapacitor_Description = "Enhances the ACU with an additional capacitor that increases the duration of the capacitor boost."
NomadsACUEnh_AddCapacitor_Help = "Additional Capacitor"
NomadsACUEnh_AddCapacitor_Remove = "Remove Additional Capacitor"


-- SCU
NomadsSCUEnh_MovementSpeedIncrease_Description = "Greatly improves the SACU's move speed."
NomadsSCUEnh_MovementSpeedIncrease_Help = "Improved Locomotor"
NomadsSCUEnh_MovementSpeedIncrease_Remove = "Remove Improved Locomotor"

NomadsSCUEnh_RapidRepair_Description = "Increases health and adds a Rapid Repair device to the SACU, repairing the SACU automatically at no cost. There is a delay before repairs start, and the device must reinitialise each time the SACU is damaged or fires a weapon."
NomadsSCUEnh_RapidRepair_Help = "Rapid Repair"
NomadsSCUEnh_RapidRepair_Remove = "Remove Rapid Repair"

NomadsSCUEnh_PowerArmor_Description = "Greatly increases the max health of the ACU."
NomadsSCUEnh_PowerArmor_Help = "Powered Armor"
NomadsSCUEnh_PowerArmor_Remove = "Remove Powered Armor"

NomadsSCUEnh_LeftArmGun_Description = "Enhances the SACU with a Kinetic Cannon. When the Capacitor ability is active the cannon gains a damage-over-time effect."
NomadsSCUEnh_LeftArmGun_Help = "Kinetic Cannon"
NomadsSCUEnh_LeftArmGun_Remove = "Remove Kinetic Cannon"

NomadsSCUEnh_LeftArmGunUpgrade_Description = "Upgrades the Kinetic Cannon so it deals more damage."
NomadsSCUEnh_LeftArmGunUpgrade_Help = "Overclocked Kinetic Cannon"
NomadsSCUEnh_LeftArmGunUpgrade_Remove = "Remove Overclocked Kinetic Cannon"

NomadsSCUEnh_RightArmGun_Description = "Enhances the SACU with a rapid fire gatling gun. When the capacitor ability is active, the gatling gun deals more damage."
NomadsSCUEnh_RightArmGun_Help = "Gatling Gun"
NomadsSCUEnh_RightArmGun_Remove = "Remove Gatling Gun"

NomadsSCUEnh_RightArmGunUpgrade_Description = "Upgrades the gatling gun so it deals additional damage."
NomadsSCUEnh_RightArmGunUpgrade_Help = "Improved Gatling Gun"
NomadsSCUEnh_RightArmGunUpgrade_Remove = "Remove Improved Gatling Gun"

NomadsSCUEnh_LeftArmEngineering_Description = "Enhances the SACU with an additional engineering tool. Also allows the SACU to construct all Nomads structures. When the capacitor ability is active the engineering functions are sped up."
NomadsSCUEnh_LeftArmEngineering_Help = "Engineering Matrix"
NomadsSCUEnh_LeftArmEngineering_Remove = "Engineering Matrix"

NomadsSCUEnh_RightArmEngineering_Description = "Enhances the SACU with an additional engineering tool. Also allows the SACU to construct all Nomads structures. When the capacitor ability is active the engineering functions are sped up."
NomadsSCUEnh_RightArmEngineering_Help = "Engineering Matrix"
NomadsSCUEnh_RightArmEngineering_Remove = "Remove Engineering Matrix"

NomadsSCUEnh_Capacitor_Description = "Allows the SACU to temporarily boost its stats with the Capacitor ability for an appropriate energy cost."
NomadsSCUEnh_Capacitor_Help = "Capacitor"
NomadsSCUEnh_Capacitor_Remove = "Remove Capacitor"

NomadsSCUEnh_AddCapacitor_Description = "Enhances the SACU with an additional Capacitor that increases the duration of the capacitor ability."
NomadsSCUEnh_AddCapacitor_Help = "Additional Capacitor"
NomadsSCUEnh_AddCapacitor_Remove = "Remove Additional Capacitor"

NomadsSCUEnh_LeftArmRocket_Description = "Enhances the SACU with a rocket launcher attached to the left shoulder that fires salvos of rockets against surface targets. When the Capacitor ability is active, the rockets gain wider splash damage and a damage-over-time effect."
NomadsSCUEnh_LeftArmRocket_Help = "Rocket Launcher"
NomadsSCUEnh_LeftArmRocket_Remove = "Remove Rocket Launcher"

NomadsSCUEnh_RightArmRocket_Description = "Enhances the SACU with a Rocket Launcher attached to the right shoulder that fires salvos of rockets against surface targets. When the Capacitor ability is active, the rockets gain wider splash damage and a damage-over-time effect."
NomadsSCUEnh_RightArmRocket_Help = "Rocket Launcher"
NomadsSCUEnh_RightArmRocket_Remove = "Remove Rocket Launcher"

NomadsSCUEnh_LeftArmRailgun_Description = "Enhances the SACU with an Underwater Railgun. When the Capacitor ability is active the Railgun's rate of fire is increased."
NomadsSCUEnh_LeftArmRailgun_Help = "Underwater Railgun"
NomadsSCUEnh_LeftArmRailgun_Remove = "Remove Underwater Railgun"

NomadsSCUEnh_ResourceAllocation_Description = "Increases the SACU's resource generation to 10 mass per second and 1000 energy per second, which speeds up the Capacitor charge time."
NomadsSCUEnh_ResourceAllocation_Help = "Resource Allocation System"
NomadsSCUEnh_ResourceAllocation_Remove = "Remove Resource Allocation System"


--------------------------------------------------------
---- MISC UNITS
--------------------------------------------------------

-- ACU
XNL0001_desc = "Armored Command Unit"
XNL0001_help = "Armored Commander is a combination of barracks and command center. Contains all the blueprints necessary to build a basic army from scratch. Upgradeable with combat enhancements, advanced engineering suits, resource allocation system, and capacitor."
XNL0001_name = "Armored Command Unit"

-- surface operations support
xno0001_desc = "Surface Operations Support"
xno0001_help = "Provides a number of services to the ACU."
xno0001_name = "Surface Operations Support"

xnc0001_desc = "Orbital Frigate"
xnc0001_help = "Provides a number of services to the ACU."
xnc0001_name = "Planetary Operations Support Ship"

xnc0002_desc = "Orbital Cruiser"
xnc0002_help = "Heavily damaged orbital cruiser."
xnc0002_name = "Orbital Cruiser"


-- orbital dropship
xna0001_desc = "Drop pod"
xna0001_help = "Transports units to the planets surface. Acts like a meteor."
xna0001_name = "Meteor"

-- area reinforcement unit
xna2101_desc = "Area reinforcement"
xna2101_help = "Stand alone unit that automatically attacks enemies in range. Has a limited lifetime, the unit crashes when out of fuel."
xna2101_name = "Fanatic"

-- orbital artillery gun (slave unit for T3 heavy artillery)
xno2302_desc = "Orbital Artillery Gun"
xno2302_help = "A gun turret in orbit. Fires high damage shells. Controlled by a ground station."
xno2302_name = "Orbital Artillery Gun"

-- support commander (and enhancement presets)
xnl0301_desc = "Support Armored Command Unit"
xnl0301_help = "This variant is not enhanced during construction and does not have weapons and very limited engineering capabilities."
xnl0301_name = "Support Armored Command Unit"

xnl0301_combat_desc = "Support Armored Command Unit (Preset: Combat)"
xnl0301_combat_help = "Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or a combination. Enhanced during construction with an upgraded main cannon on the left arm and close combat machine gun on the right arm."
xnl0301_combat_name = "Support Armored Command Unit (Preset: Combat)"

xnl0301_default_desc = "Support Armored Command Unit (Preset: Regular)"
xnl0301_default_help = "Enhanced during construction with a Kinetic Cannon on its left arm and an Engineering Matrix on its right arm."
xnl0301_default_name = "Support Armored Command Unit (Preset: Regular)"

xnl0301_energyrocket_desc = "Support Armored Command Unit (Preset: Energy Rocket Launcher)"
xnl0301_energyrocket_help= "Enhanced during construction with a rocket launcher on both shoulders and a resource generator on the back to improve capacitor fill rate."
xnl0301_energyrocket_name = "Support Armored Command Unit (Preset: Energy Rocket Launcher)"

xnl0301_engineer_desc = "Support Armored Command Unit (Preset: Engineer)"
xnl0301_engineer_help = "Enhanced during construction with an Engineering Matrix on each arm."
xnl0301_engineer_name = "Support Armored Command Unit (Preset: Engineer)"

xnl0301_fastcombat_desc = "Support Armored Command Unit (Preset: Fast Combat)"
xnl0301_fastcombat_help = "Enhanced during construction with a Gatling Gun on the right arm, a Rocket Launcher on the left arm, and an Improved Locomotor."
xnl0301_fastcombat_name = "Support Armored Command Unit (Preset: Fast Combat)"

xnl0301_gunslinger_desc = "Support Armored Command Unit (Preset: Gunslinger)"
xnl0301_gunslinger_help = "Enhanced during construction with an Overclocked Kinetic Cannon on its left arm and an Additional Capacitor on the right arm."
xnl0301_gunslinger_name = "Support Armored Command Unit (Preset: Gunslinger)"

xnl0301_heavytrooper_desc = "Support Armored Command Unit (Preset: Heavy Trooper)"
xnl0301_heavytrooper_help = "Enhanced during construction with an Overclocked Kinetic Cannon on the left arm, a Gatling Gun on the right arm, and a Rapid Repair system."
xnl0301_heavytrooper_name = "Support Armored Command Unit (Preset: Heavy Trooper)"

xnl0301_naturalproducer_desc = "Support Armored Command Unit (Preset: Producer)"
xnl0301_naturalproducer_help = "Enhanced during construction with an Engineering Matrix on each arm and a Resource Allocation System."
xnl0301_naturalproducer_name = "Support Armored Command Unit (Preset: Producer)"

xnl0301_rambo_desc = "Support Armored Command Unit (Preset: Rambo)"
xnl0301_rambo_help = "Enhanced during construction with an Additional Capacitor on the right arm, an Overclocked Kinetic Cannon on the left arm, and Powered Armor."
xnl0301_rambo_name = "Support Armored Command Unit (Preset: Rambo)"

xnl0301_sniper_desc = "Support Armored Command Unit (Preset: Sniper)"
xnl0301_sniper_help = "Enhanced during construction with an upgraded weapon on the right arm and the sniper enhancement on its back."
xnl0301_sniper_name = "Support Armored Command Unit (Preset: Sniper)"

xnl0301_rocket_desc = "Support Armored Command Unit (Preset: Rocket Launcher)"
xnl0301_rocket_help = "Enhanced during construction with a Rocket Launcher on each arm and an Improved Locomotor."
xnl0301_rocket_name = "Support Armored Command Unit (Preset: Rocket Launcher)"

xnl0301_trooper_desc = "Support Armored Command Unit (Preset: Trooper)"
xnl0301_trooper_help = "Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or a combination. Enhanced during construction with a simple gun on the left arm."
xnl0301_trooper_name = "Support Armored Command Unit (Preset: Trooper)"

xnl0301_antinaval_desc = "Support Armored Command Unit (Preset: Anti-Naval)"
xnl0301_antinaval_help = "Enhanced during construction with an Underwater Railgun on the left arm, an Additional Capacitor on the right arm and an Improved Locomotor."
xnl0301_antinaval_name = "Support Armored Command Unit (Preset: Anti-Naval)"

xnl0301_amphibious_desc = "Support Armored Command Unit (Preset: Amphibious)"
xnl0301_amphibious_help = "Enhanced during construction with an Underwater Railgun on the left arm, a Gatling Gun on the right arm and an Improved Locomotor."
xnl0301_amphibious_name = "Support Armored Command Unit (Preset: Amphibious)"

xnl0301_ras_desc = "Support Armored Command Unit (Preset: RAS)"
xnl0301_ras_help = "Enhanced during construction with a Resource Allocation System."
xnl0301_ras_name = "Support Armored Command Unit (Preset: RAS)"
--------------------------------------------------------
---- T1 UNITS
--------------------------------------------------------

-- Land units

-- T1 engineer
xnl0105_desc = "Engineer"
xnl0105_help = "Tech 1 amphibious construction, repair, capture and reclamation unit."
xnl0105_name = "Engineer"

-- T1 land scout
xnl0101_desc = "Land scout"
xnl0101_help = "Fast, lightly armored reconnaissance vehicle. Armed with a very light gun and a state-of-the-art sensor suite."
xnl0101_name = "Silhouette"

-- T1 LAV
xnl0106_desc = "Light Assault Vehicle"
xnl0106_help = "Lightly armored hovering vehicle. Provides direct-fire support against low-end units. Can fire from transports."
xnl0106_name = "Grasshopper"

-- T1 medium tank
xnl0201_desc = "Medium Tank"
xnl0201_help = "Armored medium tank. Armed with a single cannon, useful against lower tier units."
xnl0201_name = "Orbis"

-- T1 AA gun / artillery
xnl0103_desc = "Mobile Anti-Air Gun / Artillery"
xnl0103_help = "Mobile anti-air defense and artillery. Effective against low-end enemy air units. Can also target surface units with its rockets."
xnl0103_name = "Barrager"

-- T1 tank destroyer
xnl0107_desc = "Tank Destroyer"
xnl0107_help = "Carries a long range cannon that kills almost any lower tier unit with one direct hit."
xnl0107_name = "Assassin"


-- Air units
-- T1 air scout
xna0101_desc = "Air Scout"
xna0101_help = "Standard air scout."
xna0101_name = "Peeper"

-- T1 interceptor
xna0102_desc = "Interceptor"
xna0102_help = "Anti-air fighter. Useful for intercepting lower tier air units."
xna0102_name = "Falcon"

-- T1 bomber
xna0103_desc = "Bomber"
xna0103_help = "A low-end bomber equipped with air-to-ground rocket launchers."
xna0103_name = "Phoenix"

-- T1 gunship
xna0105_desc = "Light Gunship"
xna0105_help = "A low-end gunship designed to take out ground targets."
xna0105_name = "Golem"

-- T1 transport
xna0107_desc = "Light Air Transport"
xna0107_help = "An unarmed, small capacity transport with a high speed. Carries land units through the air."
xna0107_name = "Diligence"


-- Naval units

-- submarine
xns0203_desc = "Attack Submarine"
xns0203_help = "Has torpedo launchers to attack naval units from below the water surface."
xns0203_name = "Buccaneer Class"

-- frigate
xns0103_desc = "Frigate"
xns0103_help = "Low-end naval unit. Has a single fast firing cannon and an anti-air missile launcher."
xns0103_name = "Lance Class"


-- Structures

-- land factory
xnb0101_desc = "Land Factory"
xnb0101_help = "Constructs Tech 1 land units. Upgradeable."
xnb0101_name = "Land Factory"

-- air factory
xnb0102_desc = "Air Factory"
xnb0102_help = "Constructs Tech 1 air units. Upgradeable."
xnb0102_name = "Air Factory"

-- t1 naval factory
xnb0103_desc = "Naval Factory"
xnb0103_help = "Constructs Tech 1 naval units. Upgradeable."
xnb0103_name = "Naval Factory"

-- t1 power generator
xnb1101_desc = "Power Generator"
xnb1101_help = "Generates Energy. Construct next to other structures for adjacency bonus. Explodes violently when destroyed, this can cause chain reactions."
xnb1101_name = "Power Generator"

-- hydrocarbon power plant
XNB1102_desc = "Hydrocarbon Power Plant"
XNB1102_help = "Generates Energy. Must be constructed on hydrocarbon deposits. Construct structures next to Hydrocarbon power plant for adjacency bonus."
XNB1102_name = "Hydrocarbon Power Plant"

-- t1 mass extractor
xnb1103_desc = "Mass Extractor"
xnb1103_help = "Extracts Mass. Must be constructed on Mass deposits. Construct structures next to Mass extractor for adjacency bonus."
xnb1103_name = "Mass Extractor"

-- energy storage
xnb1105_desc = "Energy Storage"
xnb1105_help = "Stores Energy. Construct next to power generators for adjacency bonus."
xnb1105_name = "Energy Storage"

-- mass storage
xnb1106_desc = "Mass Storage"
xnb1106_help = "Stores Mass. Construct next to extractors or fabricators for adjacency bonus."
xnb1106_name = "Mass Storage"

-- T1 PD
xnb2101_desc = "Point Defense"
xnb2101_help = "Low-end defensive tower that attacks land- and sea-based units. Does not engage aircraft or submerged units."
xnb2101_name = "Scatterer"

-- T1 AA gun
xnb2102_desc = "Anti-Air Turret"
xnb2102_help = "Anti-air tower. Designed to engage low-end aircraft."
xnb2102_name = "Slicer"

-- t1 torpedo launcher
xnb2109_desc = "Torpedo Launcher"
xnb2109_help = "Low-end anti-naval defense system."
xnb2109_name = "Sea Needle"

-- t1 radar
xnb3101_desc = "Radar System"
xnb3101_help = "Radar system with minimal range. Detects and tracks surface and air units. Can boost its range for a short time."
xnb3101_name = "Sibyl 1"

-- T1 sonar
xnb3102_desc = "Sonar System"
xnb3102_help = "Sonar system with minimal range. Detects and tracks naval units. Can boost its range for a short time."
xnb3102_name = "Echo 1"

-- wall
xnb5101_desc = "Wall Section"
xnb5101_help = "Restricts the movement of enemy units. Offers minimal protection from enemy fire."
xnb5101_name = "Wall"


--------------------------------------------------------
---- T2 UNITS
--------------------------------------------------------

-- Land units

-- T2 engineer
xnl0208_desc = "Engineer"
xnl0208_help = "Tech 2 amphibious construction, repair, capture and reclamation unit."
xnl0208_name = "Engineer"

-- T2 light tank
xnl0203_desc = "Fast Assault Tank"
xnl0203_help = "Assault tank, has a high movement speed and fast firing cannons."
xnl0203_name = "Rogue"

-- T2 Missile launcher
xnl0111_desc = "Mobile Missile Launcher"
xnl0111_help = "Amphibious missile launcher, fires low yield tactical rockets. Designed to attack at long range. Can attack surface targets from under water."
xnl0111_name = "Avalanche"

-- T2 AA gun
xnl0205_desc = "Mobile AA Artillery"
xnl0205_help = "Mobile AA unit. Armed with rocket artillery."
xnl0205_name = "Skyshell"

-- T2 heavy tank
xnl0202_desc = "Heavy Tank"
xnl0202_help = "Heavy tank armed with powerful weapons and heavy armour."
xnl0202_name = "Brute"

-- T2 assault bot
-- xnl0300_desc = "Combat Bot"
-- xnl0300_help = "The combat bot is armed with a single cannon, useful against light to medium tier units."
-- xnl0300_name = "Goliath"

-- T2 EMP tank
xnl0306_desc = "EMP Tank"
xnl0306_help = "Equipped with EMP cannons, that stun enemy units and deal additional damage to shields. Useful for supressing groups of enemies."
xnl0306_name = "Dominator"

-- Air units
-- T2 F/B
xna0202_desc = "Fighter/Bomber"
xna0202_help = "Multipurpose unit that uses its rocket launchers on either side against air or surface units."
xna0202_name = "Spitfire"

-- T2 torpedo gunship
xna0203_desc = "Torpedo Gunship"
xna0203_help = "Versatile anti-surface and anti-submarine gunship. Carries a gun and a torpedo launcher."
xna0203_name = "Vanguard"

-- T2 transport
xna0104_desc = "Air Transport"
xna0104_help = "Unarmed air transport that can carry land units."
xna0104_name = "Scalestor"


-- Naval units

-- destroyer
xns0201_desc = "Destroyer"
xns0201_help = "Carries heavy cannons and medium railguns to deal with light submerged units. Does not have anti-air weapons."
xns0201_name = "Firestorm Class"

-- cruiser
xns0202_desc = "Cruiser"
xns0202_help = "Equipped with anti-air missiles, manual tactical missile launchers. Armed with an EMP weapon that deals additional damage to shields and suppresses enemy forces."
xns0202_name = "Mercenary Class"

-- torpedo boat
xns0102_desc = "Railgun Carrier"
xns0102_help = "Anti-submarine ship. Uses underwater railguns to attack submarines and ships. Also carries a tactical missile defense turret."
xns0102_name = "Whaler Class"


-- Structures

-- land factory (HQ, FAF specific)
xnb0201_desc = "Land Factory HQ"
xnb0201_help = "Constructs Tech 2 land units. HQ factory, required to build same tier land units and same tier land support factories. Upgradeable."
xnb0201_name = "Land Factory HQ"

-- land factory (support, FAF specific)
znb9501_desc = "Land Factory"
znb9501_help = "Constructs Tech 2 land units. Supporting factory, requires a land HQ factory to build same tier land units. Upgradeable once a land HQ factory is built."
znb9501_name = "Land Factory"

-- air factory (HQ, FAF specific)
xnb0202_desc = "Air Factory HQ"
xnb0202_help = "Constructs Tech 2 air units. HQ factory, required to build same tier air units and same tier air support factories. Upgradeable."
xnb0202_name = "Air Factory HQ"

-- air factory (support, FAF specific)
znb9502_desc = "Air Factory"
znb9502_help = "Constructs Tech 2 air units. Supporting factory, requires an air HQ factory to build same tier air units. Upgradeable once an air HQ factory is built."
znb9502_name = "Air Factory"

-- naval factory (HQ, FAF specific)
xnb0203_desc = "Naval Factory HQ"
xnb0203_help = "Constructs Tech 2 naval units. HQ factory, required to build same tier naval units and same tier naval support factories. Upgradeable."
xnb0203_name = "Naval Factory HQ"

-- naval factory (support, FAF specific)
znb9503_desc = "Naval Factory"
znb9503_help = "Constructs Tech 2 naval units. Supporting factory, requires a naval HQ factory to build same tier naval units. Upgradeable once a naval HQ factory is built."
znb9503_name = "Naval Factory"

-- Power generator
xnb1201_desc = "Power Generator"
xnb1201_help = "Mid-level power generator. Construct next to other structures for adjacency bonus. Explodes violently when destroyed, this can cause chain reactions."
xnb1201_name = "Antimatter Reactor"

-- mass extractor
xnb1202_desc = "Mass Extractor"
xnb1202_help = "Mid-level Mass extractor. Must be constructed on Mass deposits. Construct structures next to Mass extractor for adjacency bonus."
xnb1202_name = "Mass Extractor"

-- mass fabricator
xnb1104_desc = "Mass Fabricator"
xnb1104_help = "Creates Mass. Requires large amounts of Energy. Construct next to other structures for adjacency bonus. Explodes violently when destroyed, this can cause chain reactions."
xnb1104_name = "Mass Fabricator"

-- point defense
xnb2201_desc = "Point Defense"
xnb2201_help = "Heavily armored defensive tower that attacks land- and sea-based units. Does not engage aircraft or submerged units."
xnb2201_name = "Piercer"

-- aa gun
xnb2202_desc = "Anti-Air Heavy Turret"
xnb2202_help = "Anti-air tower. Designed to engage mid-level aircraft."
xnb2202_name = "Skythorn"

-- torpedo defense
xnb2207_desc = "Heavy Railgun Array"
xnb2207_help = "Anti-naval defense system. Designed to engage all naval units."
xnb2207_name = "Harpoon"

-- TML
xnb2208_desc = "Tactical Missile Launcher"
xnb2208_help = "Tactical missile launcher. Must be ordered to launch its devastating missiles (will not attack automatically)."
xnb2208_name = "Bowcaster"

-- TMD
xnb4204_desc = "Tactical Missile Defense"
xnb4204_help = "Defense against incoming tactical missile. Protection is limited to the structure's operational area."
xnb4204_name = "Arc Aegis"

-- artillery
xnb2303_desc = "Artillery Installation"
xnb2303_help = "Stationary artillery. Designed to engage slow-moving units and fixed structures."
xnb2303_name = "Fire Slinger"

-- radar
xnb3201_desc = "Radar System"
xnb3201_help = "Radar system with moderate range. Detects and tracks surface and air units. Can boost its range for a short time."
xnb3201_name = "Sibyl 2"

-- sonar
xnb3202_desc = "Sonar System"
xnb3202_help = "Sonar system with moderate range. Detects and tracks naval units. Can boost its range for a short time."
xnb3202_name = "Echo 2"

-- stealth field generator
xnb4203_desc = "Stealth Field Generator"
xnb4203_help = "Generates stealth field. Hides units and structures within its operational range. Countered by optical and Omni sensors."
xnb4203_name = "Trickster"

-- shield
xnb4202_desc = "Shield Generator"
xnb4202_help = "Generates a protective shield around units and structures within its radius."
xnb4202_name = "Surge Shield"

-- shield + stealthfield
xnb4205_desc = "Stealth Shield Generator"
xnb4205_help = "Generates a protective shield around units and structures within its radius. The shield emits high energy vortices that scramble radar detection within the shield. Hides units and structures within its operational range from radar. Countered by optical and Omni sensors."
xnb4205_name = "Trickster"

-- air staging facility
xnb5202_desc = "Air Staging Facility"
xnb5202_help = "Refuels and repairs aircraft. Air patrols will automatically use facility."
xnb5202_name = "Oasis"


--------------------------------------------------------
---- T3 UNITS
--------------------------------------------------------

-- Land units

-- T3 engineer
xnl0309_desc = "Engineer"
xnl0309_help = "Tech 3 amphibious construction, repair, capture and reclamation unit."
xnl0309_name = "Engineer"

-- T3 tank
xnl0303_desc = "Heavy Amphibious Tank"
xnl0303_help = "Heavy amphibious tank. Equipped with heavy armor, a rocket launcher and a single siege cannon."
xnl0303_name = "Nova"

-- T3 artillery
xnl0304_desc = "Mobile Heavy artillery"
xnl0304_help = "Attacks targets at great range. Able to fire while moving."
xnl0304_name = "Mauler"

-- T3 orbital fire command
-- xnl0109_desc = "Mobile Orbital Fire Command"
-- xnl0109_help = "Doesn't have direct fire weapons but coordinates attacks from orbit."
-- xnl0109_name = "Spotter"

-- T3 anti air unit
xnl0302_desc = "Mobile Anti-Air Missile Launcher"
xnl0302_help = "Launches anti-air missiles at enemy aircraft."
xnl0302_name = "Watchman"

-- T2 mobile missile defense
xnl0209_desc = "Field Engineer"
xnl0209_help = "Hover unit equipped with engineering capabilities and a tactical missile defense installation. Can only construct offensive and defensive structures."
xnl0209_name = "Scarab"

-- T3 tracked tank
xnl0305_desc = "Armored Assault Tank"
xnl0305_help = "Heavy tank equipped with dual plasma cannons and heavy ablative armor."
xnl0305_name = "Slugger"


-- Air units
-- Spy place
xnl0302_desc = "Spy Plane"
xnl0302_help = "State-of-the-art reconnaissance aircraft."
xnl0302_name = "Beholder"

-- ASF
xna0303_desc = "Air-Superiority Fighter"
xna0303_help = "Fast and agile anti-air fighter. Designed to engage all aircraft."
xna0303_name = "Thunder"

-- Bomber
xna0304_desc = "Heavy Bomber"
xna0304_help = "Drops a very large fiery bomb. Excels at taking out bases, a formation of smaller units and very big targets. Weak against individual targets."
xna0304_name = "Red Rage"

-- Gunship
xna0305_desc = "Heavy Gunship"
xna0305_help = "Equipped with a dual anti-surface cannon, a stingray gun, an anti-air missile launcher. Excels at taking out single units and structures."
xna0305_name = "Hornet"

-- Naval units

-- battleship
-- xns0301_desc = "Battleship"
-- xns0301_help = "Battleship. Has bombardment mode, useful for supressing groups of enemies." -- TODO: finish this description when the unit is implemented
-- xns0301_name = "Battleship"

-- submarine
xns0304_desc = "Tactical Submarine"
xns0304_help = "Equipped with two torpedo launchers and two tactical missile launchers."
xns0304_name = "Leviathan Class"

-- carrier
xns0303_desc = "Aircraft Carrier"
xns0303_help = "Aircraft Carrier"
xns0303_name = "Mastodon Class"

-- battleship
xns0302_desc = "Battleship"
xns0302_help = "Long-range Surface Bombardment Ship. Has two long range plasma cannons, two smaller cannons, AA defense and a submerged railgun."
xns0302_name = "Juggernaut Class"


-- Structures

-- land factory (HQ, FAF specific)
xnb0301_desc = "Land Factory HQ"
xnb0301_help = "Constructs Tech 3 land units. HQ factory, required to build same tier land units and same tier land support factories."
xnb0301_name = "Land Factory HQ"

-- land factory (support, FAF specific)
znb9601_desc = "Land Factory"
znb9601_help = "Constructs Tech 3 land units. Supporting factory, requires a land HQ factory to build same tier land units."
znb9601_name = "Land Factory"

-- air factory (HQ, FAF specific)
xnb0302_desc = "Air Factory HQ"
xnb0302_help = "Constructs Tech 3 air units. HQ factory, required to build same tier air units and same tier air support factories."
xnb0302_name = "Air Factory HQ"

-- air factory (support, FAF specific)
znb9602_desc = "Air Factory"
znb9602_help = "Constructs Tech 3 air units. Supporting factory, requires an air HQ factory to build same tier units."
znb9602_name = "Air Factory"

-- naval factory (HQ, FAF specific)
xnb0303_desc = "Naval Factory HQ"
xnb0303_help = "Constructs Tech 3 naval units. HQ factory, required to build same tier naval units and same tier naval support factories."
xnb0303_name = "Naval Factory HQ"

-- naval factory (support, FAF specific)
znb9603_desc = "Naval Factory"
znb9603_help = "Constructs Tech 3 naval units. Supporting factory, requires a naval HQ factory to build same tier naval units."
znb9603_name = "Naval Factory"

-- T3 SCU factory
xnb0304_desc = "SACU Factory"
xnb0304_help = "Constructs Support Armored Command Units, with custom presets that specialize the role of the units with combinations of enhancements."
xnb0304_name = "Chop Shop"

-- power generator
xnb1301_desc = "Power Generator"
xnb1301_help = "High-end power generator. Construct next to other structures for adjacency bonus. Explodes violently when destroyed, this can cause chain reactions."
xnb1301_name = "Advanced Antimatter Reactor"

-- mass extractor
xnb1302_desc = "Mass Extractor"
xnb1302_help = "High-end Mass extractor. Must be constructed on Mass deposits. Construct structures next to Mass extractor for adjacency bonus."
xnb1302_name = "Mass Extractor"

-- mass fabricator
xnb1303_desc = "Mass Fabricator"
xnb1303_help = "High-end Mass fabricator. Requires large amounts of Energy. Construct next to other structures for adjacency bonus. Explodes violently when destroyed, this can cause chain reactions."
xnb1303_name = "Mass Fabricator"

-- SML
xnb2305_desc = "Strategic Missile Launcher"
xnb2305_help = "Strategic missile launcher. Constructing missiles costs resources. Must be ordered to construct missiles."
xnb2305_name = "Devourer"

-- radar
xnb3301_desc = "Omni Sensor Array"
xnb3301_help = "Radar system with exceptional range. Detects and tracks surface and air units. Also detects stealthed and cloaked units. Can boost its range for a short time."
xnb3301_name = "Sibyl 3"

-- sonar
xnb3302_desc = "Sonar Platform"
xnb3302_help = "Sonar system with exceptional range. Detects and tracks naval units. Can move and boost its range for a short time."
xnb3302_name = "Echo 3"

-- sam
xnb4201_desc = "Anti-Air SAM Launcher"
xnb4201_help = "High-end anti-air tower. Designed to engage all levels of aircraft."
xnb4201_name = "Vindicator"

-- shield
xnb4301_desc = "Heavy Shield Generator"
xnb4301_help = "Generates a heavy shield around units and structures within its radius."
xnb4301_name = "Wave Shield"

-- shield + stealthfield
xnb4305_desc = "Heavy Stealth Shield Generator"
xnb4305_help = "Generates a heavy shield around units and structures within its radius. The shield emits high energy vortices that scramble radar detection within the shield. Hides units and structures within its operational range from radar. Countered by optical and Omni sensors."
xnb4305_name = "Illusionist"

-- SMD
xnb4302_desc = "Strategic Missile Defense"
xnb4302_help = "Intercepts incoming strategic missiles. Protection is limited to the structure's operational area."
xnb4302_name = "Protector"

-- Fire control
xnb4303_desc = "Fire Control"
xnb4303_help = "Fire Control"
xnb4303_name = "Fire Control"

-- T3 'short range' artillery
xnb3303_desc = "Rocket Artillery Installation"
xnb3303_help = "Stationary artillery. Hurls projectiles in a high arc. Designed to engage large groups and structures."
xnb3303_name = "Arbalast"

-- T3 long range heavy artillery
xnb2302_desc = "Heavy Artillery Installation"
xnb2302_help = "Stationary heavy artillery with excellent range, accuracy and damage potential."
xnb2302_name = "Desolator"


--------------------------------------------------------
---- EXPERIMENTALS
--------------------------------------------------------

-- transport
xna0401_desc = "Experimental Air Transport"
xna0401_help = "Experimental transport. High transport capacity with the ability to carry most naval units, as well as the Beamer."
xna0401_name = "Comet"

-- missile tank
xnl0403_desc = "Experimental Missile Tank"
xnl0403_help = "Experimental hover unit designed for long range attacks. Equipped with long range EMP missiles that saturate enemy tactical defenses and suppress armies, as well as short range gatling guns for self defense. Equipped with a nuclear missile silo."
xnl0403_name = "Crawler"

-- beam tank
xnl0402_desc = "Experimental Assault Tank"
xnl0402_help = "Armed with an experimental plasma beam weapon designed to engage any surface units. Is able to be loaded on, and fire from, the experimental transport."
xnl0402_name = "Beamer"

-- experimental tank
xnl0401_desc = "Experimental Heavy Tank"
xnl0401_help = "Hover tank experimental equipped with a large cannon, a gattling cannon, a set of smaller guns and two AA guns. Designed to engage all surface threats."
xnl0401_name = "Bullfrog"

-- planetary defense cannon
xnb2304_desc = "Experimental Planetary Defense Cannon"
xnb2304_help = "Attacks enemy units on and off the planet from a large distance."
xnb2304_name = "Big Bertha"

-- Drop off point
xnb0401_desc = "Experimental Factory"
xnb0401_help = "A place where reinforcements built in orbit are set down."
xnb0401_name = "Dropoff"


--------------------------------------------------------
---- CIVILIANS
--------------------------------------------------------

-- civilian vehcile
xnl9001_desc = "Civilian Truck"
xnl9001_help = "Civilian Truck"
xnl9001_name = "Armadillo"

-- civilian structure 1 with gun
xnb9001_desc = "Nomads Structure with defense gun"
xnb9001_help = "Nomads Structure with defense gun"
xnb9001_name = "NC1001A"

-- civilian structure 1 without gun
xnb9002_desc = "Nomads Structure"
xnb9002_help = "Nomads Structure"
xnl9002_name = "NC1001B"





--------------------------------------------------------
---- TAUNTS
--------------------------------------------------------
Nichols = "Nichols"
NTaunts_MP1_010_010 = '[{i Nichols}]: You will never escape, I will make you suffer!'
NTaunts_MP1_010_011 = '[{i Nichols}]: Your resistance is futile, you will be destroyed!'
NTaunts_MP1_010_012 = '[{i Nichols}]: Orbital strike initiated, goodbye.'
NTaunts_MP1_010_013 = '[{i Nichols}]: We are back. It\'s time for you to die.'
NTaunts_MP1_010_014 = '[{i Nichols}]: Once we were lost, but now we will reign supreme.'
NTaunts_MP1_010_015 = '[{i Nichols}]: You have what we call a very terrestrial mindset.'
NTaunts_MP1_010_016 = '[{i Nichols}]: I think the space between your ears is best left unexplored!'
NTaunts_MP1_010_017 = '[{i Nichols}]: You can\'t hope to contain the vastness of the nomad fleet.'
NTaunts_MP1_010_018 = '[{i Nichols}]: I\'m afraid, we\'re out of mercy today. How would you like an ass kicking instead?'
NTaunts_MP1_010_019 = '[{i Nichols}]: It is amazing that you made it this far without hurting yourself.'

Benson = "Benson"
NTaunts_MP1_011_010 = '[{i Benson}]: Even my ships docking sensors have better aim than your gun.'
NTaunts_MP1_011_011 = '[{i Benson}]: When we came back to the earth empire space we expected an advanced civilization, but you merely progressed beyond bow and arrow.'
NTaunts_MP1_011_012 = '[{i Benson}]: A 5 year old kid would design more sophisticated war machines than those you call \'experimentals\'.'
NTaunts_MP1_011_013 = '[{i Benson}]: You had 1000 years to develop a war machine and THIS is what you\'ve come up with?'
NTaunts_MP1_011_014 = '[{i Benson}]: How many mountainsides have you managed to gate into so far?'
NTaunts_MP1_011_015 = '[{i Benson}]: You really need to leave the air superiority to those who are actually superior.'
NTaunts_MP1_011_016 = '[{i Benson}]: I would encourage you to broaden your horizon - except that you won\'t live to see another one.'
NTaunts_MP1_011_017 = '[{i Benson}]: Your strategy is as primitive as your tech.'
