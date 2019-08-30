do

-- TODO: make sure all descriptions are up to date
-- TODO: reduce filesize a bit by removing all redundant texts in the LOC tags

Description = table.merged( Description, {

    -- enhancements
    ['xnl0001-aes'] = "<LOC Unit_Description_0005>Expands the number of available schematics and increases the ACU's build speed and maximum health.",
    ['xnl0001-hamc'] = "<LOC NomadsACUEnh_GunUpgrade_Description>Increases main cannon's damage output by several factors. Also increases range of main cannon and overcharge.",
    ['xnl0001-isb'] = "<LOC Unit_Description_0012>Increases ACU's resource generation to 30 mass per second or 3000 energy per second.",
    ['xnl0001-psg'] = "<LOC Unit_Description_0013>Creates a protective shield around the ACU. Requires Energy to run.",
    ['xnl0001-ees'] = "<LOC Unit_Description_0007>Replaces the Tech 2 Engineering Suite. Expands the number of available schematics and further increases the ACU's build speed and maximum health.",
    ['xnl0001-df'] = "<LOC NomadsACUEnh_DisruptiveField_Description>Creates a disruptive field around the ACU that damages all enemy units within range.",
    ['xnl0001-mlg'] = "<LOC NomadsACUEnh_OrbitalStroke_Description>Adds a device that coordinates attacks from orbit on enemy units near the ACU.",
    ['xnl0001-heo'] = "<LOC NomadsACUEnh_OrbitalBombardment_Description>Adds the ability to bombard an area from orbit.",
	['xnl0001-hoa'] = "<LOC NomadsACUEnh_HeavyOrbitalBombardment_Description>Increases the number of missiles in the bombardment, as well as the area.",
    ['xnl0001-fltr'] = "<LOC NomadsACUEnh_FlameThrower_Description>Adds flamethrower",
    ['xnl0001-ed'] = "<LOC NomadsACUEnh_AreaReinforcement_Description>Allows deploying stationary reinforcements launched from orbit anywhere on the battlefield.",
    ['xnl0001-hamc2'] = "<LOC NomadsACUEnh_DoubleGuns_Description>All main gun damage (including overcharge) doubled by installing a second gun barrel next to the main gun.",
    ['xnl0001-se'] = "<LOC NomadsACUEnh_RapidRepair_Description>Increases health and adds a Rapid Repair device to the ACU, repairing the ACU automatically at no cost. There is a delay before repairs start, and the device must reinitialise each time the ACU is damaged or fires a weapon.",
    ['xnl0001-sepa'] = "<LOC NomadsACUEnh_PowerArmor_Description>Greatly increases the max health of the ACU.",
    ['xnl0001-sm'] = "<LOC NomadsACUEnh_SniperMode_Description>Allows the ACU to enable and disable sniper mode at will. Sniper mode increases the range and damage of the ACU's main weapon but disables overcharge. Stacks with the gun enhancements.",
    ['xnl0001-ip'] = "<LOC NomadsACUEnh_IntelProbe_Description>Intel probes are used to reveal any area on the map for a short duration.",
    ['xnl0001-ip2'] = "<LOC NomadsACUEnh_IntelProbeAdv_Description>Upgrades the intel probe enhanced sensors for better intelligence gathering.",
    ['xnl0001-il'] = "<LOC NomadsACUEnh_MovementSpeedIncrease_Description>This enhancement improves the locomotor on the Support Commander so that it can move faster.",
    ['xnl0001-acap'] = "<LOC NomadsACUEnh_Capacitor_Description>Allows the acu to temporarily boost its stats with the capacitor ability for an appropriate energy cost.",

    ['xnl0301-sre'] = "<LOC Unit_Description_0022>Greatly expands the range of the standard onboard SACU sensor systems.",
    ['xnl0301-il'] = "<LOC NomadsSCUEnh_MovementSpeedIncrease_Description>This enhancement improves the locomotor on the Support Commander so that it can move faster.",
    ['xnl0301-ses'] = "<LOC Unit_Description_0121>Speeds up all engineering-related functions.",
    ['xnl0301-se'] = "<LOC NomadsSCUEnh_RapidRepair_Description>Increases health and puts a rapid repair device on the SACU. It repairs the ACU automatically at no cost. There's a delay before the repairs start, the device needs to reinitialise each time the SACU is damaged or fires a weapon.",
    ['xnl0301-sepa'] = "<LOC NomadsSCUEnh_PowerArmor_Description>Upgrades the armor to powered armor, increasing the max health of the SACU.",
    ['xnl0301-rag'] = "<LOC NomadsSCUEnh_LeftArmGun_Description>Enhances the SACU with a kinetic cannon. When the capacitor ability is active the cannon gains a damage-over-time effect.",
    ['xnl0301-rag2'] = "<LOC NomadsSCUEnh_LeftArmGunUpgrade_Description>Upgrades the kinetic cannon so it deals more damage.",
    ['xnl0301-acu'] = "<LOC NomadsSCUEnh_RightArmGun_Description>Enhances the SACU with a rapid fire gattling gun. When the capacitor ability is active the gattling gun deals more damage.",
    ['xnl0301-acu2'] = "<LOC NomadsSCUEnh_RightArmGunUpgrade_Description>Upgrades the gattling cannon so it deals more damage.",
    ['xnl0301-ses'] = "<LOC NomadsSCUEnh_LeftArmEngineering_Description>Enhances the SACU with an additional engineering tool. Also allows the SACU to construct all Nomads structures. When the capacitor ability is active the engineering functions are sped up.",
    ['xnl0301-rae'] = "<LOC NomadsSCUEnh_RightArmEngineering_Description>Enhances the SACU with an additional engineering tool. Also allows the SACU to construct all Nomads structures. When the capacitor ability is active the engineering functions are sped up.",
    ['xnl0301-acap'] = "<LOC NomadsSCUEnh_Capacitor_Description>Allows the SACU to temporarily boost its stats with the capacitor ability for an appropriate energy cost.",
    ['xnl0301-acap2'] = "<LOC NomadsSCUEnh_AddCapacitor_Description>Enhances the SACU with an additional capacitor that increases the duration of the capacitor ability.",
    ['xnl0301-lar'] = "<LOC NomadsSCUEnh_LeftArmRocket_Description>Enhances the SACU with a rocket launcher attached to the left shoulder that fires salvos of rockets against surface targets. When the capacitor ability is active the rockets gain a damage-over-time effect.",
    ['xnl0301-rar'] = "<LOC NomadsSCUEnh_RightArmRocket_Description>Enhances the SACU with a rocket launcher attached to the right shoulder that fires salvos of rockets against surface targets. When the capacitor ability is active the rockets gain a damage-over-time effect.",
    ['xnl0301-larg'] = "<LOC NomadsSCUEnh_LeftArmRailgun_Description>Enhances the SACU with an under water railgun. When the capacitor ability is active the railgun deals more damage per shot.",
    ['xnl0301-isb'] = "<LOC NomadsSCUEnh_ResourceAllocation_Description>Increases the SACU's resource generation to 10 mass per second and 1000 energy per second, which speeds up the capacitor charge time.",


    -- NOMADS COMMANDER UNITS
    ['xnl0001'] = "<LOC xnl0001_help>Armored Commander is a combination of barracks and command center. Contains all the blueprints necessary to build a basic army from scratch. Upgradeable with combat enhancements, advanced engineering suits, resource allocation system, and capacitor.",
    ['xnl0301'] = "<LOC xnl0301_help>Houses a Nomads soldier. Can be Customised as a heavy combatant, improved T3 engineer or combination.",
    ['xnl0301_Amphibious'] = "<LOC xnl0301_amphibious_help>Enhanced during construction with an Underwater Railgun on the left arm, a Gatling Gun on the right arm and an Improved Locomotor.",
    ['xnl0301_AntiNaval'] = "<LOC xnl0301_antinaval_help>Enhanced during construction with an Underwater Railgun on the left arm, an Additional Capacitor on the right arm and an Improved Locomotor.",
    ['xnl0301_Combat'] = "<LOC xnl0301_combat_help>Enhanced during construction with an upgraded main canon on the left arm and close combat machine gun on the right arm.",
    ['xnl0301_Default'] = "<LOC xnl0301_default_help>Enhanced during construction with a Kinetic Cannon on its left arm and an Engineering Matrix on its right arm.",
    ['xnl0301_EnergyRocket'] = "<LOC xnl0301_energyrocket_help>Enhanced during construction with a rocket launcher on both shoulders and a resource generator on the back to improve capacitor fill rate.",
    ['xnl0301_Engineer'] = "<LOC xnl0301_engineer_help>Enhanced during construction with an Engineering Matrix on each arm.",
    ['xnl0301_FastCombat'] = "<LOC xnl0301_fastcombat_help>Enhanced during construction with a Gatling Gun on the right arm, a Rocket Launcher on the left arm, and an Improved Locomotor.",
    ['xnl0301_Gunslinger'] = "<LOC xnl0301_gunslinger_help>Enhanced during construction with an Overclocked Kinetic Cannon on its left arm and an Additional Capacitor on the right arm.",
    ['xnl0301_Trooper'] = "<LOC xnl0301_trooper_help>Enhanced during construction with a simple gun on its left arm.",
    ['xnl0301_HeavyTrooper'] = "<LOC xnl0301_heavytrooper_help>Enhanced during construction with an Overclocked Kinetic Cannon on the left arm, a Gatling Gun on the right arm, and a Rapid Repair system.",
    ['xnl0301_NaturalProducer'] = "<LOC xnl0301_naturalproducer_help>Enhanced during construction with an Engineering Matrix on each arm and a Resource Allocation System.",
    ['xnl0301_Rambo'] = "<LOC xnl0301_rambo_help>Enhanced during construction with an Additional Capacitor on the right arm, an Overclocked Kinetic Cannon on the left arm, and Powered Armor.",
    ['xnl0301_Rocket'] = "<LOC xnl0301_rocket_help>Enhanced during construction with a Rocket Launcher on each arm and an Improved Locomotor.",
    ['xnl0301_Sniper'] = "<LOC xnl0301_sniper_help>Enhanced during construction with an upgraded weapon on its right arm and the sniper enhancement on its back.",
	['xnl0301_RAS'] = "<LOC xnl0301_ras_help>Enhanced during construction with a Resource Allocation System.",


    -- NOMADS ENGINEERS
    ['xnl0105'] = "<LOC xnl0105_help>Tech 1 amphibious construction, repair, capture and reclamation unit.",
    ['xnl0208'] = "<LOC xnl0208_help>Tech 2 amphibious construction, repair, capture and reclamation unit.",
    ['xnl0309'] = "<LOC xnl0309_help>Tech 3 amphibious construction, repair, capture and reclamation unit.",


    -- NOMADS FACTORIES
    ['xnb0101'] = "<LOC xnb0101_help>Constructs Tech 1 land units. Upgradeable.",
    ['xnb0102'] = "<LOC xnb0102_help>Constructs Tech 1 air units. Upgradeable.",
    ['xnb0103'] = "<LOC xnb0103_help>Constructs Tech 1 naval units. Upgradeable.",
    ['xnb0201'] = "<LOC xnb0201_help>Constructs Tech 2 land units. Upgradeable.",
    ['xnb0202'] = "<LOC xnb0202_help>Constructs Tech 2 air units. Upgradeable.",
    ['xnb0203'] = "<LOC xnb0203_help>Constructs Tech 2 naval units. Upgradeable.",
    ['xnb0301'] = "<LOC xnb0301_help>Constructs Tech 3 land units. Highest tech level available.",
    ['xnb0302'] = "<LOC xnb0302_help>Constructs Tech 3 air units. Highest tech level available.",
    ['xnb0303'] = "<LOC xnb0303_help>Constructs Tech 3 naval units. Highest tech level available.",
    ['xnb0304'] = "<LOC xnb0304_help>Constructs Support command units.",

    -- NOMADS SUPPORT FACTORIES (FAF SPECIFIC)
    ['znb9501'] = "<LOC znb9501_help>Constructs Tech 2 land units. Upgradeable.",
    ['znb9502'] = "<LOC znb9502_help>Constructs Tech 2 air units. Upgradeable.",
    ['znb9503'] = "<LOC znb9503_help>Constructs Tech 2 naval units. Upgradeable.",
    ['znb9601'] = "<LOC znb9601_help>Constructs Tech 3 land units. Highest tech level available.",
    ['znb9602'] = "<LOC znb9602_help>Constructs Tech 3 air units. Highest tech level available.",
    ['znb9603'] = "<LOC znb9603_help>Constructs Tech 3 naval units. Highest tech level available.",


    -- WEAPON STRUCTURES
    ['xnb2101'] = "<LOC xnb2101_help>Low-end defensive tower that attacks land- and sea-based units. Does not engage aircraft or submerged units.",
    ['xnb2102'] = "<LOC xnb2102_help>Anti-air tower. Designed to engage low-end aircraft.",
    ['xnb2109'] = "<LOC xnb2109_help>Anti-naval defense system.",
    ['xnb2201'] = "<LOC xnb2201_help>Heavily armored defensive tower that attacks land- and sea-based units. Does not engage aircraft or submerged units.",
    ['xnb2202'] = "<LOC xnb2202_help>Anti-air tower. Designed to engage mid-level aircraft.",
    ['xnb2303'] = "<LOC xnb2303_help>Stationary artillery. Designed to engage slow-moving units and fixed structures.",
    ['xnb2207'] = "<LOC xnb2207_help>Anti-naval defense system. Designed to engage all naval units.",
    ['xnb2208'] = "<LOC xnb2208_help>Tactical missile launcher. Must be ordered to construct missiles.",
    ['xnb4201'] = "<LOC xnb4201_help>High-end anti-air tower. Designed to engage all levels of aircraft.",
    ['xnb3303'] = "<LOC xnb3303_help>Stationary artillery. Designed to engage slow-moving units and fixed structures.",
    ['xnb2302'] = "<LOC xnb2302_help>Stationary heavy artillery with excellent range, accuracy and damage potential. ",
    ['xnb2305'] = "<LOC xnb2305_help>Strategic missile launcher. Constructing missiles costs resources. Must be ordered to construct missiles.",
    ['xnb2304'] = "<LOC xnb2304_help>Coordinates attacks Nomads spacecraft in from high orbit.",


    -- DEFENSE STRUCTURES
    ['xnb4204'] = "<LOC xnb4204_help>Tactical missile defense. Protection is limited to the structure's operational area.",
    ['xnb4202'] = "<LOC xnb4202_help>Generates a protective shield around units and structures within its radius.",
    ['xnb4205'] = "<LOC xnb4205_help>Generates a protective shield and a stealth field around units and structures within its radius. Upgrade of the normal t2 shield generator",
    ['xnb4301'] = "<LOC xnb4301_help>Generates a heavy shield around units and structures within its radius.",
    ['xnb4305'] = "<LOC xnb4205_help>Generates a heavy shield and a stealth field around units and structures within its radius. Upgrade of the normal t3 shield generator",
    ['xnb4302'] = "<LOC xnb4302_help>Strategic missile defense. Protection is limited to the structure's operational area.",


    -- ECONOMIC STRUCTURES
    ['xnb1101'] = "<LOC xnb1101_help>Generates Energy. Construct next to other structures for adjacency bonus.",
    ['XNB1103'] = "<LOC XNB1103_help>Extracts Mass. Must be constructed on Mass deposits. Construct structures next to Mass extractor for adjacency bonus.",
    ['xnb1105'] = "<LOC xnb1105_help>Stores Energy. Construct next to power generators for adjacency bonus.",
    ['xnb1106'] = "<LOC xnb1106_help>Stores Mass. Construct next to extractors or fabricators for adjacency bonus.",
    ['XNB1102'] = "<LOC XNB1102_help>Generates Energy. Must be constructed on hydrocarbon deposits. Construct structures next to Hydrocarbon power plant for adjacency bonus.",
    ['xnb1201'] = "<LOC xnb1201_help>Mid-level power generator. Construct next to other structures for adjacency bonus.",
    ['xnb1202'] = "<LOC xnb1202_help>Mid-level Mass extractor. Must be constructed on Mass deposits. Construct structures next to Mass extractor for adjacency bonus.",
    ['xnb1104'] = "<LOC xnb1104_help>Creates Mass. Requires large amounts of Energy. Construct next to other structures for adjacency bonus.",
    ['xnb1301'] = "<LOC xnb1301_help>High-end power generator. Construct next to other structures for adjacency bonus.",
    ['xnb1302'] = "<LOC xnb1302_help>High-end Mass extractor. Must be constructed on Mass deposits. Construct structures next to Mass extractor for adjacency bonus.",
    ['xnb1303'] = "<LOC xnb1303_help>High-end Mass fabricator. Requires large amounts of Energy. Construct next to other structures for adjacency bonus.",


    -- INTELLIGENCE STRUCTURES
    ['xnb3101'] = "<LOC xnb3101_help>Radar system with minimal range. Detects and tracks surface and air units.",
    ['xnb3102'] = "<LOC xnb3102_help>Sonar system with minimal range. Detects and tracks naval units.",
    ['xnb3201'] = "<LOC xnb3201_help>Radar system with moderate range. Detects and tracks surface and air units.",
    ['xnb3202'] = "<LOC xnb3202_help>Sonar system with moderate range. Detects and tracks naval units.",
    ['xnb3301'] = "<LOC xnb3301_help>Generates stealth field. Hides units and structures within its operational range. Countered by optical and Omni sensors.",
    ['xnb3302'] = "<LOC xnb3302_help>Sonar system with exceptional range. Detects and tracks naval units. Armed with a bottom-mounted torpedo turret.",


    -- MISC
    ['xnb5101'] = "<LOC xnb5101_help>Restricts the movement of enemy units. Offers minimal protection from enemy fire.",
    ['xnb5202'] = "<LOC xnb5202_help>Refuels and repairs aircraft. Air patrols will automatically use facility.",
    ['xnb4303'] = "<LOC xnb4303_help>",


    -- NOMADS LAND UNITS
    ['xnl0101'] = "<LOC xnl0101_help>Fast, lightly armored reconnaissance vehicle. Armed with a light gun and a state-of-the-art sensor suite.",
    ['xnl0106'] = "<LOC xnl0106_help>Lightly armored hover tank. Provides direct-fire support against low-end units.",
    ['xnl0201'] = "<LOC xnl0201_help>Armored medium tank. Armed with a single cannon, useful against lower tier units.",
    ['xnl0103'] = "<LOC xnl0103_help>Mobile anti-air defense and artillery. Effective against low-end enemy air units. Can also target surface units with its rockets.",
    ['xnl0107'] = "<LOC xnl0107_help>Carries a long range cannon that kills almost any lower tier unit with one direct hit. Inaccurate when moving but deadly when still, ideal for ambushes.",

    ['xnl0203'] = "<LOC xnl0203_help>Assault tank, has a high movement speed and fast firing cannons.",
    ['xnl0111'] = "<LOC xnl0111_help>Amphibious missile launcher, fires two low yield tactical missiles. Designed to attack at long range. Can attack surface targes from under water.",
    ['xnl0205'] = "<LOC xnl0205_help>Mobile AA unit. Armed with rocket artillery.",
    ['xnl0202'] = "<LOC xnl0202_help>Heavy tank, good armor and powerful weapons. Additionally, it can pin-point targets for artillery units.",
    ['xnl0300'] = "<LOC xnl0300_help>One of few walking Nomads units. The assault bot is armed with a single cannon, useful against medium tier units.",
    ['xnl0306'] = "<LOC xnl0306_help>Equipped with twin EMP cannons. Can freeze most units. Does not inflict damage.",

    ['xnl0303'] = "<LOC xnl0303_help>Heavy hover tank. Equipped with heavy armor, a rocket launcher and a single siege cannon. Designed to deal with any surface threat. Additionally, it can pin-point targets for artillery units.",
    ['xnl0109'] = "<LOC xnl0109_help>Doesn't have direct fire weapons but coordinates attacks from orbit.",
    ['xnl0304'] = "<LOC xnl0304_help>Attacks targets at great range. Needs to deploy before firing.",
    ['xnl0302'] = "<LOC xnl0302_help>Launches anti-air missiles at enemy aircraft.",
    ['xnl0209'] = "<LOC xnl0209_help>Hover unit equipped with engineering capabilities and a tactical missile defense installation. Can only construct offensive and defensive structures.",
    ['xnl0305'] = "<LOC xnl0305_help>Tracked tank unit that carries dual plasma cannons and very heavy armor.",

    ['xnl0402'] = "<LOC xnl0402_help>Beam Tank",
    ['xnl0403'] = "<LOC xnl0403_help>Experimental Missile Tank",
    ['xnl0401'] = "<LOC xnl0401_help>Experimental Ultraheavy Tank",


    -- NOMADS AIR UNTIS
    ['xna0101'] = "<LOC xna0101_help>Air scout",
    ['xna0102'] = "<LOC xna0102_help>Interceptor",
    ['xna0103'] = "<LOC xna0103_help>Bomber",
    ['xna0107'] = "<LOC xna0107_help>Transport Drone",
    ['xna0105'] = "<LOC xna0105_help>Light Gunship",

    ['xna0202'] = "<LOC xna0202_help>Fighter/Bomber",
    ['xna0203'] = "<LOC xna0203_help>Torpedo Gunship",
    ['xna0104'] = "<LOC xna0104_help>Air Transport",

    ['xna0302'] = "<LOC xna0302_help>Spy Plane",
    ['xna0303'] = "<LOC xna0303_help>Air-Superiority Fighter",
    ['xna0304'] = "<LOC xna0304_help>Strategic Bomber",
    ['xna0305'] = "<LOC xna0305_help>Heavy Gunship",

    ['xna0401'] = "<LOC xna0401_help>Experimental transport unit. Can also transport the Beamer (can fire from transport) and single naval units.",


    -- NOMADS SEA UNITS
    ['xns0203'] = "<LOC xns0203_help>Attack Submarine",
    ['xns0103'] = "<LOC xns0103_help>Frigate",

    ['xns0201'] = "<LOC xns0201_help>Destroyer",
    ['xns0202'] = "<LOC xns0202_help>Cruiser",
    ['xns0102'] = "<LOC xns0102_help>Torpedo Boat",

    ['xns0301'] = "<LOC xns0301_help>Battleship",
    ['xns0304'] = "<LOC xns0304_help>Heavy Attack Submarine",
    ['xns0303'] = "<LOC xns0303_help>Aircraft Carrier. Can store, transport and repair aircraft. Armed with strong missile based anti air.",
    ['xns0302'] = "<LOC xns0302_help>Long-range surface bombardment ship. Armed with direct fire cannons and underwater railguns.",

    -- NOMADS ORBITAL UNITS (probably non-controlable)
    ['xna0001'] = "<LOC xna0001_help>Meteor Dropship",
    ['xno0001'] = "<LOC xno0001_help>Surface Operations Support",
    ['xno2302'] = "<LOC xno2302_help>Orbital Artillery Gun",
    ['xna2101'] = "<LOC xna2101_help>Area reinforcement",
    ['xny0001'] = "<LOC xny0001_help>Commander launches intel probe",

} )

end