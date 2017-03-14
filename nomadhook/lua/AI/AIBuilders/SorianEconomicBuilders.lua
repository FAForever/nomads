BuilderGroup {
    BuilderGroupName = 'SorianSCUUpgrades',
    BuildersType = 'EngineerBuilder',

    -- Nomads
    Builder {
        BuilderName = 'Sorian Nomads CDR Upgrade 1',
        PlatoonTemplate = 'CommanderEnhanceSorian',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3' }},
                { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
                { SBC, 'CmdrHasUpgrade', { 'IntelProbe', false }},
                { SBC, 'CmdrHasUpgrade', { 'IntelProbeAdv', false }},
                { SBC, 'CmdrHasUpgrade', { 'ResourceAllocation', false }},
                { MIBC, 'IsFactionCat', { 'NOMADS', }},
            },
        Priority = 900,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'IntelProbe', },
        },
    },

    Builder {
        BuilderName = 'Sorian Nomads CDR Upgrade 2',
        PlatoonTemplate = 'CommanderEnhanceSorian',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'FACTORY TECH2, FACTORY TECH3' }},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3' }},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH2, ENERGYPRODUCTION TECH3' }},
                { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
                { SBC, 'CmdrHasUpgrade', { 'IntelProbe', true }},
                { SBC, 'CmdrHasUpgrade', { 'IntelProbeAdv', false }},
                { SBC, 'CmdrHasUpgrade', { 'ResourceAllocation', false }},
                { MIBC, 'IsFactionCat', { 'NOMADS', }},
            },
        Priority = 900,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'AdvancedEngineering', 'IntelProbeAdv', },
        },
    },

    Builder {
        BuilderName = 'Sorian Nomads CDR Upgrade 3',
        PlatoonTemplate = 'CommanderEnhanceSorian',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'FACTORY TECH2, FACTORY TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'ENERGYPRODUCTION TECH3'}},
                { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
                { SBC, 'CmdrHasUpgrade', { 'IntelProbeAdv', true }},
                { SBC, 'CmdrHasUpgrade', { 'ResourceAllocation', false }},
                { MIBC, 'IsFactionCat', { 'NOMADS', }},
            },
        Priority = 900,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'AdvancedEngineeringRemove', 'OrbitalBombardment', 'ResourceAllocation', },
        },
    },

}
