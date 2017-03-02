BuildingTemplates = {

       -- Power Structures
        {
            'T1EnergyProduction',
            'inb1101',
        },
        {
            'T1HydroCarbon',
            'inb1107',
        },
        {
            'T2EnergyProduction',
            'inb1201',
        },
        {
            'T3EnergyProduction',
            'inb1301',
        },

        -- Mass Structures
        {
            'T1Resource',
            'inb1102',
        },
        {
            'T1MassCreation',
            'inb1104',
        },
        {
            'T2Resource',
            'inb1202',
        },
        {
            'T3Resource',
            'inb1302',
        },
        {
            'T3MassCreation',
            'inb1303',
        },
        {
            'T3MassExtraction',
            'inb1302',
        },

        -- Land Factory Structures
        {
            'T1LandFactory',
            'inb0101',
        },
        {
            'T2LandFactory',
            'inb0201',
        },
        {
            'T3LandFactory',
            'inb0301',
        },
        {
            'T3QuantumGate',
            'inb0304',
        },


        -- Air Factory Structures
        {
            'T1AirFactory',
            'inb0102',
        },
        {
            'T2AirFactory',
            'inb0202',
        },
        {
            'T3AirFactory',
            'inb0302',
        },

        -- Sea Factory Structures
        {
            'T1SeaFactory',
            'inb0103',
        },
        {
            'T2SeaFactory',
            'inb0203',
        },
        {
            'T3SeaFactory',
            'inb0303',
        },

        -- Storage Structures
        {
            'MassStorage',
            'inb1106',
        },
        {
            'EnergyStorage',
            'inb1105',
        },

        -- Defense Structures
        -- -Wall
        {
            'Wall',
            'inb5101',
        },
        -- -Ground Defense
        {
            'T1GroundDefense',
            'inb2101',
        },
        {
            'T2GroundDefense',
            'inb2201',
        },

        -- -Air Defense
        {
            'T1AADefense',
            'inb2102',
        },
        {
            'T2AADefense',
            'inb2202',
        },
        {
            'T3AADefense',
            'inb4201',
        },
        -- -Naval Defense
        {
            'T1NavalDefense',
            'inb2109',
        },
        {
            'T2NavalDefense',
            'inb2207',
        },
        -- -Shield Defense
        {
            'T2ShieldDefense',
            'inb4202',
        },
        {
            'T3ShieldDefense',
            'inb4301',
        },
        -- -Missile Defense
        {
            'T2MissileDefense',
            'inb4204',
        },

        -- Intelligence Strucutres
        {
            'T1Radar',
            'inb3101',
        },
        {
            'T2Radar',
            'inb3201',
        },
        {
            'T3Radar',
            'inb3301',
        },
        {
            'T2RadarJammer',
            'inb4202',  -- shield generator, no counter intel structure
        },
        {
            'T1Sonar',
            'inb3102',
        },
        {
            'T2Sonar',
            'inb3202',
        },
        {
            'T3Sonar',
            'inb3302',
        },

        -- Artillery Structures
        {
            'T2Artillery',
            'inb2303',
        },
        {
            'T3Artillery',
            'inb2302',
        },

        -- Strategic Missile Structures
        {
            'T2StrategicMissile',
            'inb2208',
        },
        {
            'T3StrategicMissile',
            'inb2305',
        },
        {
            'T3StrategicMissileDefense',
            'inb4302',
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
            'inb5202',
        },
        --Experimental Structures
        {
            'T4LandExperimental1',
            'inu2007',
        },
        {
            'T4LandExperimental2',
            'inu4002',
        },
        {
            'T4AirExperimental1',
            'ina4001',
        },
        {
            'T4SeaExperimental1',
            'inu4001',
        },

        -- UEF FA Specific
        {
            'T2EngineerSupport', 
            'inb1005',
        },
        {
            'T3GroundDefense', 
            'inb3303',
        },
}

RebuildStructuresTemplate = {

        -- factories
        {'inb0201', 'inb0101',},
        {'inb0202', 'inb0102',},
        {'inb0203', 'inb0103',},
        {'inb0301', 'inb0101',},
        {'inb0302', 'inb0102',},
        {'inb0303', 'inb0103',},
        -- extractors
        {'inb1202', 'inb1102',},
        -- radar
--        {'xsb3104', 'xsb3101',},
--        {'xsb3201', 'xsb3101',},
}
