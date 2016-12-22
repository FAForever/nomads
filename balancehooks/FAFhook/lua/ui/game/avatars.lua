do


function AvatarUpdate()
    if import('/lua/ui/game/gamemain.lua').IsNISMode() then
        return
    end
    local avatars = GetArmyAvatars()
    local engineers = GetIdleEngineers()
    local factories = GetIdleFactories()
    local needsAvatarLayout = false
    local validAvatars = {}

    -- Find the faction key (1 - 4 valid. 5+ happen for Civilian, default to 4 to use Seraphim textures)
    -- armiesTable[GetFocusArmy()].faction returns 0 = UEF, 1 = Aeon, 2 = Cybran, 3 = Seraphim, 4 = Civilian Army, 5 = Civilian Neutral
    -- We want 1 - 4, with 4 max
    #currentFaction = math.min(GetArmiesTable().armiesTable[GetFocusArmy()].faction + 1, 4)
	# Brute51: no faction hardcoding pls!
	currentFaction = 0
	local army = GetFocusArmy()
	if army >= 0 then
	    currentFaction = GetArmiesTable().armiesTable[GetFocusArmy()].faction + 1
	end
	
    
    if avatars then
        for _, unit in avatars do
            if controls.avatars[unit:GetEntityId()] then
                controls.avatars[unit:GetEntityId()]:Update()
            else
                controls.avatars[unit:GetEntityId()] = CreateAvatar(unit)
                needsAvatarLayout = true
            end
            validAvatars[unit:GetEntityId()] = true
        end
        for entID, control in controls.avatars do
            local i = entID
            if not validAvatars[i] then
                controls.avatars[i]:Destroy()
                controls.avatars[i] = nil
                needsAvatarLayout = true
            end
        end
    elseif controls.avatars then
        for entID, control in controls.avatars do
            local i = entID
            controls.avatars[i]:Destroy()
            controls.avatars[i] = nil
            needsAvatarLayout = true
        end
    end

    if engineers then
        if controls.idleEngineers then
            controls.idleEngineers:Update(engineers)
        else
            controls.idleEngineers = CreateIdleTab(engineers, 'engineer', CreateIdleEngineerList)
            if expandedCheck == 'engineer' then
                controls.idleEngineers.expandCheck:SetCheck(true)
            end
            needsAvatarLayout = true
        end
    else
        if controls.idleEngineers then
            controls.idleEngineers:Destroy()
            controls.idleEngineers = nil
            needsAvatarLayout = true
        end
    end

    if factories and table.getn(EntityCategoryFilterDown(categories.ALLUNITS - categories.GATE, factories)) > 0 then
        if controls.idleFactories then
            controls.idleFactories:Update(EntityCategoryFilterDown(categories.ALLUNITS - categories.GATE, factories))
        else
            controls.idleFactories = CreateIdleTab(EntityCategoryFilterDown(categories.ALLUNITS - categories.GATE, factories), 'factory', CreateIdleFactoryList)
            if expandedCheck == 'factory' then
                controls.idleFactories.expandCheck:SetCheck(true)
            end
            needsAvatarLayout = true
        end
    else
        if controls.idleFactories then
            controls.idleFactories:Destroy()
            controls.idleFactories = nil
            needsAvatarLayout = true
        end
    end

    if needsAvatarLayout then
        import(UIUtil.GetLayoutFilename('avatars')).LayoutAvatars()
    end

    local buttons = import('/modules/scumanager.lua').buttonGroup
    if options.gui_scu_manager == 0 then
        buttons:Hide()
    else 
        buttons:Show()
        buttons.Right:Set(function() return controls.collapseArrow.Right() - 2 end)
        buttons.Top:Set(function() return controls.collapseArrow.Bottom() end)
    end
end



end
