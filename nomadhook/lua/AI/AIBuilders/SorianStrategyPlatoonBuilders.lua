-- Modifying Sorian AI to enhance Nomads ACUs
-- Deleted SCU enhancement builder group because we build pre-enhanced SCUs


BuilderGroup {
    BuilderGroupName = 'SorianACUUpgrades - Rush',
    BuildersType = 'EngineerBuilder',

    -- Nomads
    Builder {
        BuilderName = 'Sorian Nomads CDR Upgrade - Rush - Gun',
        PlatoonTemplate = 'CommanderEnhanceSorian',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'FACTORY' }},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION' }},
                { SBC, 'CmdrHasUpgrade', { 'GunUpgrade', false }},
                { SBC, 'CmdrHasUpgrade', { 'OrbitalBombardment ', false }},
                { MIBC, 'IsFactionCat', { 'NOMAD', }},
            },
        Priority = 0.1,
        ActivePriority = 900,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'GunUpgrade' },
        },
    },

    Builder {
        BuilderName = 'Sorian Nomads CDR Upgrade - Rush - Bombardment',
        PlatoonTemplate = 'CommanderEnhanceSorian',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'FACTORY TECH2, FACTORY TECH3' }},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3' }},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH2, ENERGYPRODUCTION TECH3' }},
                { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
                { SBC, 'CmdrHasUpgrade', { 'GunUpgrade', true }},
                { SBC, 'CmdrHasUpgrade', { 'OrbitalBombardment', false }},
                { MIBC, 'IsFactionCat', { 'NOMAD', }},
            },
        Priority = 0.1,
        ActivePriority = 900,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'OrbitalBombardment', },
        },
    },

    Builder {
        BuilderName = 'Sorian UEF CDR Upgrade - Rush - Power armor',
        PlatoonTemplate = 'CommanderEnhanceSorian',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'FACTORY TECH2, FACTORY TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION TECH3'}},
                { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
                { SBC, 'CmdrHasUpgrade', { 'GunUpgrade', true }},
                { SBC, 'CmdrHasUpgrade', { 'OrbitalBombardment', true }},
                { SBC, 'CmdrHasUpgrade', { 'PowerArmor', false }},
                { MIBC, 'IsFactionCat', { 'NOMAD', }},
            },
        Priority = 0.1,
        ActivePriority = 900,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'RapidRepair', 'DoubleGuns', 'PowerArmor' },
        },
    },


}