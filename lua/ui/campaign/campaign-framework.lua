-- stuff for campaigns overviews / briefings / etc, but not missions. Just the UI part in between missions.

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Text = import('/lua/maui/text.lua').Text
local WrapText = import('/lua/maui/text.lua').WrapText
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Edit = import('/lua/maui/edit.lua').Edit
local Button = import('/lua/maui/button.lua').Button
local Group = import('/lua/maui/group.lua').Group
local Scrollbar = import('/lua/maui/scrollbar.lua').Scrollbar
local MenuCommon = import('/lua/ui/menus/menucommon.lua')
local MultiLineText = import('/lua/maui/multilinetext.lua').MultiLineText
local MapPreview = import('/lua/ui/controls/mappreview.lua').MapPreview
local Prefs = import('/lua/user/prefs.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local Combo = import('/lua/ui/controls/combo.lua').Combo
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Movie = import('/lua/maui/movie.lua').Movie
local MapUtil = import('/lua/ui/maputil.lua')

local Campaigns = import('/lua/campaigns.lua')
local CampaignMovies = import('/lua/ui/campaign/campaignmovies.lua')

-- get most up to date faction data
dirty_module('/lua/factions.lua')
local Factions = import('/lua/factions.lua').GetFactions()

local _CampaignInfoCache = false
local _CampaignLayoutCache = false
local GUI = false
local mapErrorDialog = false


-- -------------------------------------------------------------------------------

-- Provides a general purpuse campaign UI.
function CreateDefaultUI()

    local _SelectedMissionInfo = false
    local campaignInfo = GetCampaignInfo()
    local campaignLayout = GetCampaignLayout()
    local currentFaction = Campaigns.GetLastPlayedFaction(campaignInfo.uid) or campaignInfo.factions[1]
    local progress = Campaigns.GetMissionProgress(campaignInfo.uid, currentFaction) or 0
    local curDifficulty = Campaigns.GetDifficulty(campaignInfo.uid) or 2

    -- ---------------------------------------------------------------------------
    --   SETUP
    -- ---------------------------------------------------------------------------

    GUI.parent = Group(GetFrame(0))
    LayoutHelpers.FillParent(GUI.parent, GetFrame(0))
    GUI.parent:DisableHitTest()

    local ambientSounds = PlaySound(Sound({Cue = "AMB_SER_OP_Briefing", Bank = "AmbientTest",}))
    GUI.parent.OnDestroy = function(self)
        StopSound(ambientSounds)
    end

    GUI.background = CreateBackground(GUI.parent)
    GUI.foreground = CreateForeground(GUI.parent)

    GUI.title = UIUtil.CreateText(GUI.parent, campaignLayout.Layout.MissionScreen.Title or campaignInfo.name or 'Unknown campaign', 24)
    LayoutHelpers.AtHorizontalCenterIn(GUI.title, GUI.foreground)
    LayoutHelpers.AtTopIn(GUI.title, GUI.foreground, 36)

    GUI.subTitle = UIUtil.CreateText(GUI.parent, campaignLayout.Layout.MissionScreen.SubTitle or '', 18)
    LayoutHelpers.AtHorizontalCenterIn(GUI.subTitle, GUI.foreground)
    LayoutHelpers.AtTopIn(GUI.subTitle, GUI.foreground, 80)


    -- ---------------------------------------------------------------------------
    --   BUTTONS
    -- ---------------------------------------------------------------------------


    GUI.factionBtn = UIUtil.CreateButtonStd(GUI.parent, '/scx_menu/small-btn/small', "<LOC uicampaign_0012>Other faction", 16, 2)
    GUI.factionBtn.Depth:Set(function() return GUI.parent.Depth() +10 end)
    LayoutHelpers.AtLeftIn(GUI.factionBtn, GUI.foreground, 300)
    LayoutHelpers.AtBottomIn(GUI.factionBtn, GUI.foreground, 32)

    if table.getn( campaignInfo.factions) > 1 then
        GUI.factionBtn.OnClick = function(self)
            GUI.parent:Hide()
            CreateFactionSelectUI(function(newFaction) OnFactionChanged(newFaction) GUI.parent:Show() end)
        end
    else
        GUI.factionBtn:Disable()
    end

    GUI.launchBtn = UIUtil.CreateButtonStd(GUI.parent, '/scx_menu/medium-no-br-btn/medium-uef', "<LOC opbrief_0003>Launch", 20, 2)
    GUI.launchBtn.Depth:Set(function() return GUI.parent.Depth() +10 end)
    LayoutHelpers.AtRightIn(GUI.launchBtn, GUI.foreground, 50)
    LayoutHelpers.AtBottomIn(GUI.launchBtn, GUI.foreground, 32)
    Tooltip.AddButtonTooltip(GUI.launchBtn, 'campaignbriefing_launch')
    GUI.launchBtn.OnClick = function(self)
        if _SelectedMissionInfo then
            StartMission(
               campaignInfo.location .. '/scenario/' .. _SelectedMissionInfo.scenarioFile,
               currentFaction,
               _SelectedMissionInfo.key,
               curDifficulty,
               campaignInfo.UID
            )
            GUI.parent:Destroy()
        end
    end

    GUI.backBtn = UIUtil.CreateButtonStd(GUI.parent, '/scx_menu/small-wide-btn/small', "<LOC tooltipui0282>Exit to main menu", 16, 2)
    GUI.backBtn.Depth:Set(function() return GUI.parent.Depth() +10 end)
    LayoutHelpers.AtLeftIn(GUI.backBtn, GUI.foreground, 50)
    LayoutHelpers.AtBottomIn(GUI.backBtn, GUI.foreground, 32)
    GUI.backBtn.OnClick = function(self)
        GUI.parent:Destroy()
        import('/lua/ui/menus/main.lua').CreateUI()
    end
    import('/lua/ui/uimain.lua').SetEscapeHandler(function() GUI.backBtn.OnClick() end)


    -- ---------------------------------------------------------------------------
    --   MISSION INFO
    -- ---------------------------------------------------------------------------

    GUI.missioninfo = Group(GUI.foreground)
    GUI.missioninfo.Width:Set(550)
    GUI.missioninfo.Height:Set(520)
    LayoutHelpers.AtLeftTopIn(GUI.missioninfo, GUI.foreground, 56, 124)

    GUI.briefingTitle = UIUtil.CreateText(GUI.missioninfo, "", 24)
    LayoutHelpers.AtHorizontalCenterIn(GUI.briefingTitle, GUI.missioninfo)
    LayoutHelpers.AtTopIn(GUI.briefingTitle, GUI.missioninfo, 12)

    GUI.briefingText = UIUtil.CreateTextBox(GUI.missioninfo)
    LayoutHelpers.AtLeftTopIn(GUI.briefingText, GUI.missioninfo, 0, 60)
    LayoutHelpers.AtRightIn(GUI.briefingText, GUI.missioninfo, 0)
    LayoutHelpers.AtBottomIn(GUI.briefingText, GUI.missioninfo, 0)


    -- ---------------------------------------------------------------------------
    --   MISSION LIST
    -- ---------------------------------------------------------------------------

    local numMissionsPerPage = 7

    GUI.missionlist = Group(GUI.foreground)
    GUI.missionlist.Width:Set(250)
    GUI.missionlist.Height:Set(520)

    LayoutHelpers.AtRightTopIn(GUI.missionlist, GUI.foreground, 78, 124)
    UIUtil.CreateVertScrollbarFor(GUI.missionlist)

    GUI.missionlist.controlList = {}
    GUI.missionlist.top = 1

    GUI.missionlist.GetScrollValues = function(self, axis)
        return 1, table.getn(self.controlList), self.top, math.min(self.top + numMissionsPerPage - 1, table.getn(GUI.missionlist.controlList))
    end

    GUI.missionlist.ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta))
    end

    GUI.missionlist.ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta) * numMissionsPerPage)
    end

    GUI.missionlist.ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self.top then return end
        self.top = math.max(math.min(table.getn(self.controlList) - numMissionsPerPage + 1 , top), 1)
        self:CalcVisible()
    end

    GUI.missionlist.IsScrollable = function(self, axis)
        return true
    end

    GUI.missionlist.CalcVisible = function(self)
        local top = self.top
        local bottom = self.top + numMissionsPerPage
        for index, control in ipairs(self.controlList) do
            if index < top or index >= bottom then
                control:Hide()
            else
                control:Show()
                control.Left:Set(self.Left)
                local lIndex = index
                local lControl = control
                control.Top:Set(function() return self.Top() + ((lIndex - top) * lControl.Height()) end)
            end
        end
    end

    GUI.missionlist.Clear = function(self)
        for index, control in self.controlList do
            control:Destroy()
        end
        self.controlList = {}
        self.top = 0
    end

    -- ---------------------------------------------------------------------------
    --   BEHAVIOUR
    -- ---------------------------------------------------------------------------

    function OnselectedMissionChanged(missionInfo)
        _SelectedMissionInfo = missionInfo
        StartMissionBriefing(missionInfo)
    end

    function OnFactionChanged( newFaction)
        if newFaction ~= currentFaction then
            Campaigns.SetLastPlayedFaction(campaignInfo.uid, newFaction)
            currentFaction = newFaction
            ShowFactionMissions()
        end
    end

    local function AddMissionToList(parent, missionNum, missionInfo, isAvailable)
        local text = missionInfo.name or 'unknown ('..repr(missionNum)..')' --LOC("<LOC campaign_00007>Mission") .. ' ' .. repr(missionNum)
        local button = UIUtil.CreateButtonStd(parent, '/scx_menu/small-wide-btn/small', text, 16, 2)

        button.missionNum = missionNum
        button.missionInfo = missionInfo
        button.OnClick = function(self)
            OnselectedMissionChanged(self.missionInfo)
        end

        return button
    end

    function ShowFactionMissions()

        local availableMissions = GetMissionsAvailability()

        local function NewMission(num, MissionInfo)
            local m = AddMissionToList(GUI.missionlist, num, MissionInfo, availableMissions[currentFaction][num])
            table.insert(GUI.missionlist.controlList, m)
            return m
        end

        local spacingBetweenItems = 20
        local c = 0
        GUI.missionlist:Clear()

        for i, MissionInfo in campaignLayout.Missions[currentFaction] do
            if availableMissions[currentFaction][i] then
                local m = NewMission(i, MissionInfo)
--                LayoutHelpers.AtRightTopIn(m, GUI.missionlist, 0, (c * spacingBetweenItems) )
                c = c + 1
            end
        end

        GUI.missionlist.top = math.max( 1, c - numMissionsPerPage + 1)
        GUI.missionlist:CalcVisible()
    end


    function StartMissionBriefing(missionInfo)
        GUI.briefingTitle:SetText(missionInfo.title or missionInfo.name)
        UIUtil.SetTextBoxText(GUI.briefingText, missionInfo.briefing.text)
    end

    -- ---------------------------------------------------------------------------

    if not currentFaction then
        GUI.parent:Hide()
        CreateFactionSelectUI(function(newFaction) OnFactionChanged(newFaction) GUI.parent:Show() end)
    else
        ShowFactionMissions(currentFaction)
        if progress < 1 then
            GUI.missionlist.controlList[1]:OnClick()
        else
            GUI.missionlist.controlList[(progress + 1)]:OnClick()
        end
    end
end

-- -------------------------------------------------------------------------------

function AfterMission( missionInfo)

    LOG('missionInfo = '..repr(missionInfo))

    CreateDefaultUI()
end

-- -------------------------------------------------------------------------------

function CreateFactionSelectUI(callback)

    local campaignInfo = GetCampaignInfo()
    local campaignLayout = GetCampaignLayout()

    -- first find out what factions we can choose (which have missions available)

    local AM = GetMissionsAvailability()
    local AF = {}

    Factions = import('/lua/factions.lua').GetFactions() -- get most recent faction data
    for k, faction in Factions do
        if AM[faction.Key] then
            for num, isAvailable in AM[faction.Key] do
                if isAvailable then
                    table.insert(AF, faction.Key)
                    break
                end
            end
        end
    end

    local NumFactionsAvailable = table.getn(AF)

    -- if only 1 faction can be chosen then don't bother creating an UI, just use that faction
    if NumFactionsAvailable == 1 then
        Campaigns.SetLastPlayedFaction(AF[1])
        callback()
        return

    elseif NumFactionsAvailable == 0 then
        -- if we have no factions available just exit all together and throw error in log
        WARN('*Campaign: No faction with missions available found!')
        import('/lua/ui/menus/main.lua').CreateUI()
        return
    end

    -- create faction select box. It's supposed to be dynamic and auto-sizing so it can fit many factions

    local iconsPerRow = 5
    if math.mod(NumFactionsAvailable, 5) == 0 then
        -- nothing, iconsPerRow is already 5. this is here to make the following 2 statements easier
    elseif math.mod(NumFactionsAvailable, 4) == 0 then
        iconsPerRow = 4
    elseif math.mod(NumFactionsAvailable, 3) == 0 then
        iconsPerRow = 3
    end

    local iconSize = 64
    local width = iconSize * math.max(3, iconsPerRow)
    local height = iconSize * math.ceil(NumFactionsAvailable / iconsPerRow)
    local horzBarWidth = 2 + math.max(0, width - 236)  -- the minus stuff comes from the corner images
    local horzSpacing = math.max( (((width - 236) * -1) / iconsPerRow), 0)
    local vertBarHeight = 2 + math.max(0, height - 64)

    -- background
    local parentBG = Group(GetFrame(0))
    LayoutHelpers.FillParent(parentBG, GetFrame(0))
    parentBG:DisableHitTest()
    local bg = CreateBackground(parentBG, true)
    parentBG.bg = bg.bg or nil
    parentBG.bgfmv = bg.bgfmv or nil

    -- bg
    local center = Bitmap(parentBG, UIUtil.UIFile('/campaign/campaign-framework/faction-select_bg.dds'))
    LayoutHelpers.AtCenterIn(center, parentBG)
    center.Depth:Set(function() return parentBG.Depth() + 1 end)
    center.Width:Set(horzBarWidth)
    center.Height:Set(vertBarHeight)

    -- horz stuff
    local top = Bitmap(center, UIUtil.UIFile('/campaign/campaign-framework/faction-select_top.dds'))
    LayoutHelpers.Above(top, center)
    top.Width:Set(horzBarWidth)
    local bottom = Bitmap(center, UIUtil.UIFile('/campaign/campaign-framework/faction-select_bottom.dds'))
    LayoutHelpers.Below(bottom, center)
    bottom.Width:Set(horzBarWidth)

    -- vert stuff
    local left = Bitmap(center, UIUtil.UIFile('/campaign/campaign-framework/faction-select_left.dds'))
    LayoutHelpers.LeftOf(left, center)
    left.Height:Set(vertBarHeight)
    local right = Bitmap(center, UIUtil.UIFile('/campaign/campaign-framework/faction-select_right.dds'))
    LayoutHelpers.RightOf(right, center)
    right.Height:Set(vertBarHeight)

    -- corners
    local leftTop = Bitmap(top, UIUtil.UIFile('/campaign/campaign-framework/faction-select_left_top.dds'))
    LayoutHelpers.LeftOf(leftTop, top)
    local rightTop = Bitmap(top, UIUtil.UIFile('/campaign/campaign-framework/faction-select_right_top.dds'))
    LayoutHelpers.RightOf(rightTop, top)
    local leftBottom = Bitmap(bottom, UIUtil.UIFile('/campaign/campaign-framework/faction-select_left_bottom.dds'))
    LayoutHelpers.LeftOf(leftBottom, bottom)
    local rightBottom = Bitmap(bottom, UIUtil.UIFile('/campaign/campaign-framework/faction-select_right_bottom.dds'))
    LayoutHelpers.RightOf(rightBottom, bottom)

    -- title
    local title = UIUtil.CreateText(top, "<LOC sel_campaign_0025>Choose your faction", 16)
    LayoutHelpers.AtHorizontalCenterIn(title, top)
    LayoutHelpers.AtTopIn(title, top, 32)

    -- faction icons
    local function CreateFactionIcon(parent, factionName)

        local faction
        for k, details in Factions do
            if details.Key == factionName then
                faction = details
                break
            end
        end

        local icon = Bitmap(parent, UIUtil.UIFile(faction.LargeIcon))
        icon.Depth:Set(function() return parent.Depth() + 1 end)
        icon:SetAlpha(1) -- no see-through please!
        icon.factionName = factionName

        local name = UIUtil.CreateText(icon, faction.DisplayName, 14)
        LayoutHelpers.AtHorizontalCenterIn(name, icon)
        LayoutHelpers.AtTopIn(name, icon, 40)
        name:SetAlpha(0)
        icon.name = name

        icon.HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                icon.name:SetAlpha(1)
            elseif event.Type == 'MouseExit' then
                icon.name:SetAlpha(0)
            elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
                local sound = Sound({Cue = "UI_Mod_Select", Bank = "Interface",})
                PlaySound(sound)
--                Campaigns.SetLastPlayedFaction(campaignInfo.uid, self.factionName)
                parentBG:Destroy()
                callback(self.factionName)
--                CreateDefaultUI()
            end
        end

        return icon
    end

    local factionIcons = {}
    local icon
    local i = 0
    for k, faction in AF do
        icon = CreateFactionIcon(leftTop, faction)
        table.insert(factionIcons, icon)
        LayoutHelpers.AtLeftTopIn(icon, leftTop, 53 + (math.mod(i, iconsPerRow) * iconSize) + (math.mod(i, iconsPerRow) * horzSpacing), 80 + (math.floor(i / iconsPerRow) * iconSize))
        i = i + 1
    end

end

-- -------------------------------------------------------------------------------

function StartMission(ScenName, faction, missionNum, difficulty, campaignUID)
    -- ScenName = /maps/<something>/<something>_scenario.lua
    local scenario = MapUtil.LoadScenario(ScenName)
    if scenario then

        local function TryLaunch()
            local factionToIndex = import('/lua/factions.lua').FactionIndexMap
            LaunchSinglePlayerSession(
                SetupCampaignSession(
                    scenario,
                    difficulty,
                    factionToIndex[faction],
                    {
                        faction = faction,
                        missionNum = missionNum,
                        difficulty = difficulty,
                        campaignUID = campaignUID,
                    },
                    false
                )
            )
        end

        local ok,msg = pcall(TryLaunch)

        if not ok then
            if mapErrorDialog then mapErrorDialog:Destroy() end
            mapErrorDialog = UIUtil.ShowInfoDialog(GetFrame(0), LOC("<LOC opbrief_0000>Error loading map") .. ': ' .. msg, "<LOC _Ok>")
            mapErrorDialog.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
        end

    else
        if mapErrorDialog then mapErrorDialog:Destroy() end
        mapErrorDialog = UIUtil.ShowInfoDialog(GetFrame(0), LOCF("<LOC opbrief_0001>Unknown map: %s", ScenName), "<LOC _Ok>")
        mapErrorDialog.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
    end
end

function CreateBackground(parent, forFactionSelect)
    local campaignLayout = GetCampaignLayout()
    local table = {}
    local screen = "MissionScreen"

    if forFactionSelect then
        screen = "FacionScreen"
    end

    -- Background image
    if campaignLayout.Layout[screen].BackgroundImage then
        local filepath = UIUtil.UIFile(campaignLayout.Layout[screen].BackgroundImage)
        if not DiskGetFileInfo(filepath) then
            filepath = GetFullPath(campaignLayout.Layout[screen].BackgroundImage)
        end
        if DiskGetFileInfo(filepath) then
            table.bg = Bitmap(parent, filepath)
            table.bg.Depth:Set(function() return parent.Depth() - 2 end)
            LayoutHelpers.AtCenterIn(table.bg, parent)
            table.bg.Height:Set(parent.Height)
            table.bg.Width:Set(function()
                local ratio = table.bg.Height() / table.bg.BitmapHeight()
                return table.bg.BitmapWidth() * ratio
            end)
        end
    end

    -- Background movie
    if campaignLayout.Layout[screen].BackgroundMovie then
        table.bgfmv = Movie(parent, '/movies'..campaignLayout.Layout[screen].BackgroundMovie..'.sfd')
        table.bg.Depth:Set(function() return parent.Depth() - 1 end)
        table.bgfmv:Loop(true)
        table.bgfmv:Play()
        LayoutHelpers.FillParent(table.bgfmv, parent)
    end

    return table
end


function CreateForeground(parent)
    local panel = Bitmap(parent, UIUtil.UIFile('/campaign/campaign-framework/bg.dds'))
    LayoutHelpers.AtCenterIn(panel, parent)
    return panel
end


-- call this whenever a mission ends
function MissionFinished(MissionNum, faction, Succesfully)
    if Succesfully then
        local campaignInfo = GetCampaignInfo()
        Campaigns.SetMissionProgress(campaignInfo.uid, faction, MissionNum)
        if campaignInfo.cutscene.after then
            PlayCutscene( GetFullPath(campaignInfo.cutscene.after), true, function() CreateDefaultUI() end)
            return
        end
    end
    CreateDefaultUI()
end


-- gets all available missions, for all factions. Returns a table with this layout: [faction][mission] = available (true/false)
-- so it looks somethign like this:
-- [uef]  => [1] => true
--           [2] => true
--           [3] => false
-- [aeon] => [1] => true
--           [2] => false
--           [3] => false
-- etc
function GetMissionsAvailability()
    local campaignInfo = GetCampaignInfo()
    local campaignLayout = GetCampaignLayout()
    local availableMissions = {}
    local progress

    for faction, missionLayout in campaignLayout.Missions do

        availableMissions[faction] = {}
        local progress = Campaigns.GetMissionProgress(campaignInfo.uid, faction)

        for missionNum, details in missionLayout do

            if missionNum > progress and not details.initiallyEnabled then
                -- set missions not yet available to false
                availableMissions[faction][missionNum] = false
                continue
            end

            availableMissions[faction][missionNum] = true

            if not details.unlocks then
                -- if no unlock data then assume it unlocks next mission
                availableMissions[faction][(missionNum + 1)] = true

            elseif type(details.unlocks) == 'number' then
                availableMissions[faction][details.unlocks] = true

            elseif type(details.unlocks) == 'table' then
                -- looks like we're unlocking multiple missions and/or other factions missions!
                for k, v in details.unlocks do
                    if type(k) == 'string' then
                        -- unlocking other faction mission(s)
                        for l, w in v do
                            availableMissions[k][w] = true
                        end
                    else
                        -- unlocking current faction mission
                        availableMissions[faction][v] = true
                    end
                end
            end
        end
    end

    return availableMissions
end


function PlayCutscene(file, callback)
    if callback then
        callback()
    end
end


function PlayBriefing( MissionNum, callback )
    if callback then
        callback()
    end

end


function PlayVideo(videofile, parent, callback, cue, voice)
    CampaignMovies.PlayCampaignMovie(videofile, parent, callback, cue, voice)
end


function GetMissionInfo(MissionNum, faction)
    local campaignInfo = GetCampaignInfo()
    local missions = GetAllMissionsInfo(faction)
    return missions[MissionNum]
end


function GetAllMissionsInfo(faction)
    local campaignInfo = GetCampaignInfo()
    local missions = import( GetFullPath(campaignInfo.missionfile) ).Missions
    if faction then
        missions = missions[faction]
    end
    return missions
end


function GetCampaignLayout()
    if not _CampaignLayoutCache then
        local r = {}
        local campaignInfo = GetCampaignInfo()
        local filename = GetFullPath(campaignInfo.layoutfile)
        local ok, result = pcall(doscript, filename, r)
        if not ok then
            WARN("Problem loading " .. filename .. ":\n" .. result)
        else
            _CampaignLayoutCache = r
        end
    end
    return _CampaignLayoutCache
end


function GetFullPath( file)
    local campaignInfo = GetCampaignInfo()
    return campaignInfo.location .. '/' .. file
end


function GetCampaignInfo()
    if not _CampaignInfoCache then
        _CampaignInfoCache = Campaigns.GetCampaignInfo(Campaigns.GetLastStartedCampaign())
    end
    return _CampaignInfoCache
end

function SetupCampaignSession(scenario, difficulty, inFaction, campaignInfo, isTutorial)

    if not difficulty then
        error("SetupCampaignSession - difficulty required")
    end
    if not scenario then
        error("SetupCampaignSession - scenario required")
    end
    import('/lua/SinglePlayerLaunch.lua').VerifyScenarioConfiguration(scenario)

    local faction = inFaction or 1
    local sessionInfo = {
        teamInfo = {},
        playerName = ( Prefs.GetFromCurrentProfile('Name') or 'Player' ),
        createReplay = false,
        scenarioInfo = scenario,
    }

    -- session options
    sessionInfo.scenarioInfo.Options = {}
    sessionInfo.scenarioInfo.Options.FogOfWar = 'explored'
    sessionInfo.scenarioInfo.Options.Difficulty = difficulty
    sessionInfo.scenarioInfo.Options.DoNotShareUnitCap = true
    sessionInfo.scenarioInfo.Options.Timeouts = -1
    sessionInfo.scenarioInfo.Options.GameSpeed = 'normal'
    sessionInfo.scenarioInfo.Options.FACampaignFaction = Factions[faction].Key

    -- army stuff
    local armies = sessionInfo.scenarioInfo.Configurations.standard.teams[1].armies
    for index, name in armies do
        sessionInfo.teamInfo[index] = import('/lua/ui/lobby/lobbyComm.lua').GetDefaultPlayerOptions(sessionInfo.playerName)
        if index == 1 then
            sessionInfo.teamInfo[index].PlayerName = sessionInfo.playerName
            sessionInfo.teamInfo[index].Faction = faction
        else
            sessionInfo.teamInfo[index].PlayerName = name
            sessionInfo.teamInfo[index].Human = false
            sessionInfo.teamInfo[index].Faction = 1
        end
        sessionInfo.teamInfo[index].ArmyName = name
    end

    -- Copy campaign flow information for the front end to use when ending the game
    -- or when restoring from a saved game
    if campaignInfo then
LOG('1 campaignInfo = '..repr(campaignInfo))
        sessionInfo.scenarioInfo.campaignInfo = campaignInfo
    end

    if isTutorial and (isTutorial == true) then
        sessionInfo.scenarioInfo.tutorial = true
    end

    Prefs.SetToCurrentProfile('LoadingFaction', faction)

    sessionInfo.scenarioMods = import('/lua/mods.lua').GetCampaignMods(sessionInfo.scenarioInfo)
    LOG('sessioninfo: ', repr(sessionInfo.teamInfo))
    return sessionInfo
end
