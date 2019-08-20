local conditionTbl = {
    ['OSB_Child_AirAttacks_T3HeavyGunships'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 2, 3, 5 },
                {'default_brain','1', '2', '3', '5'}
            },
        },
    },
    ['OSB_Child_AirAttacks_T2SeraphimPlatoon1'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain',4, 5 },
                {'default_brain', '4','5' }
            },
        },
        ChildrenType = { 'Gunships', 'CombatFighters', },
    },
    ['OSB_Child_AirAttacks_T2SeraphimPlatoon2'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 4, 5 },
                {'default_brain', '4','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2SeraphimPlatoon3'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 4, 5 },
                {'default_brain', '4','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2UEFPlatoon1'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 5 },
                {'default_brain', '1','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2UEFPlatoon2'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 5 },
                {'default_brain', '1','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2UEFPlatoon3'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 5 },
                {'default_brain', '1','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2AeonPlatoon1'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 2, 5 },
                {'default_brain', '2','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2AeonPlatoon2'] =  {
        PlatoonTemplate = 'OST_AirAttacks_T2AeonPlatoon2',
        Priority = 696,
        InstanceCount = 3,
        LocationType = 'MAIN',
        PlatoonType = 'Air',
        RequiresConstruction = true,
        PlatoonAIFunction = {'/lua/ScenarioPlatoonAI.lua', 'DefaultOSBasePatrol',
            {'default_platoon'},
            {'default_platoon'}
        },
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 2, 5 },
                {'default_brain', '2','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2AeonPlatoon3'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 2, 5 },
                {'default_brain', '2','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T1CybranPlatoon1'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 3, 5 },
                {'default_brain', '3','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T1CybranPlatoon2'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 3, 5 },
                {'default_brain', '3','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T1CybranPlatoon3'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 3, 5 },
                {'default_brain', '3','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T1CybranPlatoon4'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 3, 5 },
                {'default_brain', '3','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2CybranPlatoon1'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 3, 5 },
                {'default_brain', '3','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2CybranPlatoon2'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 3, 5 },
                {'default_brain', '3','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T2CybranPlatoon3'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 3, 5 },
                {'default_brain', '3','5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T3HeavyGunshipPlatoon3'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 2, 3, 5 },
                {'default_brain', '1', '2', '3', '5' }
            },
        },
    },
    ['OSB_Child_AirAttacks_T3HeavyGunshipPlatoon4'] =  {
        BuildConditions = {
            [3] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 2, 3, 5 },
                {'default_brain', '1', '2','3', '5' }
            },
        },
    },
}

for name, builder in Scenario.Armies['ARMY_1'].PlatoonBuilders.Builders do
    if conditionTbl[name] then
        for i, condition in conditionTbl[name].BuildConditions do
            builder.BuildConditions[i] = condition
        end
    end
end