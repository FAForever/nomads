BuffBlueprint {
    Name = 'AnchorModeImmobilize',
    DisplayName = 'AnchorModeImmobilize',
    BuffType = 'ANCHORMODE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Immobilize = {
            DeactivateDelay = 0,
        },
    },
}

BuffBlueprint {
    Name = 'AnchorModeImmobilizeAddRange',
    DisplayName = 'AnchorModeImmobilizeAddRange',
    BuffType = 'ANCHORMODE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Immobilize = {
            DeactivateDelay = 1.5,
        },
        MaxRadius = {
            Mult = 1.3,
        },
        RadarRadius = {
            Mult = 1.3,
        },
        VisionRadius = {
            Mult = 1.3,
        },
    },
}

BuffBlueprint {
    Name = 'CapacitorEngineering',
    DisplayName = 'CapacitorEngineering',
    BuffType = 'CAPACITORBUILDRATE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = 2,
        },
    },
}

BuffBlueprint {
    Name = 'CapacitorIntel',
    DisplayName = 'CapacitorIntel',
    BuffType = 'CAPACITORINTEL',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
--        VisionRadius = {
--            Add = 0,
--            Mult = 1.5,
--        },
--        RadarRadius = {
--            Mult = 4,
--        },		
--        SonarRadius = {
--            Mult = 4,
--        },
        OmniRadius = {
            Mult = 2,
        },
    },
}


BuffBlueprint {
    Name = 'CapacitorRegen',
    DisplayName = 'CapacitorRegen',
    BuffType = 'CAPACITORREGEN',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        Regen = {
            Mult = 2,
        },
    },
}

BuffBlueprint {
    Name = 'CapacitorROF',
    DisplayName = 'CapacitorROF',
    BuffType = 'CAPACITORROF',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        RateOfFire = {
            Mult = 0.34,  -- remember that values below 1 actually boost the rof!
        },
    },
}

BuffBlueprint {
    Name = 'CapacitorROFSCUGatling',
    DisplayName = 'CapacitorROFSCUGatling',
    BuffType = 'CAPACITORROFSCUGAT',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        RateOfFireSpecifiedWeapons2 = {
            Add = 0,
            Mult = 1.66666,  -- remember that values below 1 actually boost the rof!
        },
    },
}

BuffBlueprint {
    Name = 'CapacitorROFSCURailgun',
    DisplayName = 'CapacitorROFSCURailgun',
    BuffType = 'CAPACITORROFSCURG',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        RateOfFireSpecifiedWeapons3 = {
            Add = 0,
            Mult = 0.5,  -- remember that values below 1 actually boost the rof!
        },
    },
}
