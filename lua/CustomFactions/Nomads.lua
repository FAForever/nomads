-- Working example file

FactionList = {
    {
        Key = 'nomads',
        Category = 'NOMADS',
        FactionInUnitBp = 'Nomads',
        DisplayName = "<LOC _NOMADS>Nomads",
        SoundPrefix = 'Nomads',
        InitialUnit = 'XNL0001',
        CampaignFileDesignator = 'N',
        TransmissionLogColor = 'ff0000ff',
        Icon = "/widgets/faction-icons-alpha_bmp/nomads_ico.dds",
        VeteranIcon = "/game/veteran-logo_bmp/nomads-veteran_bmp.dds",
        SmallIcon = "/faction_icon-sm/nomads_ico.dds",
        LargeIcon = "/faction_icon-lg/nomads_ico.dds",
        TooltipID = 'lob_nomads',
        DefaultSkin = 'nomads',
        loadingMovie = '/nomads_load.sfd',
        loadingColor = 'FFbadbdb',
        loadingTexture = '/UEF_load.dds',
        IdleEngTextures = {
            T1 = '/icons/units/xnl0105_icon.dds',
            T2 = '/icons/units/xnl0208_icon.dds',
            T2F = '/icons/units/xnl0209_icon.dds',
            T3 = '/icons/units/xnl0309_icon.dds',
            SCU = '/icons/units/xnl0301_icon.dds',
        },
        IdleFactoryTextures = {
            LAND = {
                '/icons/units/xnb0101_icon.dds',
                '/icons/units/xnb0201_icon.dds',
                '/icons/units/xnb0301_icon.dds',
            },
            AIR = {
                '/icons/units/xnb0102_icon.dds',
                '/icons/units/xnb0202_icon.dds',
                '/icons/units/xnb0302_icon.dds',
            },
            NAVAL = {
                '/icons/units/xnb0103_icon.dds',
                '/icons/units/xnb0203_icon.dds',
                '/icons/units/xnb0303_icon.dds',
            },
        },
        PreBuildUnits = {
            MassExtractors = { 'xnb1103', 'xnb1103', 'xnb1103', 'xnb1103', },
            Regular = { 'xnb0101', 'xnb1101', 'xnb1101', 'xnb1101', 'xnb1101', },
        },

        -- AI stuff
        BaseTemplatesFile = '/lua/CustomFactions/NomadsAIFiles/BaseTemplates.lua',
        BuildingTemplatesFile = '/lua/CustomFactions/NomadsAIFiles/BuildingTemplates.lua',
        UpgradeTemplatesFile = '/lua/CustomFactions/NomadsAIFiles/UpgradeTemplates.lua',
        PlatoonTemplateKey = 'Nomads',

        -- Used by GAZ_UI. This mod needs to be the version that supports Nomads and other custom factions
        GAZ_UI_Info = {
            BuildingIdPrefixes = { 'xnb', },
            TexEnhancementPrefix = {
                char = 'n',
                prefix = '/game/nomads-enhancements/',
            },
            SCUEnhancementPaths = {
                Combat = { 'GunRight', 'GunRightUpgrade', 'GunLeft', 'MovementSpeedIncrease', },
                Engineer = { 'EngineeringLeft', 'ResourceAllocation', 'EngineeringRight', },
            },
        },
    },
}