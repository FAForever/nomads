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

local Campaigns = import('/lua/campaigns.lua')
--local OpenUrlDialog = import('/lua/ui/dialogs/openurldialog.lua').OpenUrlDialog

-- get most up to date faction data
dirty_module('/lua/factions.lua')
local Factions = import('/lua/factions.lua').GetFactions()


function CreateUI(parent, exitBehavior)


    local selectedCmpgn = false
    local allCampaigns = {}

    -- -------------------------------------------------------------------------------------------
    -- SETUP
    -- -------------------------------------------------------------------------------------------

    local panel = Bitmap(parent, UIUtil.SkinnableFile('/campaign/campaign-overview/bg.dds'))
    LayoutHelpers.AtCenterIn(panel, parent)

    panel.brackets = UIUtil.CreateDialogBrackets(panel, 18, 18, 20, 15)

    local title = UIUtil.CreateText(panel, "<LOC uicampaign_0001>Campaigns", 24)
    LayoutHelpers.AtHorizontalCenterIn(title, panel)
    LayoutHelpers.AtTopIn(title, panel, 37)

    -- -------------------------------------------------------------------------------------------
    -- CHECKBOXES
    -- -------------------------------------------------------------------------------------------

    -- default campaigns
    local ChkDefCmpgn = Checkbox(panel,
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_up.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_up.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_over.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_over.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_dis.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_dis.dds'))
    LayoutHelpers.AtLeftIn(ChkDefCmpgn, panel, 100)
    LayoutHelpers.AtTopIn(ChkDefCmpgn, panel, 77)
    local lblDefCmpgn = UIUtil.CreateText(ChkDefCmpgn, "<LOC uicampaign_0002>Default campaigns", 16)
    LayoutHelpers.RightOf(lblDefCmpgn, ChkDefCmpgn, 4)
    lblDefCmpgn.Top:Set(lblDefCmpgn.Top() + 4)

    -- downloaded campaigns
    local ChkDwnldCmpgn = Checkbox(panel,
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_up.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_up.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_over.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_over.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_dis.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_dis.dds'))
    LayoutHelpers.AtLeftIn(ChkDwnldCmpgn, panel, 275)
    LayoutHelpers.AtTopIn(ChkDwnldCmpgn, panel, 77)
    local lblDwnldCmpgn = UIUtil.CreateText(ChkDwnldCmpgn, "<LOC uicampaign_0003>Downloaded campaigns", 16)
    LayoutHelpers.RightOf(lblDwnldCmpgn, ChkDwnldCmpgn, 4)
    lblDwnldCmpgn.Top:Set(lblDwnldCmpgn.Top() + 4)

    -- tutorial campaigns
    local ChkTutCmpgn = Checkbox(panel,
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_up.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_up.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_over.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_over.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_dis.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_dis.dds'))
    LayoutHelpers.AtLeftIn(ChkTutCmpgn, panel, 450)
    LayoutHelpers.AtTopIn(ChkTutCmpgn, panel, 77)
    local lblTutCmpgn = UIUtil.CreateText(ChkTutCmpgn, "<LOC uicampaign_0011>Tutorials", 16)
    LayoutHelpers.RightOf(lblTutCmpgn, ChkTutCmpgn, 4)
    lblTutCmpgn.Top:Set(lblTutCmpgn.Top() + 4)

    -- sort
    local ChkSort = Checkbox(panel,
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_up.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_up.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_over.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_over.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-d_btn_dis.dds'),
        UIUtil.UIFile('/dialogs/check-box_btn/radio-s_btn_dis.dds'))
    LayoutHelpers.AtLeftIn(ChkSort, panel, 700)
    LayoutHelpers.AtTopIn(ChkSort, panel, 77)
    local lblSort = UIUtil.CreateText(ChkSort, "<LOC uicampaign_0004>Sort chronologically", 16)
    LayoutHelpers.RightOf(lblSort, ChkSort, 4)
    lblSort.Top:Set(lblSort.Top() + 4)

    -- set check status
    if not GetPreference('campaign_overview.NotChkDefCmpgnChecked') then
        ChkDefCmpgn:SetCheck(true, true)
    end
    if not GetPreference('campaign_overview.NotChkDwnldCmpgnChecked') then
        ChkDwnldCmpgn:SetCheck(true, true)
    end
    if not GetPreference('campaign_overview.NotChkTutCmpgnChecked') then
        ChkTutCmpgn:SetCheck(true, true)
    end
    if not GetPreference('campaign_overview.NotChkSortChecked') then
        ChkSort:SetCheck(true, true)
    end

    -- init oncheck events
    ChkDefCmpgn.OnCheck = function(self, checked)
        SetPreference('campaign_overview.NotChkDefCmpgnChecked', not checked)
        ShowDefault(checked)
    end
    ChkDwnldCmpgn.OnCheck = function(self, checked)
        SetPreference('campaign_overview.NotChkDwnldCmpgnChecked', not checked)
        ShowDownloaded(checked)
    end
    ChkTutCmpgn.OnCheck = function(self, checked)
        SetPreference('campaign_overview.NotChkTutCmpgnChecked', not checked)
        ShowTutorials(checked)
    end
    ChkSort.OnCheck = function(self, checked)
        SetPreference('campaign_overview.NotChkSortChecked', not checked)
        SortCampaigns(checked)
    end

    -- -------------------------------------------------------------------------------------------
    -- BUTTONS
    -- -------------------------------------------------------------------------------------------

    -- website button
    local websiteBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "<LOC _Website>Website", 16, 2)
    LayoutHelpers.AtHorizontalCenterIn(websiteBtn, panel)
    LayoutHelpers.AtTopIn(websiteBtn, panel, 665)
    websiteBtn.OnClick = function(self)
        if selectedCmpgn.url then
            OpenUrlDialog(panel, selectedCmpgn.url)
        end
    end
    websiteBtn:Disable()

    -- back button
    local backBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "<LOC _Back>Back", 16, 2)
    LayoutHelpers.AtLeftIn(backBtn, panel, 96)
    LayoutHelpers.AtTopIn(backBtn, panel, 665)
    backBtn.OnClick = function(self)
        panel:Destroy()
    	if exitBehavior then
            exitBehavior()
        end
    end
    import('/lua/ui/uimain.lua').SetEscapeHandler(function() backBtn.OnClick() end)

    -- start button
    local startBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/large-no-bracket-btn/large', "<LOC uicampaign_0006>Start campaign", 16, 2)
    LayoutHelpers.AtRightIn(startBtn, panel, 50)
    LayoutHelpers.AtTopIn(startBtn, panel, 665)
    startBtn.OnClick = function(self)
        panel:Destroy()
        StartCampaign(selectedCmpgn.campaignInfo)
    end
    startBtn:Disable()

    -- -------------------------------------------------------------------------------------------
    -- SCROLL BARS
    -- -------------------------------------------------------------------------------------------

    local numElementsPerPage = 3

    -- campaign scrollbars
    local scrollGroup = Group(panel)
    scrollGroup.Width:Set(900)
    scrollGroup.Height:Set(532)
    LayoutHelpers.AtLeftTopIn(scrollGroup, panel, 50, 120)

    local scrollbar = UIUtil.CreateVertScrollbarFor(scrollGroup)
    -- Why not use a horizontal scrollbar? I would have if horizontal scrollbars in FA would actually work

    scrollGroup.controlList = {}
    scrollGroup.top = 1

    scrollGroup.GetScrollValues = function(self, axis)
        return 1, table.getn(self.controlList), self.top, math.min(self.top + numElementsPerPage - 1, table.getn(scrollGroup.controlList))
    end

    scrollGroup.ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta))
    end

    scrollGroup.ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta) * numElementsPerPage)
    end

    scrollGroup.ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self.top then return end
        self.top = math.max(math.min(table.getn(self.controlList) - numElementsPerPage + 1 , top), 1)
        self:CalcVisible()
    end

    scrollGroup.IsScrollable = function(self, axis)
        return true
    end

    scrollGroup.CalcVisible = function(self)
        local top = self.top
        local bottom = self.top + numElementsPerPage
        for index, control in ipairs(self.controlList) do
            if index < top or index >= bottom then
                control:Hide()
            else
                control:Show()
                control.Top:Set(self.Top()-2) -- here
                local lIndex = index
                local lControl = control
                control.Left:Set(function() return self.Left() + ((lIndex - top) * lControl.Width()) end) -- here
            end
        end
    end

    scrollGroup.Clear = function(self)
        for index, control in self.controlList do
            control:Destroy()
        end
        self.controlList = {}
    end

    -- -------------------------------------------------------------------------------------------
    -- CAMPAIGN LIST ELEMENT
    -- -------------------------------------------------------------------------------------------

    local function CreateListElement(parent, campaignInfo, onSelectBehaviour)

        local bmpFiles = { d = "/campaign/campaign-overview/campaign-item_d.dds", s = "/campaign/campaign-overview/campaign-item_s.dds", }
        if campaignInfo.istutorial then
            bmpFiles = { d = "/campaign/campaign-overview/campaign-item-tut_d.dds", s = "/campaign/campaign-overview/campaign-item-tut_s.dds", }
        end

        local bg = Bitmap(parent, UIUtil.UIFile(bmpFiles['d']))
        bg.Height:Set(532)
        bg.Width:Set(300)

        bg.parent = parent
        bg.campaignInfo = campaignInfo

        local name = UIUtil.CreateText(bg, LOC(campaignInfo.name), 18, UIUtil.bodyFont)
        LayoutHelpers.AtTopIn(name, bg, 12)
        LayoutHelpers.AtHorizontalCenterIn(name, bg)
        name:SetDropShadow(true)

        local complText = LOC('<LOC _No>')
        if campaignInfo.completed then
            complText = LOC('<LOC _Yes>')
        end
        local compl = UIUtil.CreateText(bg, (LOC('<LOC uicampaign_0010>Completed: ') .. complText), 14, 'Arial Bold')
        LayoutHelpers.AtLeftTopIn(compl, bg, 12, 42)

        local xdayText = LOC('<LOC uicampaign_0009>Unknown')
        if campaignInfo.xday then
            if campaignInfo.xday > 0 then
                xdayText = LOC('<LOC uicampaign_0008>X-day') .. ' + ' .. repr(campaignInfo.xday)
            elseif campaignInfo.xday < 0 then
                xdayText = LOC('<LOC uicampaign_0008>X-day') .. ' - ' .. repr(campaignInfo.xday * -1)  -- times -1 to get rid of the -
            else
                xdayText = LOC('<LOC uicampaign_0008>X-day')
            end
        end
        local xday = UIUtil.CreateText(bg, (LOC('<LOC uicampaign_0007>Begins at date: ') .. xdayText), 14, 'Arial Bold')
        LayoutHelpers.AtLeftTopIn(xday, bg, 12, 57)

        -- a little magic here to make the campaign overview thing compatible with custom factions, at least the faction icons

        Factions = import('/lua/factions.lua').GetFactions() -- get most recent faction data

        local factionIcons = {}
        local n = 0
        local f
        for i, faction in Factions do
            if not faction['Key'] or not faction['LargeIcon'] then
                continue
            end
            f = faction['Key']
            factionIcons[f] = Bitmap(bg, UIUtil.UIFile(faction['LargeIcon']))
            factionIcons[f].Height:Set(30)
            factionIcons[f].Width:Set(30)
            factionIcons[f]:DisableHitTest()
            LayoutHelpers.AtLeftIn(factionIcons[f], bg, 15 + (n * 34.5))
            LayoutHelpers.AtTopIn(factionIcons[f], bg, 74 + (math.floor(math.max(n, 1) / 8) * 34.5) )
            n = n + 1
            if not table.find(campaignInfo.factions, f) then
                factionIcons[f]:SetAlpha(0.33)
            end
        end

        local desc = MultiLineText(bg, UIUtil.bodyFont, 14, UIUtil.fontColor)
        LayoutHelpers.AtTopIn(desc, bg, 150)
        LayoutHelpers.AtHorizontalCenterIn(desc, bg)
        desc.Height:Set(85)
        desc.Width:Set(272)
        desc:SetText(LOC(campaignInfo.description))

        if campaignInfo.icon then
            local iconFile = campaignInfo.location .. campaignInfo.icon
            if not DiskGetFileInfo(iconFile) then
                iconFile = campaignInfo.icon
            end
            if DiskGetFileInfo(iconFile) then
                local icon = Bitmap(bg, iconFile)
                icon.Height:Set(272)
                icon.Width:Set(272)
                icon:DisableHitTest()
                LayoutHelpers.AtTopIn(icon, bg, 250)
                LayoutHelpers.AtHorizontalCenterIn(icon, bg)
            end
        else
            -- there's no icon, why not make the textbox a little larger?
            desc.Height:Set(377)
        end

        name:DisableHitTest()
        xday:DisableHitTest()
        desc:DisableHitTest()

        bg.Highlight = function(self, highlight)
            if highlight then
                self:SetTexture(UIUtil.UIFile(bmpFiles['s']))
            else
                self:SetTexture(UIUtil.UIFile(bmpFiles['d']))
            end
        end

        bg.HandleEvent = function(self, event)
            if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
                if onSelectBehaviour then
                    onSelectBehaviour(self)
                end
            end
        end

        bg:Hide()

        return bg
    end

    -- -------------------------------------------------------------------------------------------
    -- BEHAVIOUR
    -- -------------------------------------------------------------------------------------------

    -- campaign selected
    local function SelectCampaign(cmpgn)
        if selectedCmpgn then
            selectedCmpgn:Highlight(false)
        end
        if cmpgn then
            selectedCmpgn = cmpgn
            selectedCmpgn:Highlight(true)
            startBtn:Enable()
        else
            selectedCmpgn = nil
            startBtn:Disable()
            websiteBtn:Disable()
        end
    end

    -- show or hide default campaigns
    function ShowDefault(show)
        PopulateList()
    end

    -- show or hide downloaded campaigns
    function ShowDownloaded(show)
        PopulateList()
    end

    -- show or hide tutorials
    function ShowTutorials(show)
        PopulateList()
    end

    -- sort campaigns
    function SortCampaigns(chronologically)
        PopulateList(true)
    end

    function StartCampaign(campaignInfo)
        local initfile = campaignInfo.location .. '/' .. (campaignInfo.initfile or 'Init.lua')
        if DiskGetFileInfo(initfile) then
            local file = import(initfile)
            if file.Initiate then
                Campaigns.SetLastStartedCampaign(campaignInfo.uid)
                exitBehavior(true)
                file.Initiate()
                return
            end
        end
        -- if the campaign is setup OK then we never get here, that only happens when something is wrong
        WARN('*Campaign: Could not launch campaign. Does initfile exist? Does it have an Initiate function?')
        if exitBehavior then
            exitBehavior()
        end
    end

    -- -------------------------------------------------------------------------------------------
    -- CREATE CAMPAIGN LIST ITEMS
    -- -------------------------------------------------------------------------------------------

    function PopulateList(Refresh)

        if Refresh then
            allCampaigns = Campaigns.GetAllCampaigns(ChkSort:IsChecked())
        end

        local def = ChkDefCmpgn:IsChecked()
        local dwnld = ChkDwnldCmpgn:IsChecked()
        local tut = ChkTutCmpgn:IsChecked()

        -- clear old stuff
        SelectCampaign(nil)
        scrollGroup:Clear()

        local t = 1
        local c
        local lastPlayedCampaign = Campaigns.GetLastStartedCampaign()
        for k, campaign in allCampaigns do

            if (not campaign.downloaded and not def) or (campaign.downloaded and not dwnld)
                    or (campaign.istutorial and not tut) or campaign.selectable == false then
                -- skip campaigns we don't want to see
                continue
            end

            c = CreateListElement(scrollGroup, campaign, SelectCampaign)
            table.insert(scrollGroup.controlList, c)
            if campaign.uid == lastPlayedCampaign then
                SelectCampaign(c)
                scrollGroup.top = math.max(math.min( t-1, (table.getn(scrollGroup.controlList) + 1 - numElementsPerPage)), 1)  -- so the last played campaign is visible
            end
            t = t + 1
        end
        scrollGroup:CalcVisible()
    end

    PopulateList(true)
LOG('1')

end
