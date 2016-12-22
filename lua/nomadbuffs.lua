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
            DeactivateDelay = 0,
        },
        MaxRadius = {
            Add = 2,
        },
    },
}

BuffBlueprint {
    Name = 'BombardMode',
    DisplayName = 'BombardMode',
    BuffType = 'BOMBARDMODE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BombardFiringRandomness = {
            Add = 1.25,
            Mult = 1.25,
        },
        BombardMaxRadius = {
            Mult = 1,
        },
        BombardRateOfFire = {
            Mult = 0.666,  # remember that values below 1 actually boost the rof!
        },
    },
}

BuffBlueprint {
    Name = 'BombardModeImmobilize',
    DisplayName = 'BombardModeImmobilize',
    BuffType = 'BOMBARDMODE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        BombardFiringRandomness = {
            Add = 1.25,
            Mult = 1.5,
        },
        BombardMaxRadius = {
            Mult = 1,
        },
        BombardRateOfFire = {
            Mult = 1,
        },
        Immobilize = {
            DeactivateDelay = 4,
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
            Add = 0,
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
        VisionRadius = {
            Add = 0,
            Mult = 1.5,
        },
#        RadarRadius = {
#            Add = 0,
#            Mult = 1.25,
#        },
#        OmniRadius = {
#            Add = 0,
#            Mult = 1.25,
#        },
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
            Add = 0,
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
            Add = 0,
            Mult = 1.2,  # remember that values below 1 actually boost the rof!
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
            Mult = 1.66666,  # remember that values below 1 actually boost the rof!
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
            Mult = 0.5,  # remember that values below 1 actually boost the rof!
        },
    },
}

BuffBlueprint {
    Name = 'IntelOvercharge',
    DisplayName = 'IntelOvercharge',
    BuffType = 'INTELOVERCHARGE',
    Stacks = 'REPLACE',
    Duration = -1,
    Affects = {
        RadarRadius = {
            Mult = 1.5,
        },
        SonarRadius = {
            Mult = 1.5,
        },
    },
}

