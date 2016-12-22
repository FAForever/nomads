
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

    if table.getn(selection) == 1 then
        currentCommandQueue = SetCurrentFactoryForQueueDisplay(selection[1])
    else
        currentCommandQueue = {}
        ClearCurrentFactoryForQueueDisplay()
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

        if not selection[1]:IsInCategory('FACTORY') then
            local inQueue = {}
            for _, v in currentCommandQueue or {} do
                inQueue[v.id] = true
            end


            local bpid = __blueprints[selection[1]:GetBlueprint().BlueprintId].General.UpgradesTo
            if bpid then
                while bpid and bpid ~= '' do -- UpgradesTo is sometimes ''??
                    if not inQueue[bpid] then
                        table.insert(buildableUnits, bpid)
                    end
                    bpid = __blueprints[bpid].General.UpgradesTo
                end

                buildableUnits = table.unique(buildableUnits)
            end
        end

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
        elseif EntityCategoryContains(categories.ENGINEER + categories.FACTORY, selection[1]) then
            sortedOptions.t1 = EntityCategoryFilterDown(categories.TECH1, buildableUnits)
            sortedOptions.t2 = EntityCategoryFilterDown(categories.TECH2, buildableUnits)
            sortedOptions.t3 = EntityCategoryFilterDown(categories.TECH3, buildableUnits)
            sortedOptions.t4 = EntityCategoryFilterDown(categories.EXPERIMENTAL, buildableUnits)
        else
            sortedOptions.t1 = buildableUnits
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
                local currentFaction = selection[1]:GetBlueprint().General.FactionName
                if currentFaction then
                    sortedOptions.templates = {}
                    local function ConvertID(BPID)
                        local FirstLetterArray = { "%1", "x", "u", "b", "i" }
                        local SecondLetterArray = { ["Aeon"] = "a", ["UEF"] = "e", ["Cybran"] = "r", ["Seraphim"] = "s", ["Nomads"] = "n"}
                        local SecondLetter = SecondLetterArray[currentFaction]
                        for _, FirstLetter in FirstLetterArray do
                            local NewBPID = string.gsub(BPID, "(%a)(%a)(%a)(%d+)",FirstLetter..SecondLetter.. "%3%4")
                        -- =local xsb1012 = string.gsub(ueb1012, "(u)(e)(b)(1012)",x..s.. "b1012")
                            if table.find(buildableUnits, NewBPID) then
                                return NewBPID
                            end
                        end
                        return BPID
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
                            template.icon = ConvertID(template.icon)
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
        prefix = '/game/nomad-enhancements/'..iconID
    else
        prefix = oldGetEnhancementPrefix(unitID, iconID)
    end
    return prefix
end