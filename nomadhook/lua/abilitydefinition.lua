do

abilities = table.merged( abilities, {

    ShowPosition = {
        UISlot = 1, -- which slot should this order go into.
        script = 'ShowPosition', -- which script to use .. these are in /lua/sim/tasks/
        UIBitmapId = 'repair', -- these are in /game/orders/
        UIHelpText = 'ShowPosition', --this can use the LOC< blah> system if you wish, make sure you enter the data into the correct loc table.
        cursor = 'RULEUCC_Capture', --these are defined in skins.lua

        --important entry... we need this set to false to activate the ability,
        --basicly were saying a unit does not need to be selected to activate the ability script.
        --if this is nil or true then the abilty needs units to be selected to activate.
        --usage types are: Event, Selected or Valid
        usage = 'Event',

        --mouse decal.
        --entering data into this table will show a decal on the mouse WHEN the ability is activated if decal = true.
        --we do not need to specify a full path to the texture IF its a default game decal, however
        --if you want to use your own custom decal you will have to add this to your textures folder in the nomads.scd, 
        --dms will find textures in a mods folder.. so its not a problem for me.. nor you i suspect.
        MouseDecal = {
            decal = true,
            size = 5,
            texture = '/game/AreaTargetDecal/nuke_icon_small.dds',
        },

        --any information contained in this table will be available in the task script.. in commandData
        ExtraInfo = {
            CoolDownTime = 10,
            AbilMinRange = 10,  -- minimum range, 0 means no range limit, def = 0
            AbilMaxRange = 100, -- maximum range, 0 means no range limit, def = 0
        },
    },

-- TODO: active ability decals for most

    LaunchNuke = {
        UIBitmapId = 'nuke',
        cursor = 'SPECABIL_Nuke',
        enabled = true,
        ExtraInfo = {},
        UIHelpText = 'specabil_launch_nuke',
        UISlot = 1,
        script = 'LaunchNuke',
        usage = 'Event',

        UIBehaviorSingleClick = {
            AllowDraging = true,
            AllowMaxSpread = true,
            DragDelta = 0,
            UseSelected = true,
        },
        UIBehaviorDoubleClick = {
            AllowDraging = true,
            AllowMaxSpread = true,
            AllReticulesAtStart = true,
            DragDelta = 2,
            UseSelected = true,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
        GetRangeCheckUnitsFile = '/lua/user/tasks/Tasks.lua',
        MapReticulesToUnitIdsFile = '/lua/user/tasks/Tasks.lua',
        UserProcessFile = '/lua/user/tasks/Tasks.lua',
        UserVerifyFile = '/lua/user/tasks/Tasks.lua',
    },

    LaunchTacMissile = {
        UIBitmapId = 'tactical',
        cursor = 'RULEUCC_Tactical',
        enabled = true,
        ExtraInfo = {
            DoRangeCheck = true,
        },
        UIHelpText = 'specabil_launch_tacmissile',
        UISlot = 2,
        script = 'LaunchTacMissile',
        usage = 'Event',

        UIBehaviorSingleClick = {
            DragDelta = 0,
            UseSelected = true,
        },
        UIBehaviorDoubleClick = {
            AllReticulesAtStart = true,
            DragDelta = 1,
            UseSelected = true,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
        GetRangeCheckUnitsFile = '/lua/user/tasks/Tasks.lua',
        MapReticulesToUnitIdsFile = '/lua/user/tasks/Tasks.lua',
        UserProcessFile = '/lua/user/tasks/Tasks.lua',
        UserVerifyFile = '/lua/user/tasks/Tasks.lua',
    },

    NomadIntelOvercharge = {
        UIBitmapId = 'radar-boost',
        cursor = 'RULEUCC_Script',
        enabled = true,
        ExtraInfo = {
            DoRangeCheck = true,
        },
        UIHelpText = 'specabil_intelovercharge',
        UISlot = 3,
        script = 'NomadIntelOvercharge',
        usage = 'Valid',

        UIBehaviorSingleClick = {
            AllReticulesAtStart = false,
            DragDelta = 0,
            UseSelected = true,
        },
        UIBehaviorDoubleClick = {
            AllowDraging = false,
            AllowMaxSpread = false,
            AllReticulesAtStart = true,
            DragDelta = 1,
            UseSelected = false,
        },
-- TODO: make ActivateImmediately work
--        UIBehaviorSingleClickRight = {
--            ActivateImmediately = true,
--        },

        SoundReady = 'IntelBoostReady',
        SoundLaunched = 'IntelBoostInitiated',

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
        GetRangeCheckUnitsFile = '/lua/user/tasks/Tasks.lua',
-- FIXME: This MapReticulesToUnitIdsFile needs to be finished before it can be used.
        MapReticulesToUnitIdsFile = '/lua/user/tasks/NomadIntelOvercharge.lua',
        UserProcessFile = '/lua/user/tasks/Tasks.lua',
        UserVerifyFile = '/lua/user/tasks/Tasks.lua',
    },

    NomadAreaBombardment = {
        UIBitmapId = 'area-assist',
        cursor = 'RULEUCC_SpecialAction',
        enabled = true,
        ExtraInfo = {
            CoolDownTime = 60,
            DoRangeCheck = true,
            NumReticules = 10,
        },
        UIHelpText = 'specabil_areabombardment',
        UISlot = 5,
        script = 'NomadAreaBombardment',
        usage = 'Event',

        UIBehaviorSingleClick = {
            AllReticulesAtStart = true,
            DragDelta = 1,
            UseSelected = false,
        },
        UIBehaviorDoubleClick = {
            AllReticulesAtStart = true,
            DragDelta = 2,
            UseSelected = false,
        },

        SoundReady = 'OrbitalStrikeReady',
        SoundLaunched = 'OrbitalStrikeLaunched',

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
        GetRangeCheckUnitsFile = '/lua/user/tasks/Tasks.lua',
        MapReticulesToUnitIdsFile = '/lua/user/tasks/Tasks.lua',
        UserProcessFile = '/lua/user/tasks/Tasks.lua',
        UserVerifyFile = '/lua/user/tasks/Tasks.lua',
    },

    NomadIntelProbe = {
        UIBitmapId = 'intelprobe',
        cursor = 'SPECABIL_Eye',
        enabled = true,
        ExtraInfo = {
            ArtillerySupportRadius = 70,
            CoolDownTime = 60,
            DoRangeCheck = false,
            Lifetime = 60,
            Omni = false,
            ProjectileBP = '/projectiles/NIntelProbe1/NIntelProbe1_proj.bp',
            Radar = true,
            Radius = 70,
            Sonar = true,
            Vision = false,
            WaterVision = false,
            UnitBpId = 'iny0001',  -- TODO: embed this in the probe projectile script
        },
        UIHelpText = 'specabil_intelprobe',
        ActiveDecal = {
-- TODO: enable this once decal is done
--            enabled = true,
            enabled = false,
        },
        UISlot = 4,
        script = 'NomadIntelProbe',
        usage = 'Event',

        SoundReady = 'IntelProbeReady',
        SoundLaunched = 'IntelProbeLaunched',

        UIBehaviorSingleClick = {
            AllowDraging = false,
            AllowMaxSpread = false,
            AllReticulesAtStart = false,
            DragDelta = 0,
            ReticuleSizeOverride = 70,
            UseSelected = false,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
        GetRangeCheckUnitsFile = '/lua/user/tasks/Tasks.lua',
        MapReticulesToUnitIdsFile = '/lua/user/tasks/Tasks.lua',
        UserProcessFile = '/lua/user/tasks/Tasks.lua',
        UserVerifyFile = '/lua/user/tasks/Tasks.lua',
    },

    NomadIntelProbeAdvanced = {
        UIBitmapId = 'intelprobe',
        cursor = 'SPECABIL_Eye',
        enabled = true,
        ExtraInfo = {
            ArtillerySupportRadius = 35,
            CoolDownTime = 60,
            DoRangeCheck = false,
            Lifetime = 30,
            ProjectileBP = '/projectiles/NIntelProbe1/NIntelProbe1_proj.bp',
            Omni = true,
            Radar = false,
            Radius = 35,
            Sonar = false,
            Vision = true,
            WaterVision = true,
            UnitBpId = 'iny0001',  -- TODO: embed this in the probe projectile script
        },
        UIHelpText = 'specabil_intelprobe',
        ActiveDecal = {
-- TODO: enable this once decal is done
--            enabled = true,
            enabled = false,
        },
        UISlot = 4,
        script = 'NomadIntelProbeAdvanced',
        usage = 'Event',

-- TODO: Perhaps these sound vars should be in an Audio section to conform to for example units?
        SoundReady = 'IntelProbeReady',
        SoundLaunched = 'IntelProbeLaunched',

        UIBehaviorSingleClick = {
            AllowDraging = false,
            AllowMaxSpread = false,
            AllReticulesAtStart = false,
            DragDelta = 0,
            ReticuleSizeOverride = 35,
            UseSelected = false,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
        GetRangeCheckUnitsFile = '/lua/user/tasks/Tasks.lua',
        MapReticulesToUnitIdsFile = '/lua/user/tasks/Tasks.lua',
        UserProcessFile = '/lua/user/tasks/Tasks.lua',
        UserVerifyFile = '/lua/user/tasks/Tasks.lua',
    },

    TargetLocation = {
        UIBitmapId = 'intelprobe',
        cursor = 'RULEUCC_SpecialAction',
        enabled = true,
        ExtraInfo = {
            DoRangeCheck = false,
            Radius = 45,

            NumReticules = 10,

        },
        UIHelpText = 'specabil_remoteviewing',
        ActiveDecal = {
-- TODO: enable this once decal is done
--            enabled = true,
            enabled = false,
        },
        UISlot = 1,
        script = 'TargetLocation',
        usage = 'Event',

        UIBehaviorSingleClick = {
            AllowDraging = true,
            AllowMaxSpread = true,
            AllReticulesAtStart = true,
            DragDelta = 1,
            UseSelected = true,
        },

        UIBehaviorDoubleClick = {
            AllReticulesAtStart = true,
            DragDelta = 2,
            UseSelected = false,
        },

        GetAllUnitsFile = '/lua/user/tasks/Tasks.lua',
        GetRangeCheckUnitsFile = '/lua/user/tasks/Tasks.lua',
        MapReticulesToUnitIdsFile = '/lua/user/tasks/Tasks.lua',
        UserProcessFile = '/lua/user/tasks/Tasks.lua',
        UserVerifyFile = '/lua/user/tasks/Tasks.lua',
    },
})

end