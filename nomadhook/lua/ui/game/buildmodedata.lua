-- TODO: make sure this is up to date

local NomadsT1Eng = {
    ['L'] = 'xnb0101',
    ['A'] = 'xnb0102',
    ['S'] = 'xnb0103',
    ['E'] = 'xnb1103',
    ['X'] = 'xnb1106',
    ['P'] = 'xnb1101',
    ['H'] = 'XNB1102',
    ['Y'] = 'xnb1105',
    ['W'] = 'xnb5101',
    ['D'] = 'xnb2101',
    ['N'] = 'xnb2102',
    ['T'] = 'xnb2109',
    ['I'] = 'xnb3101',
    ['O'] = 'xnb3102',
}

local NomadsT2Eng = {
    ['E'] = 'xnb1201',
    ['P'] = 'xnb1202',
    ['D'] = 'xnb2201',
    ['N'] = 'xnb2202',
    ['F'] = 'xnb1104',
    ['T'] = 'xnb2207',
    ['R'] = 'xnb2303',
    ['M'] = 'xnb2208',
    ['K'] = 'xnb4204',
    ['V'] = 'xnb4202',
    ['C'] = 'xnb4203',
    ['I'] = 'xnb3201',
    ['O'] = 'xnb3202',
    ['G'] = 'xnb5202',
}

local NomadsT3Eng = {
    ['E'] = 'xnb1302',
    ['D'] = 'xnb3303',
    ['F'] = 'xnb1303',
    ['P'] = 'xnb1301',
    ['N'] = 'xnb4201',
    ['R'] = 'xnb2302',
    ['M'] = 'xnb2305',
    ['K'] = 'xnb4302',
    ['V'] = 'xnb4301',
    ['O'] = 'xnb3302',
    ['I'] = 'xnb3301',
    ['Q'] = 'xnb0304',
}

local NomadsT4Eng = {
    ['S'] = 'xnl0402',
    ['M'] = 'xnl0401',
    ['R'] = 'xnl0403',
    ['A'] = 'xna0401',
}

local NomadsT1Land = {
    ['E'] = 'xnl0105',
    ['S'] = 'xnl0101',
    ['O'] = 'xnl0106',
    ['T'] = 'xnl0201',
    ['R'] = 'xnl0107',
    ['N'] = 'xnl0103',
}

local NomadsT2Land = {
    ['A'] = 'xal0203',
    ['E'] = 'xnl0208',
    ['A'] = 'xnl0203',
    ['T'] = 'xnl0202',
    ['M'] = 'xnl0111',
    ['N'] = 'xnl0205',
    ['V'] = 'xnl0306',
    ['D'] = 'xnl0209',
}

local NomadsT3Land = {
    ['S'] = 'xnl0109',
    ['E'] = 'xnl0309',
    ['T'] = 'xnl0303',
    ['R'] = 'xnl0304',
    ['N'] = 'xnl0302',
}

local NomadsT1Air = {
    ['E'] = 'xnl0105',
    ['S'] = 'xna0101',
    ['F'] = 'xna0102',
    ['O'] = 'xna0103',
    ['G'] = 'xna0105',
    ['T'] = 'xna0107',
}

local NomadsT2Air = {
    ['E'] = 'xnl0208',
    ['F'] = 'xna0202',
    ['G'] = 'xna0203',
    ['T'] = 'xna0104',
}

local NomadsT3Air = {
    ['E'] = 'xnl0309',
    ['S'] = 'xna0302',
    ['F'] = 'xna0303',
    ['O'] = 'xna0304',
    ['G'] = 'xna0305',
}

local NomadsT1Sea = {
    ['E'] = 'xnl0105',
    ['F'] = 'xns0103',
    ['S'] = 'xns0203',
}

local NomadsT2Sea = {
    ['E'] = 'xnl0208',
    ['O'] = 'xns0102',
    ['C'] = 'xns0202',
    ['D'] = 'xns0201',
}

local NomadsT3Sea = {
    ['E'] = 'xnl0309',
    ['D'] = 'xnl0209',
    ['T'] = 'xns0301',
    ['D'] = 'xns0302',
    ['C'] = 'xns0303',
    ['S'] = 'xns0304',
}

buildModeKeys = table.merged( buildModeKeys, {

    -- ACU
    ['xnl0001'] = {
        [1] = NomadsT1Eng,
        [2] = NomadsT2Eng,
        [3] = NomadsT3Eng,
        [4] = NomadsT4Eng,
    },

    -- SCU
    ['xnl0301'] = {
        [1] = NomadsT1Eng,
        [2] = NomadsT2Eng,
        [3] = NomadsT3Eng,
        [4] = NomadsT4Eng,
    },

    -- T1 engineer
    ['xnl0105'] = {
        [1] = NomadsT1Eng,
    },

    -- T2 engineer
    ['xnl0208'] = {
        [1] = NomadsT1Eng,
        [2] = NomadsT2Eng,
    },

    -- T2 field engineer
    ['xnl0209'] = {
        [1] = NomadsT1Eng,
        [2] = NomadsT2Eng,
    },

    -- T3 engineer
    ['xnl0309'] = {
        [1] = NomadsT1Eng,
        [2] = NomadsT2Eng,
        [3] = NomadsT3Eng,
        [4] = NomadsT4Eng,
    },

    -- T1 Land Factory
    ['xnb0101'] = {
        [1] = NomadsT1Land,
        ['U'] = 'xnb0201',
    },

    -- T2 Land Factory
    ['xnb0201'] = {
        [1] = NomadsT1Land,
        [2] = NomadsT2Land,
        ['U'] = 'xnb0301',
    },

    -- T3 Land Factory
    ['xnb0301'] = {
        [1] = NomadsT1Land,
        [2] = NomadsT2Land,
        [3] = NomadsT3Land,
    },

    -- T1 Air Factory
    ['xnb0102'] = {
        [1] = NomadsT1Air,
        ['U'] = 'xnb0202',
    },

    -- T2 Air Factory
    ['xnb0202'] = {
        [1] = NomadsT1Air,
        [2] = NomadsT2Air,
        ['U'] = 'xnb0302',
    },

    -- T3 Air Factory
    ['xnb0302'] = {
        [1] = NomadsT1Air,
        [2] = NomadsT2Air,
        [3] = NomadsT3Air,
    },

    -- T1 Naval Factory
    ['xnb0103'] = {
        [1] = NomadsT1Sea,
        ['U'] = 'xnb0203',
    },

    -- T2 Naval Factory
    ['xnb0203'] = {
        [1] = NomadsT1Sea,
        [2] = NomadsT2Sea,
        ['U'] = 'xnb0303',
    },

    -- T3 Naval Factory
    ['xnb0303'] = {
        [1] = NomadsT1Sea,
        [2] = NomadsT2Sea,
        [3] = NomadsT3Sea,
    },

    -- Quantum Gateway
    ['xnb0304'] = {
        [3] = {
            ['C'] = 'xnl0301_Default',
            ['A'] = 'xnl0301_AntiNaval',
            ['O'] = 'xnl0301_Combat',
            ['E'] = 'xnl0301_Engineer',
            ['R'] = 'xnl0301_Rambo',
            ['K'] = 'xnl0301_Rocket',
        },
    },

    -- T1 Mass Extractor
    ['xnb1103'] = {
        ['U'] = 'xnb1202',
    },

    -- T2 Mass Extractor
    ['xnb1202'] = {
        ['U'] = 'xnb1302',
    },

    -- T1 Radar
    ['xnb3101'] = {
        ['U'] = 'xnb3201',
    },

    -- T2 Radar
    ['xnb3201'] = {
        ['U'] = 'xnb3301',
    },

    -- T1 Sonar
    ['xnb3102'] = {
        ['U'] = 'xnb3202',
    },

    -- T2 Sonar
    ['xnb3202'] = {
        ['U'] = 'xnb3302',
    },

    -- T2 shield
    ['xnb4202'] = {
        ['U'] = 'xnb4205',
    },

    -- T3 shield
    ['xnb4301'] = {
        ['U'] = 'xnb4305',
    },

    -- Aircraft Carrier
    ['xns0303'] = {
        [1] = NomadsT1Air,
        [2] = NomadsT2Air,
        [3] = NomadsT3Air,
    },
})