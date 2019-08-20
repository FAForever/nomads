local conditionTbl = {
    ['OSB_Child_NavalAttacks_CarrierPlatoon'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 2, 3, 4, 5 },
                {'default_brain', '2','3','4', '5' }
            },
        },
    },
    ['OSB_Child_NavalAttacks_NukeSubmarinePlatoon'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 2, 3, 5 },
                {'default_brain', '1','2','3','5' }
            },
        },
    },
    ['OSB_Child_NavalAttacks_T3MixedPlatoon1'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 2, 3, 4, 5 },
                {'default_brain', '2','3','4','5' }
            },
        },
    },
    ['OSB_Child_NavalAttacks_T3MixedPlatoon2'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 2, 3, 4, 5 },
                {'default_brain', '2','3','4','5' }
            },
        },
    },
    ['OSB_Child_NavalAttacks_TropBoatPlatoon'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 5 },
                {'default_brain', '1', '5' }
            },
        },
    },
    ['OSB_Child_NavalAttacks_T2UEFPlatoon1'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 5 },
                {'default_brain', '1', '5' }
            },
        },
    },
    ['OSB_Child_NavalAttacks_T2UEFPlatoon2'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 5 },
                {'default_brain', '1', '5' }
            },
        },
    },
    ['OSB_Child_NavalAttacks_T2UEFPlatoon3'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 5 },
                {'default_brain', '1', '5' }
            },
        },
    },
    ['OSB_Child_NavalAttacks_T2UEFPlatoon7'] =  {
        BuildConditions = {
            [2] = {'/lua/editor/miscbuildconditions.lua', 'FactionIndex',
                {'default_brain', 1, 5 },
                {'default_brain', '1', '5' }
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