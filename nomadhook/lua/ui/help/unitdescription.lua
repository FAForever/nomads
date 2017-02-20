do

-- TODO: make sure all descriptions are up to date
-- TODO: reduce filesize a bit by removing all redundant texts in the LOC tags

Description = table.merged( Description, {

    -- enhancements
    ['inu0001-aes'] = "<LOC Unit_Description_0005>Expands the number of available schematics and increases the ACU's build speed and maximum health.",
    ['inu0001-hamc'] = "<LOC NomadsACUEnh_GunUpgrade_Description>Increases main cannon's damage output by several factors. Also increases range of main cannon and overcharge.",
    ['inu0001-isb'] = "<LOC Unit_Description_0012>Increases ACU's resource generation.",
    ['inu0001-psg'] = "<LOC Unit_Description_0013>Creates a protective shield around the ACU. Requires Energy to run.",
    ['inu0001-ees'] = "<LOC Unit_Description_0007>Replaces the Tech 2 Engineering Suite. Expands the number of available schematics and further increases the ACU's build speed and maximum health.",
    ['inu0001-df'] = "<LOC NomadsACUEnh_DisruptiveField_Description>Creates a disruptive field around the ACU that damages all enemy units within range.",
    ['inu0001-mlg'] = "<LOC NomadsACUEnh_OrbitalStroke_Description>Adds a device that coordinates attacks from orbit on enemy units near the ACU.",
    ['inu0001-heo'] = "<LOC NomadsACUEnh_OrbitalBombardment_Description>Adds the ability to bombard an area from orbit.",
    ['inu0001-fltr'] = "<LOC NomadsACUEnh_FlameThrower_Description>Adds flamethrower",
    ['inu0001-ed'] = "<LOC NomadsACUEnh_AreaReinforcement_Description>Allows deploying stationary reinforcements launched from orbit anywhere on the battlefield.",
    ['inu0001-hamc2'] = "<LOC NomadsACUEnh_DoubleGuns_Description>All main gun damage (including overcharge) doubled by installing a second gun barrel next to the main gun.",
    ['inu0001-se'] = "<LOC NomadsACUEnh_RapidRepair_Description>Increases health and puts a rapid repair device on the ACU. It repairs the ACU automatically at no cost. The device needs to reinitialise each time the ACU is damaged.",
    ['inu0001-sepa'] = "<LOC NomadsACUEnh_PowerArmor_Description>Upgrades the armor to powered armor, increasing the max health of the ACU.",
    ['inu0001-sm'] = "<LOC NomadsACUEnh_SniperMode_Description>Allows the ACU to enable and disable sniper mode at will. Sniper mode increases the range and damage of the ACU's main weapon but disables overcharge. Stacks with the gun enhancements.",
    ['inu0001-ip'] = "<LOC NomadsACUEnh_IntelProbe_Description>Intel probes are used to reveal any area on the map for a short duration.",
    ['inu0001-ip2'] = "<LOC NomadsACUEnh_IntelProbeAdv_Description>Upgrades the intel probe enhanced sensors for better intelligence gathering.",
    ['inu0001-il'] = "<LOC NomadsACUEnh_MovementSpeedIncrease_Description>This enhancement improves the locomotor on the Support Commander so that it can move faster.",
    ['inu0001-acap'] = "<LOC NomadsACUEnh_Capacitor_Description>Allows the acu to temporarily boost its stats with the capacitor ability for an appropriate energy cost.",

    ['inu0301-sre'] = "<LOC Unit_Description_0022>Greatly expands the range of the standard onboard SACU sensor systems.",
    ['inu0301-il'] = "<LOC NomadsSCUEnh_MovementSpeedIncrease_Description>This enhancement improves the locomotor on the Support Commander so that it can move faster.",
    ['inu0301-ses'] = "<LOC Unit_Description_0121>Speeds up all engineering-related functions.",
    ['inu0301-se'] = "<LOC NomadsSCUEnh_RapidRepair_Description>Increases health and puts a rapid repair device on the SACU. It repairs the ACU automatically at no cost. There's a delay before the repairs start, the device needs to reinitialise each time the SACU is damaged or fires a weapon.",
    ['inu0301-sepa'] = "<LOC NomadsSCUEnh_PowerArmor_Description>Upgrades the armor to powered armor, increasing the max health of the SACU.",
    ['inu0301-rag'] = "<LOC NomadsSCUEnh_LeftArmGun_Description>Enhances the SACU with a kinetic cannon. When the capacitor ability is active the cannon gains a damage-over-time effect.",
    ['inu0301-rag2'] = "<LOC NomadsSCUEnh_LeftArmGunUpgrade_Description>Upgrades the kinetic cannon so it deals more damage.",
    ['inu0301-acu'] = "<LOC NomadsSCUEnh_RightArmGun_Description>Enhances the SACU with a rapid fire gattling gun. When the capacitor ability is active the gattling gun deals more damage.",
    ['inu0301-acu2'] = "<LOC NomadsSCUEnh_RightArmGunUpgrade_Description>Upgrades the gattling cannon so it deals more damage.",
    ['inu0301-ses'] = "<LOC NomadsSCUEnh_LeftArmEngineering_Description>Enhances the SACU with an additional engineering tool. Also allows the SACU to construct all Nomads structures. When the capacitor ability is active the engineering functions are sped up.",
    ['inu0301-rae'] = "<LOC NomadsSCUEnh_RightArmEngineering_Description>Enhances the SACU with an additional engineering tool. Also allows the SACU to construct all Nomads structures. When the capacitor ability is active the engineering functions are sped up.",
    ['inu0301-acap'] = "<LOC NomadsSCUEnh_Capacitor_Description>Allows the SACU to temporarily boost its stats with the capacitor ability for an appropriate energy cost.",
    ['inu0301-acap2'] = "<LOC NomadsSCUEnh_AddCapacitor_Description>Enhances the SACU with an additional capacitor that increases the duration of the capacitor ability.",
    ['inu0301-lar'] = "<LOC NomadsSCUEnh_LeftArmRocket_Description>Enhances the SACU with a rocket launcher attached to the left shoulder that fires salvos of rockets against surface targets. When the capacitor ability is active the rockets gain a damage-over-time effect.",
    ['inu0301-rar'] = "<LOC NomadsSCUEnh_RightArmRocket_Description>Enhances the SACU with a rocket launcher attached to the right shoulder that fires salvos of rockets against surface targets. When the capacitor ability is active the rockets gain a damage-over-time effect.",
    ['inu0301-larg'] = "<LOC NomadsSCUEnh_LeftArmRailgun_Description>Enhances the SACU with an under water railgun. When the capacitor ability is active the railgun deals more damage per shot.",
    ['inu0301-isb'] = "<LOC NomadsSCUEnh_ResourceAllocation_Description>Adds a resource generator to the SACU. This system generates some resources, especially power, which speeds up the capacitor charge time. Because of the volatile nature of this generator, a large explosion is generated when the SACU dies. This enhancement is often used for increased firepower via capacitor but also sometimes for kamikaze attacks.",


    -- NOMADS COMMANDER UNITS
    ['inu0001'] = "<LOC inu0001_help>Houses Commander. Combination barracks and command center. Contains all the blueprints necessary to build a basic army from scratch.",
    ['inu0301'] = "<LOC inu0301_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination.",
    ['inu0301_Amphibious'] = "<LOC inu0301_amphibious_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or a combination. Enhanced during construction with a railgun on the left arm, a machine gune on the right arm and an improved locomotor.",
    ['inu0301_AntiNaval'] = "<LOC inu0301_antinaval_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or a combination. Enhanced during construction with a railgun on the left arm, an additional capacitor on the right shoulder and an improved locomotor.",
    ['inu0301_Combat'] = "<LOC inu0301_combat_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with an upgraded main canon on the left arm and close combat machine gun on the right arm.",
    ['inu0301_Default'] = "<LOC inu0301_default_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with a weapon on its left arm and engineering capabilities on its right arm.",
    ['inu0301_EnergyRocket'] = "<LOC inu0301_energyrocket_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with a rocket launcher on both shoulders and a resource generator on the back to improve capacitor fill rate.",
    ['inu0301_Engineer'] = "<LOC inu0301_engineer_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with two engineering arms.",
    ['inu0301_FastCombat'] = "<LOC inu0301_fastcombat_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with a cannon, a machine gun and an improved locomotor.",
    ['inu0301_Gunslinger'] = "<LOC inu0301_gunslinger_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with an upgraded gun on its left arm and an additional capacitor for enhanced firepower.",
    ['inu0301_Trooper'] = "<LOC inu0301_trooper_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with a simple gun on its left arm.",
    ['inu0301_HeavyTrooper'] = "<LOC inu0301_heavytrooper_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with an upgraded gun on the left arm, a machine gun and a rapid repair system.",
    ['inu0301_NaturalProducer'] = "<LOC inu0301_naturalproducer_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with engineering capabilities on both arms and a resource generator on its back.",
    ['inu0301_Rambo'] = "<LOC inu0301_rambo_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with fully upgraded weapons, rapid repair and power armor.",
    ['inu0301_Rocket'] = "<LOC inu0301_rocket_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with a rocket launcher on both shoulders and improved locomotor.",
    ['inu0301_Sniper'] = "<LOC inu0301_sniper_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination. Enhanced during construction with an upgraded weapon on its right arm and the sniper enhancement on its back.",


    -- NOMADS ENGINEERS
    ['inu1001'] = "<LOC inu1001_help>Tech 1 amphibious construction, repair, capture and reclamation unit.",
    ['inu1005'] = "<LOC inu1005_help>Tech 2 amphibious construction, repair, capture and reclamation unit.",
    ['inu2001'] = "<LOC inu2001_help>Tech 3 amphibious construction, repair, capture and reclamation unit.",


    -- NOMADS FACTORIES
    ['inb0101'] = "<LOC inb0101_help>Constructs Tech 1 land units. Upgradeable.",
    ['inb0102'] = "<LOC inb0102_help>Constructs Tech 1 air units. Upgradeable.",
    ['inb0103'] = "<LOC inb0103_help>Constructs Tech 1 naval units. Upgradeable.",
    ['inb0201'] = "<LOC inb0201_help>Constructs Tech 2 land units. Upgradeable.",
    ['inb0202'] = "<LOC inb0202_help>Constructs Tech 2 air units. Upgradeable.",
    ['inb0203'] = "<LOC inb0203_help>Constructs Tech 2 naval units. Upgradeable.",
    ['inb0301'] = "<LOC inb0301_help>Constructs Tech 3 land units. Highest tech level available.",
    ['inb0302'] = "<LOC inb0302_help>Constructs Tech 3 air units. Highest tech level available.",
    ['inb0303'] = "<LOC inb0303_help>Constructs Tech 3 naval units. Highest tech level available.",
    ['inb0304'] = "<LOC inb0304_help>Constructs Support command units.",

    -- NOMADS SUPPORT FACTORIES (FAF SPECIFIC)
    ['inb0211'] = "<LOC inb0211_help>Constructs Tech 2 land units. Upgradeable.",
    ['inb0212'] = "<LOC inb0212_help>Constructs Tech 2 air units. Upgradeable.",
    ['inb0213'] = "<LOC inb0213_help>Constructs Tech 2 naval units. Upgradeable.",
    ['inb0311'] = "<LOC inb0311_help>Constructs Tech 3 land units. Highest tech level available.",
    ['inb0312'] = "<LOC inb0312_help>Constructs Tech 3 air units. Highest tech level available.",
    ['inb0313'] = "<LOC inb0313_help>Constructs Tech 3 naval units. Highest tech level available.",


    -- WEAPON STRUCTURES
    ['inb2101'] = "<LOC inb2101_help>Low-end defensive tower that attacks land- and sea-based units. Does not engage aircraft or submerged units.",
    ['inb2102'] = "<LOC inb2102_help>Anti-air tower. Designed to engage low-end aircraft.",
    ['inb2109'] = "<LOC inb2109_help>Anti-naval defense system.",
    ['inb2201'] = "<LOC inb2201_help>Heavily armored defensive tower that attacks land- and sea-based units. Does not engage aircraft or submerged units.",
    ['inb2202'] = "<LOC inb2202_help>Anti-air tower. Designed to engage mid-level aircraft.",
    ['inb2303'] = "<LOC inb2303_help>Stationary artillery. Designed to engage slow-moving units and fixed structures.",
    ['inb2207'] = "<LOC inb2207_help>Anti-naval defense system. Designed to engage all naval units.",
    ['inb2208'] = "<LOC inb2208_help>Tactical missile launcher. Must be ordered to construct missiles.",
    ['inb4201'] = "<LOC inb4201_help>High-end anti-air tower. Designed to engage all levels of aircraft.",
    ['inb3303'] = "<LOC inb3303_help>Stationary artillery. Designed to engage slow-moving units and fixed structures.",
    ['inb2302'] = "<LOC inb2302_help>Stationary heavy artillery with excellent range, accuracy and damage potential. ",
    ['inb2305'] = "<LOC inb2305_help>Strategic missile launcher. Constructing missiles costs resources. Must be ordered to construct missiles.",
    ['inb2304'] = "<LOC inb2304_help>Coordinates attacks Nomads spacecraft in from high orbit.",


    -- DEFENSE STRUCTURES
    ['inb4204'] = "<LOC inb4204_help>Tactical missile defense. Protection is limited to the structure's operational area.",
    ['inb4202'] = "<LOC inb4202_help>Generates a protective shield around units and structures within its radius.",
    ['inb4205'] = "<LOC inb4205_help>Generates a protective shield and a stealth field around units and structures within its radius. Upgrade of the normal t2 shield generator",
    ['inb4301'] = "<LOC inb4301_help>Generates a heavy shield around units and structures within its radius.",
    ['inb4305'] = "<LOC inb4205_help>Generates a heavy shield and a stealth field around units and structures within its radius. Upgrade of the normal t3 shield generator",
    ['inb4302'] = "<LOC inb4302_help>Strategic missile defense. Protection is limited to the structure's operational area.",


    -- ECONOMIC STRUCTURES
    ['inb1101'] = "<LOC inb1101_help>Generates Energy. Construct next to other structures for adjacency bonus.",
    ['inb1102'] = "<LOC inb1102_help>Extracts Mass. Must be constructed on Mass deposits. Construct structures next to Mass extractor for adjacency bonus.",
    ['inb1105'] = "<LOC inb1105_help>Stores Energy. Construct next to power generators for adjacency bonus.",
    ['inb1106'] = "<LOC inb1106_help>Stores Mass. Construct next to extractors or fabricators for adjacency bonus.",
    ['inb1107'] = "<LOC inb1107_help>Generates Energy. Must be constructed on hydrocarbon deposits. Construct structures next to Hydrocarbon power plant for adjacency bonus.",
    ['inb1201'] = "<LOC inb1201_help>Mid-level power generator. Construct next to other structures for adjacency bonus.",
    ['inb1202'] = "<LOC inb1202_help>Mid-level Mass extractor. Must be constructed on Mass deposits. Construct structures next to Mass extractor for adjacency bonus.",
    ['inb1104'] = "<LOC inb1104_help>Creates Mass. Requires large amounts of Energy. Construct next to other structures for adjacency bonus.",
    ['inb1301'] = "<LOC inb1301_help>High-end power generator. Construct next to other structures for adjacency bonus.",
    ['inb1302'] = "<LOC inb1302_help>High-end Mass extractor. Must be constructed on Mass deposits. Construct structures next to Mass extractor for adjacency bonus.",
    ['inb1303'] = "<LOC inb1303_help>High-end Mass fabricator. Requires large amounts of Energy. Construct next to other structures for adjacency bonus.",


    -- INTELLIGENCE STRUCTURES
    ['inb3101'] = "<LOC inb3101_help>Radar system with minimal range. Detects and tracks surface and air units.",
    ['inb3102'] = "<LOC inb3102_help>Sonar system with minimal range. Detects and tracks naval units.",
    ['inb3201'] = "<LOC inb3201_help>Radar system with moderate range. Detects and tracks surface and air units.",
    ['inb3202'] = "<LOC inb3202_help>Sonar system with moderate range. Detects and tracks naval units.",
    ['inb3301'] = "<LOC inb3301_help>Generates stealth field. Hides units and structures within its operational range. Countered by optical and Omni sensors.",
    ['inb3302'] = "<LOC inb3302_help>Sonar system with exceptional range. Detects and tracks naval units. Armed with a bottom-mounted torpedo turret.",


    -- MISC
    ['inb5101'] = "<LOC inb5101_help>Restricts the movement of enemy units. Offers minimal protection from enemy fire.",
    ['inb5202'] = "<LOC inb5202_help>Refuels and repairs aircraft. Air patrols will automatically use facility.",
    ['inb4303'] = "<LOC inb4303_help>",


    -- NOMADS LAND UNITS
    ['inu1002'] = "<LOC inu1002_help>Fast, lightly armored reconnaissance vehicle. Armed with a light gun and a state-of-the-art sensor suite.",
    ['inu1007'] = "<LOC inu1007_help>Lightly armored hover tank. Provides direct-fire support against low-end units.",
    ['inu1004'] = "<LOC inu1004_help>Armored hover tank. Armed with a single cannon, useful against lower tier units.",
    ['inu1006'] = "<LOC inu1006_help>Mobile anti-air defense and artillery. Effective against low-end enemy air units. Can also target surface units with its rockets.",
    ['inu1008'] = "<LOC inu1008_help>Carries a long range cannon that kills almost any lower tier unit with one direct hit. Inaccurate when moving but deadly when still, ideal for ambushes.",

    ['inu2002'] = "<LOC inu2002_help>Assault tank, has a high movement speed and fast firing cannons.",
    ['inu2003'] = "<LOC inu2003_help>Amphibious missile launcher, fires two low yield tactical missiles. Designed to attack at long range. Can attack surface targes from under water.",
    ['inu2004'] = "<LOC inu2004_help>Mobile AA unit. Armed with rocket artillery.",
    ['inu2005'] = "<LOC inu2005_help>Heavy tank, good armor and powerful weapons. Additionally, it can pin-point targets for artillery units.",
    ['inu3005'] = "<LOC inu3005_help>One of few walking Nomads units. The assault bot is armed with a single cannon, useful against medium tier units.",
    ['inu3003'] = "<LOC inu3003_help>Equipped with twin EMP cannons. Can freeze most units. Does not inflict damage.",

    ['inu3002'] = "<LOC inu3002_help>Heavy hover tank. Equipped with heavy armor, a rocket launcher and a single siege cannon. Designed to deal with any surface threat. Additionally, it can pin-point targets for artillery units.",
    ['inu1003'] = "<LOC inu1003_help>Doesn't have direct fire weapons but coordinates attacks from orbit.",
    ['inu3004'] = "<LOC inu3004_help>Attacks targets at great range. Needs to deploy before firing.",
    ['inu3007'] = "<LOC inu3007_help>Launches anti-air missiles at enemy aircraft.",
    ['inu3008'] = "<LOC inu3008_help>Hover unit equipped with limited engineering capabilities and a tactical missile defense installation. Can only construct offensive and defensive structures.",
    ['inu3009'] = "<LOC inu3009_help>Tracked tank unit that carries dual plasma cannons and very heavy armor.",

    ['inu2007'] = "<LOC inu2007_help>Beam Tank",
    ['inu4001'] = "<LOC inu4001_help>Experimental Missile Tank",
    ['inu4002'] = "<LOC inu4002_help>Experimental Ultraheavy Tank",


    -- NOMADS AIR UNTIS
    ['ina1001'] = "<LOC ina1001_help>Air scout",
    ['ina1002'] = "<LOC ina1002_help>Interceptor",
    ['ina1003'] = "<LOC ina1003_help>Bomber",
    ['ina1005'] = "<LOC ina1005_help>Transport Drone",
    ['ina1004'] = "<LOC ina1004_help>Light Gunship",

    ['ina2002'] = "<LOC ina2002_help>Fighter/Bomber",
    ['ina2003'] = "<LOC ina2003_help>Torpedo Gunship",
    ['ina2001'] = "<LOC ina2001_help>Air Transport",

    ['ina3001'] = "<LOC ina3001_help>Spy Plane",
    ['ina3003'] = "<LOC ina3003_help>Air-Superiority Fighter",
    ['ina3004'] = "<LOC ina3004_help>Strategic Bomber",
    ['ina3006'] = "<LOC ina3006_help>Heavy Gunship",

    ['ina4001'] = "<LOC ina4001_help>Experimental transport unit. Can also transport the Beamer (can fire from transport) and single naval units.",


    -- NOMADS SEA UNITS
    ['ins1001'] = "<LOC ins1001_help>Attack Submarine",
    ['ins1002'] = "<LOC ins1002_help>Frigate",

    ['ins2001'] = "<LOC ins2001_help>Destroyer",
    ['ins2002'] = "<LOC ins2002_help>Cruiser",
    ['ins2003'] = "<LOC ins2003_help>Torpedo Boat",

    ['ins3001'] = "<LOC ins3001_help>Battleship",
    ['ins3002'] = "<LOC ins3002_help>Heavy Attack Submarine",
    ['ins3003'] = "<LOC ins3003_help>Aircraft Carrier. Can store, transport and repair aircraft. Armed with strong missile based anti air.",
    ['ins3004'] = "<LOC ins3004_help>Long-range surface bombardment ship. Armed with direct fire cannons and underwater railguns.",

    -- NOMADS ORBITAL UNITS (probably non-controlable)
    ['ina0001'] = "<LOC ina0001_help>Meteor Dropship",
    ['ino0001'] = "<LOC ino0001_help>Surface Operations Support",
    ['ino2302'] = "<LOC ino2302_help>Orbital Artillery Gun",
    ['ina2101'] = "<LOC ina2101_help>Area reinforcement",
    ['iny0001'] = "<LOC iny0001_help>Commander launches intel probe",

} )

end