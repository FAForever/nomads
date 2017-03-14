

BuilderGroup {
    BuilderGroupName = 'ACUUpgrades',
    BuildersType = 'PlatoonFormBuilder',

    -- Nomads
    Builder {
        BuilderName = 'Nomads CDR Upgrade 1',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'FACTORY TECH2, FACTORY TECH3' }},
                { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3' }},
                { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH2, ENERGYPRODUCTION TECH3' }},
                { EBC, 'GreaterThanEconStorageRatio', { 0.6, 0.6}},
                { MIBC, 'IsFactionCat', { 'NOMADS', }},
            },
        Priority = 0,
        BuilderType = 'Any',
        BuilderData = {
            Enhancement = { 'IntelProbe', 'OrbitalBombardment', 'IntelProbeAdv', },
        },
        PlatoonAddBehaviors = { 'BuildOnceAI' },
    },
    Builder {
        BuilderName = 'Nomads CDR Upgrade 2',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'FACTORY TECH2, FACTORY TECH3'}},
                { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION TECH2, ENERGYPRODUCTION TECH3'}},
                { EBC, 'GreaterThanEconStorageRatio', { 0.6, 0.6}},
                { MIBC, 'IsFactionCat', { 'NOMADS', }},
            },
        Priority = 0,
        BuilderType = 'Any',
        BuilderData = {
            Enhancement = { 'ResourceAllocation', },
        },
        PlatoonAddBehaviors = { 'BuildOnceAI' },
    },

}
