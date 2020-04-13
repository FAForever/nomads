BuildingTemplates = {

       -- Power Structures
        {
            'T1EnergyProduction',
            'xnb1101',
        },
        {
            'T1HydroCarbon',
            'xnb1102',
        },
        {
            'T2EnergyProduction',
            'xnb1201',
        },
        {
            'T3EnergyProduction',
            'xnb1301',
        },

        -- Mass Structures
        {
            'T1Resource',
            'xnb1103',
        },
        {
            'T1MassCreation',
            'xnb1104',
        },
        {
            'T2Resource',
            'xnb1202',
        },
        {
            'T3Resource',
            'xnb1302',
        },
        {
            'T3MassCreation',
            'xnb1303',
        },
        {
            'T3MassExtraction',
            'xnb1302',
        },

        -- Land Factory Structures
        {
            'T1LandFactory',
            'xnb0101',
        },
        {
            'T2LandFactory',
            'xnb0201',
        },
        {
            'T2SupportLandFactory',
            'znb9501',
        },
        {
            'T3LandFactory',
            'xnb0301',
        },
        {
            'T3SupportLandFactory',
            'znb9601',
        },
        {
            'T3QuantumGate',
            'xnb0304',
        },


        -- Air Factory Structures
        {
            'T1AirFactory',
            'xnb0102',
        },
        {
            'T2AirFactory',
            'xnb0202',
        },
        {
            'T2SupportAirFactory',
            'znb9502',
        },
        {
            'T3AirFactory',
            'xnb0302',
        },
        {
            'T3SupportAirFactory',
            'znb9602',
        },

        -- Sea Factory Structures
        {
            'T1SeaFactory',
            'xnb0103',
        },
        {
            'T2SeaFactory',
            'xnb0203',
        },
        {
            'T2SupportSeaFactory',
            'znb9503',
        },
        {
            'T3SeaFactory',
            'xnb0303',
        },
        {
            'T3SupportSeaFactory',
            'znb9603',
        },

        -- Storage Structures
        {
            'MassStorage',
            'xnb1106',
        },
        {
            'EnergyStorage',
            'xnb1105',
        },

        -- Defense Structures
        -- -Wall
        {
            'Wall',
            'xnb5101',
        },
        -- -Ground Defense
        {
            'T1GroundDefense',
            'xnb2101',
        },
        {
            'T2GroundDefense',
            'xnb2301',
        },

        -- -Air Defense
        {
            'T1AADefense',
            'xnb2102',
        },
        {
            'T2AADefense',
            'xnb2202',
        },
        {
            'T3AADefense',
            'xnb4201',
        },
        -- -Naval Defense
        {
            'T1NavalDefense',
            'xnb2109',
        },
        {
            'T2NavalDefense',
            'xnb2207',
        },
        -- -Shield Defense
        {
            'T2ShieldDefense',
            'xnb4202',
        },
        {
            'T3ShieldDefense',
            'xnb4301',
        },
        -- -Missile Defense
        {
            'T2MissileDefense',
            'xnb4204',
        },

        -- Intelligence Strucutres
        {
            'T1Radar',
            'xnb3101',
        },
        {
            'T2Radar',
            'xnb3201',
        },
        {
            'T3Radar',
            'xnb3301',
        },
        {
            'T2RadarJammer',
            'xnb4202',  -- shield generator, no counter intel structure
        },
        {
            'T1Sonar',
            'xnb3102',
        },
        {
            'T2Sonar',
            'xnb3202',
        },
        {
            'T3Sonar',
            'xnb3302',
        },

        -- Artillery Structures
        {
            'T2Artillery',
            'xnb2303',
        },
        {
            'T3Artillery',
            'xnb2302',
        },

        -- Strategic Missile Structures
        {
            'T2StrategicMissile',
            'xnb2208',
        },
        {
            'T3StrategicMissile',
            'xnb2305',
        },
        {
            'T3StrategicMissileDefense',
            'xnb4302',
        },

        -- Misc Structures
        {
            '1x1Concrete',
            'ueb5204',
        },
        {
            '2x2Concrete',
            'ueb5205',
        },
        {
            'T2AirStagingPlatform',
            'xnb5202',
        },
        --Experimental Structures
        {
            'T4LandExperimental1',
            'xnl0402',
        },
--        {
--            'T4LandExperimental2',
--            'xnl0401',
--        },
        {
            'T4AirExperimental1',
            'xna0401',
        },
        {
            'T4SeaExperimental1',
            'xnl0403',
        },

        -- UEF FA Specific
        {--this doesnt exist for nomads, dunno what it is
            'T2EngineerSupport',
            'xnb1005',
        },
        {
            'T3GroundDefense',
            'xnb3303',
        },
}

RebuildStructuresTemplate = {

        -- factories
        {'xnb0201', 'xnb0101',},
        {'xnb0202', 'xnb0102',},
        {'xnb0203', 'xnb0103',},
        {'xnb0301', 'xnb0101',},
        {'xnb0302', 'xnb0102',},
        {'xnb0303', 'xnb0103',},
        -- extractors
        {'xnb1202', 'xnb1103',},
        -- radar
--        {'xsb3104', 'xsb3101',},
--        {'xsb3201', 'xsb3101',},
}
