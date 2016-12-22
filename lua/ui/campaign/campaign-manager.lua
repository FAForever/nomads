local Campaigns = import('/lua/campaigns.lua')

function AfterCampaignMission( missionInfo)

    # TODO: put the campaign UID in missionInfo and use that below. For some reason the campaign UID doesn't
    #       get passed all the way to here so for now using the profile variable work-around.

#    local campaignUID = missionInfo.campaignUID
    local campaignUID = Campaigns.GetLastStartedCampaign()

    if not campaignUID then
        WARN('AfterCampaignMission - Missing campaign UID. Going back to main menu. missionInfo = '..repr(missionInfo))
        import('/lua/ui/menus/main.lua').CreateUI()

    else
        local campaignInfo = Campaigns.GetCampaignInfo(campaignUID)
        import(campaignInfo.location ..'/'.. (campaignInfo.initfile or 'Init.lua')).AfterMission(missionInfo)
    end
end