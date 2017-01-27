local Factions = import('/lua/factions.lua').Factions
local FactionInUnitBpToKey = import('/lua/factions.lua').FactionInUnitBpToKey


--this has like one change from faf, not sure what it does though, all at the end of this function.
function OnRolloverHandler(button, state)
    local item = button.Data

    if options.gui_draggable_queue ~= 0 and item.type == 'queuestack' and prevSelection and EntityCategoryContains(categories.FACTORY, prevSelection[1]) then
        if state == 'enter' then
            button.oldHandleEvent = button.HandleEvent
            --if we have entered the button and are dragging something then we want to replace it with what we are dragging
            if dragging == true then
                --move item from old location (index) to new location (this button's index)
                MoveItemInQueue(currentCommandQueue, index, item.position)
                --since the currently selected button has now moved, update the index
                index = item.position

                button.dragMarker = Bitmap(button, '/textures/ui/queuedragger.dds')
                LayoutHelpers.FillParent(button.dragMarker, button)
                button.dragMarker:DisableHitTest()
                Effect.Pulse(button.dragMarker, 1.5, 0.6, 0.8)
            end
            button.HandleEvent = function(self, event)
                if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
                    local count = 1
                    if event.Modifiers.Ctrl == true or event.Modifiers.Shift == true then
                        count = 5
                    end

                    if event.Modifiers.Left then
                        if not dragLock then
                            --left button pressed so start dragging procedure
                            dragging = true
                            index = item.position
                            originalIndex = index

                            self.dragMarker = Bitmap(self, '/textures/ui/queuedragger.dds')
                            LayoutHelpers.FillParent(self.dragMarker, self)
                            self.dragMarker:DisableHitTest()
                            Effect.Pulse(self.dragMarker, 1.5, 0.6, 0.8)

                            --copy un modified queue so that current build order is recorded (for deleting it)
                            oldQueue = table.copy(currentCommandQueue)
                        end
                    else
                        PlaySound(Sound({ Cue = "UI_MFD_Click", Bank = "Interface" }))
                        DecreaseBuildCountInQueue(item.position, count)
                    end
                elseif event.Type == 'ButtonRelease' then
                    if dragging then
                        --if queue has changed then update queue, else increase build count (like default)
                        if modified then
                            ButtonReleaseCallback()
                        else
                            PlaySound(Sound({ Cue = "UI_MFD_Click", Bank = "Interface" }))
                            dragging = false
                            local count = 1
                            if event.Modifiers.Ctrl == true or event.Modifiers.Shift == true then
                                count = 5
                            end
                            IncreaseBuildCountInQueue(item.position, count)
                        end
                        if self.dragMarker then
                            self.dragMarker:Destroy()
                            self.dragMarker = false
                        end
                    end
                else
                    button.oldHandleEvent(self, event)
                end
            end
        else
            if button.oldHandleEvent then
                button.HandleEvent = button.oldHandleEvent
            else
                WARN('OLD HANDLE EVENT MISSING HOW DID THIS HAPPEN?!')
            end
            if button.dragMarker then
                button.dragMarker:Destroy()
                button.dragMarker = false
            end
            UnitViewDetail.Hide() --added in nomads, and thats it bscly
        end
    else
        if state == 'enter' then
            if item.type == 'item' or item.type == 'queuestack' or item.type == 'unitstack' or item.type == 'attachedunit' then
                UnitViewDetail.Show(__blueprints[item.id], sortedOptions.selection[1], item.id)
            elseif item.type == 'enhancement' then
                UnitViewDetail.ShowEnhancement(item.enhTable, item.unitID, item.icon, GetEnhancementPrefix(item.unitID, item.icon), sortedOptions.selection[1])
            end
        else
            UnitViewDetail.Hide()
        end
    end
end

--hooking to fix templates being propagated through factions
local oldOnSelection = OnSelection

function OnSelection(buildableCategories, selection, isOldSelection)

    if options.gui_templates_factory ~= 0 then
        if table.empty(selection) then
            allFactories = false
        else
            allFactories = true
            for i, v in selection do
                if not v:IsInCategory('FACTORY') then
                    allFactories = false
                    break
                end
            end
        end
    end

    if table.getsize(selection) > 0 then
        capturingKeys = false
        -- Sorting down units
        local buildableUnits = EntityCategoryGetUnitList(buildableCategories)
        if not isOldSelection then
            previousTabSet = nil
            previousTabSize = nil
            activeTab = nil
            ClearSessionExtraSelectList()
        end
        sortedOptions = {}
        UnitViewDetail.Hide()

        -- Engymod addition by Rienzilla
        -- Only honour CONSTRUCTIONSORTDOWN if we selected a factory
        local allFactory = true
        for i, v in selection do
            if allFactory and not v:IsInCategory('FACTORY') then
                allFactory = false
            end
        end

        if allFactory then
            local sortDowns = EntityCategoryFilterDown(categories.CONSTRUCTIONSORTDOWN, buildableUnits)
            sortedOptions.t1 = EntityCategoryFilterDown(categories.TECH1 - categories.CONSTRUCTIONSORTDOWN, buildableUnits)
            sortedOptions.t2 = EntityCategoryFilterDown(categories.TECH2 - categories.CONSTRUCTIONSORTDOWN, buildableUnits)
            sortedOptions.t3 = EntityCategoryFilterDown(categories.TECH3 - categories.CONSTRUCTIONSORTDOWN, buildableUnits)
            sortedOptions.t4 = EntityCategoryFilterDown(categories.EXPERIMENTAL - categories.CONSTRUCTIONSORTDOWN, buildableUnits)

            for _, unit in sortDowns do
                if EntityCategoryContains(categories.EXPERIMENTAL, unit) then
                    table.insert(sortedOptions.t3, unit)
                elseif EntityCategoryContains(categories.TECH3, unit) then
                    table.insert(sortedOptions.t2, unit)
                elseif EntityCategoryContains(categories.TECH2, unit) then
                    table.insert(sortedOptions.t1, unit)
                end
            end
        else
            sortedOptions.t1 = EntityCategoryFilterDown(categories.TECH1, buildableUnits)
            sortedOptions.t2 = EntityCategoryFilterDown(categories.TECH2, buildableUnits)
            sortedOptions.t3 = EntityCategoryFilterDown(categories.TECH3, buildableUnits)
            sortedOptions.t4 = EntityCategoryFilterDown(categories.EXPERIMENTAL, buildableUnits)
        end

        if table.getn(buildableUnits) > 0 then
            controls.constructionTab:Enable()
        else
            controls.constructionTab:Disable()
            if BuildMode.IsInBuildMode() then
                BuildMode.ToggleBuildMode()
            end
        end

        sortedOptions.selection = selection
        controls.selectionTab:Enable()

        local allSameUnit = true
        local bpID = false
        local allMobile = true
        for i, v in selection do
            if allMobile and not v:IsInCategory('MOBILE') then
                allMobile = false
            end
            if allSameUnit and bpID and bpID ~= v:GetBlueprint().BlueprintId then
                allSameUnit = false
            else
                bpID = v:GetBlueprint().BlueprintId
            end
            if not allMobile and not allSameUnit then
                break
            end
        end

        if table.getn(selection) == 1 and selection[1]:GetBlueprint().Enhancements then
            controls.enhancementTab:Enable()
        else
            controls.enhancementTab:Disable()
        end

        local templates = Templates.GetTemplates()
        if allMobile and templates and table.getsize(templates) > 0 then
            sortedOptions.templates = {}
            for templateIndex, template in templates do
                local valid = true
                for _, entry in template.templateData do
                    if type(entry) == 'table' then
                        if not table.find(buildableUnits, entry[1]) then
                            valid = false
                            break
                        end
                    end
                end
                if valid then
                    template.templateID = templateIndex
                    table.insert(sortedOptions.templates, template)
                end
            end
        end

        if table.getn(selection) == 1 then
            currentCommandQueue = SetCurrentFactoryForQueueDisplay(selection[1])
        else
            currentCommandQueue = {}
            ClearCurrentFactoryForQueueDisplay()
        end

        if not isOldSelection then
            if not controls.constructionTab:IsDisabled() then
                controls.constructionTab:SetCheck(true)
            else
                controls.selectionTab:SetCheck(true)
            end
        elseif controls.constructionTab:IsChecked() then
            controls.constructionTab:SetCheck(true)
        elseif controls.enhancementTab:IsChecked() then
            controls.enhancementTab:SetCheck(true)
        else
            controls.selectionTab:SetCheck(true)
        end

        prevSelection = selection
        prevBuildCategories = buildableCategories
        prevBuildables = buildableUnits
        import(UIUtil.GetLayoutFilename('construction')).OnSelection(false)

        controls.constructionGroup:Show()
        controls.choices:CalcVisible()
        controls.secondaryChoices:CalcVisible()
    else
        if BuildMode.IsInBuildMode() then
            BuildMode.ToggleBuildMode()
        end
        currentCommandQueue = {}
        ClearCurrentFactoryForQueueDisplay()
        import(UIUtil.GetLayoutFilename('construction')).OnSelection(true)
    end

    if table.getsize(selection) > 0 then
        --repeated from original to access the local variables
        local allSameUnit = true
        local bpID = false
        local allMobile = true
        for i, v in selection do
            if allMobile and not v:IsInCategory('MOBILE') then
                allMobile = false
            end
            if allSameUnit and bpID and bpID ~= v:GetBlueprint().BlueprintId then
                allSameUnit = false
            else
                bpID = v:GetBlueprint().BlueprintId
            end
            if not allMobile and not allSameUnit then
                break
            end
        end

        --Upgrade multiple SCU at once
        if selection[1]:GetBlueprint().Enhancements and allSameUnit then
            controls.enhancementTab:Enable()
        end

        --Allow all races to build other races templates
        if options.gui_all_race_templates ~= 0 then
            local templates = Templates.GetTemplates()
            local buildableUnits = EntityCategoryGetUnitList(buildableCategories)
            if allMobile and templates and table.getsize(templates) > 0 then

                local unitFactionName = selection[1]:GetBlueprint().General.FactionName
                local currentFaction = Factions[ FactionInUnitBpToKey[unitFactionName] ]

                if currentFaction then
                    sortedOptions.templates = {}
                    local function ConvertID(BPID)
                        local prefixes = currentFaction.GAZ_UI_Info.BuildingIdPrefixes or {}
                        for k, prefix in prefixes do
                            if table.find(buildableUnits, string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")) then
                                return string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")
                            end
                        end
                        return false
                    end

                    for templateIndex, template in templates do
                        local valid = true
                        local converted = false
                        for _, entry in template.templateData do
                            if type(entry) == 'table' then
                                if not table.find(buildableUnits, entry[1]) then

                                    entry[1] = ConvertID(entry[1])
                                    converted = true
                                    if not table.find(buildableUnits, entry[1]) then
                                        valid = false
                                        break
                                    end
                                end
                            end
                        end
                        if valid then
                            if converted then
                                template.icon = ConvertID(template.icon)
                            end
                            template.templateID = templateIndex
                            table.insert(sortedOptions.templates, template)
                        end
                    end
                end

                --refresh the construction tab to show any new available templates
                if not isOldSelection then
                    if not controls.constructionTab:IsDisabled() then
                        controls.constructionTab:SetCheck(true)
                    else
                        controls.selectionTab:SetCheck(true)
                    end
                elseif controls.constructionTab:IsChecked() then
                    controls.constructionTab:SetCheck(true)
                elseif controls.enhancementTab:IsChecked() then
                    controls.enhancementTab:SetCheck(true)
                else
                    controls.selectionTab:SetCheck(true)
                end
            end
        end
    end

    -- add valid templates for selection
    if allFactories then
        sortedOptions.templates = {}
        local templates = TemplatesFactory.GetTemplates()
        if templates and not table.empty(templates) then
            local buildableUnits = EntityCategoryGetUnitList(buildableCategories)
            for templateIndex, template in ipairs(templates) do
                local valid = true
                for index, entry in ipairs(template.templateData) do
                    if not table.find(buildableUnits, entry.id) then
                        valid = false
                        -- allow templates containing factory upgrades & higher tech units
                        if index > 1 then
                            for i = index - 1, 1, -1 do
                                local blueprint = __blueprints[template.templateData[i].id]
                                if blueprint.General.UpgradesFrom ~= 'none' then
                                    -- previous entry is a (valid) upgrade
                                    valid = true
                                    break
                                end
                            end
                        end
                        break
                    end
                end
                if valid then
                    template.templateID = templateIndex
                    table.insert(sortedOptions.templates, template)
                end
            end
        end

        -- templates tab enable & refresh
        local templatesTab = GetTabByID('templates')
        if templatesTab then
            templatesTab:Enable()
            if templatesTab:IsChecked() then
                templatesTab:SetCheck(true)
            end
        end
    end
end



--hooking to fix enhancement prefixes not accounting for nomads
local oldGetEnhancementPrefix = GetEnhancementPrefix

function GetEnhancementPrefix(unitID, iconID)
    local prefix = ''
    if string.sub(unitID, 2, 2) == 'N' or string.sub(unitID, 2, 2) == 'n' then
        prefix = '/game/nomads-enhancements/'..iconID
    else
        prefix = oldGetEnhancementPrefix(unitID, iconID)
    end
    return prefix
end