-- TODO: make sure this is up to date

local NomadT1Eng = {
    ['L'] = 'inb0101',
    ['A'] = 'inb0102',
    ['S'] = 'inb0103',
    ['E'] = 'inb1102',
    ['X'] = 'inb1108',
    ['P'] = 'inb1101',
    ['H'] = 'inb1107',
    ['Y'] = 'inb1105',
    ['W'] = 'inb5101',
    ['D'] = 'inb2101',
    ['N'] = 'inb2102',
    ['T'] = 'inb2109',
    ['I'] = 'inb3101',
    ['O'] = 'inb3102',
}

local NomadT2Eng = {
    ['E'] = 'inb1201',
    ['P'] = 'inb1202',
    ['D'] = 'inb2201',
    ['N'] = 'inb2202',
    ['F'] = 'inb1103',
    ['T'] = 'inb2207',
    ['R'] = 'inb2303',
    ['M'] = 'inb2208',
    ['K'] = 'inb4204',
    ['V'] = 'inb4202',
    ['C'] = 'inb4203',
    ['I'] = 'inb3201',
    ['O'] = 'inb3202',
    ['G'] = 'inb5202',
}

local NomadT3Eng = {
    ['E'] = 'inb1302',
    ['D'] = 'inb3303',
    ['F'] = 'inb1303',
    ['P'] = 'inb1301',
    ['N'] = 'inb4201',
    ['R'] = 'inb2302',
    ['M'] = 'inb2305',
    ['K'] = 'inb4302',
    ['V'] = 'inb4301',
    ['O'] = 'inb3302',
    ['I'] = 'inb3301',
    ['Q'] = 'inb0304',
}

local NomadT4Eng = {
    ['S'] = 'inu2007',
    ['M'] = 'inu4002',
    ['R'] = 'inu4001',
    ['A'] = 'ina4001',
}

local NomadT1Land = {
    ['E'] = 'inu1001',
    ['S'] = 'inu1002',
    ['O'] = 'inu1007',
    ['T'] = 'inu1004',
    ['R'] = 'inu1008',
    ['N'] = 'inu1006',
}

local NomadT2Land = {
    ['A'] = 'xal0203',
    ['E'] = 'inu1005',
    ['A'] = 'inu2002',
    ['T'] = 'inu2005',
    ['M'] = 'inu2003',
    ['N'] = 'inu2004',
    ['V'] = 'inu3003',
    ['D'] = 'inu3008',
}

local NomadT3Land = {
    ['S'] = 'inu1003',
    ['E'] = 'inu2001',
    ['T'] = 'inu3002',
    ['R'] = 'inu3004',
    ['N'] = 'inu3007',
}

local NomadT1Air = {
    ['E'] = 'inu1001',
    ['S'] = 'ina1001',
    ['F'] = 'ina1002',
    ['O'] = 'ina1003',
    ['G'] = 'ina1004',
    ['T'] = 'ina1005',
}

local NomadT2Air = {
    ['E'] = 'inu1005',
    ['F'] = 'ina2002',
    ['G'] = 'ina2003',
    ['T'] = 'ina2001',
}

local NomadT3Air = {
    ['E'] = 'inu2001',
    ['S'] = 'ina3001',
    ['F'] = 'ina3003',
    ['O'] = 'ina3004',
    ['G'] = 'ina3006',
}

local NomadT1Sea = {
    ['E'] = 'inu1001',
    ['F'] = 'ins1002',
    ['S'] = 'ins1001',
}

local NomadT2Sea = {
    ['E'] = 'inu1005',
    ['O'] = 'ins2003',
    ['C'] = 'ins2002',
    ['D'] = 'ins2001',
}

local NomadT3Sea = {
    ['E'] = 'inu2001',
    ['D'] = 'inu3008',
    ['T'] = 'ins3001',
    ['D'] = 'ins3004',
    ['C'] = 'ins3003',
    ['S'] = 'ins3002',
}

buildModeKeys = table.merged( buildModeKeys, {

    -- ACU
    ['inu0001'] = {
        [1] = NomadT1Eng,
        [2] = NomadT2Eng,
        [3] = NomadT3Eng,
        [4] = NomadT4Eng,
    },

    -- SCU
    ['inu3001'] = {
        [1] = NomadT1Eng,
        [2] = NomadT2Eng,
        [3] = NomadT3Eng,
        [4] = NomadT4Eng,
    },

    -- T1 engineer
    ['inu1001'] = {
        [1] = NomadT1Eng,
    },

    -- T2 engineer
    ['inu1005'] = {
        [1] = NomadT1Eng,
        [2] = NomadT2Eng,
    },

    -- T2 field engineer
    ['inu3008'] = {
        [1] = NomadT1Eng,
        [2] = NomadT2Eng,
    },

    -- T3 engineer
    ['inu2001'] = {
        [1] = NomadT1Eng,
        [2] = NomadT2Eng,
        [3] = NomadT3Eng,
        [4] = NomadT4Eng,
    },

    -- T1 Land Factory
    ['inb0101'] = {
        [1] = NomadT1Land,
        ['U'] = 'inb0201',
    },

    -- T2 Land Factory
    ['inb0201'] = {
        [1] = NomadT1Land,
        [2] = NomadT2Land,
        ['U'] = 'inb0301',
    },

    -- T3 Land Factory
    ['inb0301'] = {
        [1] = NomadT1Land,
        [2] = NomadT2Land,
        [3] = NomadT3Land,
    },

    -- T1 Air Factory
    ['inb0102'] = {
        [1] = NomadT1Air,
        ['U'] = 'inb0202',
    },

    -- T2 Air Factory
    ['inb0202'] = {
        [1] = NomadT1Air,
        [2] = NomadT2Air,
        ['U'] = 'inb0302',
    },

    -- T3 Air Factory
    ['inb0302'] = {
        [1] = NomadT1Air,
        [2] = NomadT2Air,
        [3] = NomadT3Air,
    },

    -- T1 Naval Factory
    ['inb0103'] = {
        [1] = NomadT1Sea,
        ['U'] = 'inb0203',
    },

    -- T2 Naval Factory
    ['inb0203'] = {
        [1] = NomadT1Sea,
        [2] = NomadT2Sea,
        ['U'] = 'inb0303',
    },

    -- T3 Naval Factory
    ['inb0303'] = {
        [1] = NomadT1Sea,
        [2] = NomadT2Sea,
        [3] = NomadT3Sea,
    },

    -- Quantum Gateway
    ['inb0304'] = {
        [3] = {
            ['C'] = 'inu3001_Default',
            ['A'] = 'inu3001_AntiNaval',
            ['O'] = 'inu3001_Combat',
            ['E'] = 'inu3001_Engineer',
            ['R'] = 'inu3001_Rambo',
            ['K'] = 'inu3001_Rocket',
        },
    },

    -- T1 Mass Extractor
    ['inb1102'] = {
        ['U'] = 'inb1202',
    },

    -- T2 Mass Extractor
    ['inb1202'] = {
        ['U'] = 'inb1302',
    },

    -- T1 Radar
    ['inb3101'] = {
        ['U'] = 'inb3201',
    },

    -- T2 Radar
    ['inb3201'] = {
        ['U'] = 'inb3301',
    },

    -- T1 Sonar
    ['inb3102'] = {
        ['U'] = 'inb3202',
    },

    -- T2 Sonar
    ['inb3202'] = {
        ['U'] = 'inb3302',
    },

    -- T2 shield
    ['inb4202'] = {
        ['U'] = 'inb4205',
    },

    -- T3 shield
    ['inb4301'] = {
        ['U'] = 'inb4305',
    },

    -- Aircraft Carrier
    ['ins3003'] = {
        [1] = NomadT1Air,
        [2] = NomadT2Air,
        [3] = NomadT3Air,
    },
})