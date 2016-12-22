# Working example file

FactionList = {
    {
        Key = 'nomads',
        Category = 'NOMAD',
        FactionInUnitBp = 'Nomads',
        DisplayName = "<LOC _NOMAD>Nomad",
        SoundPrefix = 'Nomads',
        InitialUnit = 'INU0001',
        CampaignFileDesignator = 'N',
        TransmissionLogColor = 'ff0000ff',
        Icon = "/widgets/faction-icons-alpha_bmp/nomad_ico.dds",
        VeteranIcon = "/game/veteran-logo_bmp/nomad-veteran_bmp.dds",
        SmallIcon = "/faction_icon-sm/nomad_ico.dds",
        LargeIcon = "/faction_icon-lg/nomad_ico.dds",
        TooltipID = 'lob_nomad',
        DefaultSkin = 'nomad',
        loadingMovie = '/movies/nomad_load.sfd',
        loadingColor = 'FFbadbdb',
        loadingTexture = '/UEF_load.dds',
        IdleEngTextures = {
            T1 = '/icons/units/INU1001_icon.dds',
            T2 = '/icons/units/INU1005_icon.dds',
            T2F = '/icons/units/INU3008_icon.dds',
            T3 = '/icons/units/INU2001_icon.dds',
            SCU = '/icons/units/INU3001_icon.dds',
        },
        IdleFactoryTextures = {
            LAND = {
                '/icons/units/INB0101_icon.dds',
                '/icons/units/INB0201_icon.dds',
                '/icons/units/INB0301_icon.dds',
            },
            AIR = {
                '/icons/units/INB0102_icon.dds',
                '/icons/units/INB0202_icon.dds',
                '/icons/units/INB0302_icon.dds',
            },
            NAVAL = {
                '/icons/units/INB0103_icon.dds',
                '/icons/units/INB0203_icon.dds',
                '/icons/units/INB0303_icon.dds',
            },
        },
        PreBuildUnits = {
            MassExtractors = { 'INB1102', 'INB1102', 'INB1102', 'INB1102', },
            Regular = { 'INB0101', 'INB1101', 'INB1101', 'INB1101', 'INB1101', },
        },

        # AI stuff
        BaseTemplatesFile = '/lua/CustomFactions/NomadsAIFiles/BaseTemplates.lua',
        BuildingTemplatesFile = '/lua/CustomFactions/NomadsAIFiles/BuildingTemplates.lua',
        UpgradeTemplatesFile = '/lua/CustomFactions/NomadsAIFiles/UpgradeTemplates.lua',
        PlatoonTemplateKey = 'Nomad',

        # Used by GAZ_UI. This mod needs to be the version that supports Nomads and other custom factions
        GAZ_UI_Info = {
            BuildingIdPrefixes = { 'inb', },
            TexEnhancementPrefix = {
                char = 'n',
                prefix = '/game/nomad-enhancements/',
            },
            SCUEnhancementPaths = {
                Combat = { 'GunRight', 'GunRightUpgrade', 'GunLeft', 'MovementSpeedIncrease', },
                Engineer = { 'EngineeringLeft', 'ResourceAllocation', 'EngineeringRight', },
            },
        },
    },
}