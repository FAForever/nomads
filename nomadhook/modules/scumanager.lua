do


-- This whole table should be copied from the SCU's blueprint (see EnhancementPresets). Doing this hard coded for now, following FAF code.
upgradeDefaultTable = table.merged( upgradeDefaultTable, {

	NOMADS = {
		Engineer = {
			'EngineeringLeft',
			'EngineeringRight',
		},
		Combat = {
                'GunLeft',
                'GunLeftUpgrade',
                'GunRight',  
                'RapidRepair',
		},
	},
})


--configuration window
function ConfigureUpgrades()
	local window = Bitmap(GetFrame(0))
	window:SetTexture('/textures/ui/common/SCUManager/configwindow.dds')
	LayoutHelpers.AtRightTopIn(window, GetFrame(0), 100, 100)
	window.Depth:Set(1000)
	local buttonGrid = Grid(window, 48, 48)
	LayoutHelpers.AtLeftTopIn(buttonGrid, window, 10, 30)
	buttonGrid.Right:Set(function() return window.Right() - 10 end)
	buttonGrid.Bottom:Set(function() return window.Bottom() - 32 end)
	buttonGrid.Depth:Set(window.Depth() + 10)

	local factionChooser = Combo(window, 14, 4, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	--create the buttons for choosing acu type
	local combatButton = Checkbox(window, '/textures/ui/common/SCUManager/combat_up.dds', '/textures/ui/common/SCUManager/combat_sel.dds', '/textures/ui/common/SCUManager/combat_over.dds', '/textures/ui/common/SCUManager/combat_over.dds', '/textures/ui/common/SCUManager/combat_up.dds', '/textures/ui/common/SCUManager/combat_up.dds', "UI_Menu_MouseDown_Sml", "UI_Menu_MouseDown_Sml")
	local EngineerButton = Checkbox(window, '/textures/ui/common/SCUManager/engineer_up.dds', '/textures/ui/common/SCUManager/engineer_sel.dds', '/textures/ui/common/SCUManager/engineer_over.dds', '/textures/ui/common/SCUManager/engineer_over.dds', '/textures/ui/common/SCUManager/engineer_up.dds', '/textures/ui/common/SCUManager/engineer_up.dds', "UI_Menu_MouseDown_Sml", "UI_Menu_MouseDown_Sml")
	combatButton:SetCheck(true)
	
	LayoutHelpers.AtLeftTopIn(factionChooser, window, 6, 6)
	factionChooser.Width:Set(100)
	factionChooser:AddItems({'Aeon', 'Cybran', 'UEF', 'Seraphim', 'Nomads'})
	factionChooser.OnClick = function(self, index, text)
		if combatButton:IsChecked() then
			LayoutGrid(buttonGrid, text, 'Combat')
		else
			LayoutGrid(buttonGrid, text, 'Engineer')
		end
	end
	
	LayoutHelpers.AtLeftTopIn(combatButton, window, 108, 6)
	LayoutHelpers.RightOf(EngineerButton, combatButton)
	combatButton.OnClick = function(self, modifiers)
		EngineerButton:SetCheck(false)
		combatButton:SetCheck(true)
		local index, fact = factionChooser:GetItem()
		LayoutGrid(buttonGrid, fact, 'Combat')
	end
	EngineerButton.OnClick = function(self, modifiers)
		combatButton:SetCheck(false)
		EngineerButton:SetCheck(true)
		local index, fact = factionChooser:GetItem()
		LayoutGrid(buttonGrid, fact, 'Engineer')
	end

	--the 6 icons showing which upgrades the scu will recieve
	buttonGrid.QueuedUpgrades = {}
	for i = 1, 6 do
		local index = i
		buttonGrid.QueuedUpgrades[index] = Bitmap(buttonGrid)
		buttonGrid.QueuedUpgrades[index]:SetTexture('/textures/ui/common/SCUManager/queueborder.dds')
		if index == 1 then
			LayoutHelpers.AtLeftTopIn(buttonGrid.QueuedUpgrades[index], window, 150, 4)
		else
			LayoutHelpers.RightOf(buttonGrid.QueuedUpgrades[index], buttonGrid.QueuedUpgrades[index-1])
		end
	end

	local okButton = UIUtil.CreateButtonStd(window, '/widgets/small', 'OK', 16)
	LayoutHelpers.AtLeftTopIn(okButton, window, 160, 123)
	okButton.OnClick = function(self)
		Prefs.SetToCurrentProfile("SCU_Manager_settings", upgradeTable)
		Prefs.SavePreferences()
		window:Destroy()
	end
	local cancelButton = UIUtil.CreateButtonStd(window, '/widgets/small', 'Cancel', 16)
	LayoutHelpers.AtLeftTopIn(cancelButton, window, 8, 123)
	cancelButton.OnClick = function(self)
		upgradeTable = Prefs.GetFromCurrentProfile("SCU_Manager_settings") or upgradeDefaultTable
		window:Destroy()
	end

	if GetSelectedUnits() then
		local faction = GetSelectedUnits()[1]:GetBlueprint().General.FactionName
		FactionIndexTable = {Aeon = 1, Cybran = 2, UEF = 3, Seraphim = 4, Nomads = 5}
		if FactionIndexTable[faction] then
			factionChooser:SetItem(FactionIndexTable[faction])
			LayoutGrid(buttonGrid, faction, 'Combat')
		else
			LayoutGrid(buttonGrid, 'Aeon', 'Combat')
		end
	else
		LayoutGrid(buttonGrid, 'Aeon', 'Combat')
	end
end

--shows available and current enhancements for an scu type
function LayoutGrid(buttonGrid, faction, scuType)
	--get the enhancements available to whichever scu is being edited
	local bpid = 'ual0301'
	if faction == 'Cybran' then
		bpid = 'url0301'
	elseif faction == 'UEF' then
		bpid = 'uel0301'
	elseif faction == 'Seraphim' then
		bpid = 'xsl0301'
	elseif faction == 'Nomads' then
		bpid = 'inu3001'
	end
	local bp = __blueprints[bpid]
	local availableEnhancements = bp["Enhancements"]

	--clear the current enhancements, and add the new ones
	for i, v in buttonGrid.QueuedUpgrades do
		if v.Icon then
			v.Icon:Destroy()
			v.Icon = false
		end
		if upgradeTable[string.upper(faction)][scuType][i] then
			local enhancementName = upgradeTable[string.upper(faction)][scuType][i]
			v.Icon = CreateEnhancementButton(v, enhancementName, availableEnhancements[enhancementName], bpid, 22, faction, scuType, buttonGrid)
			v.Icon.enhancementName = enhancementName
			v.Icon.Index = i
			LayoutHelpers.AtCenterIn(v.Icon, v)
		end
	end

	--make a table of available enhancements, not showing any that are already owned, any that need a non queued prerequisite, or any where the slot is already used
	buttonGrid:DeleteAndDestroyAll(true)
	local visCols, visRows = buttonGrid:GetVisible()
	local currentRow = 1
	local currentCol = 1
	buttonGrid:AppendCols(visCols, true)
	buttonGrid:AppendRows(1, true)
	local index = 0
	local tempAvailableButtons = {}
	for name, data in availableEnhancements do
		local alreadyOwns = false
		for i, v in buttonGrid.QueuedUpgrades do
			if v.Icon.enhancementName then
				if v.Icon.enhancementName == name then
					alreadyOwns = true
				end
			end
		end
		if not alreadyOwns then
			if data['Slot'] and not string.find(name, 'Remove') then
				if data['Prerequisite'] then
					for i, v in buttonGrid.QueuedUpgrades do
						if v.Icon.enhancementName then
							if v.Icon.enhancementName == data['Prerequisite'] then
								table.insert(tempAvailableButtons, {Name = name, Enhancement = data})
							end
						end
					end
				else
					local slotUsed = false
					for i, v in buttonGrid.QueuedUpgrades do
						if v.Icon.enhancementName then
							if availableEnhancements[v.Icon.enhancementName].Slot == data['Slot'] then
								slotUsed = true
							end
						end
					end
					if not slotUsed then
						table.insert(tempAvailableButtons, {Name = name, Enhancement = data})
					end
				end
			end
		end
	end
	table.sort(tempAvailableButtons, function(up1, up2) return (up1.Enhancement.Slot .. up1.Name) <= (up2.Enhancement.Slot .. up2.Name) end)
	for i, data in tempAvailableButtons do
		local button = CreateEnhancementButton(buttonGrid, data.Name, data.Enhancement, bpid, 46, faction, scuType, buttonGrid)
		buttonGrid:SetItem(button, currentCol, currentRow, true)
		if currentCol < visCols then
			currentCol = currentCol + 1
		else
			currentCol = 1
			currentRow = currentRow + 1
			buttonGrid:AppendRows(1, true)
		end
	end
	buttonGrid:EndBatch()
end

local oldGetEnhancementPrefix = GetEnhancementPrefix
function GetEnhancementPrefix(unitID, iconID)
    local prefix = oldGetEnhancementPrefix(unitID, iconID)
    if string.sub(unitID, 2, 2) == 'n' then
        prefix = '/game/nomad-enhancements/'..iconID
    end
    return prefix
end

--tell the scu what type it now is, and upgrade it
function UpgradeSCU(unit, upgType)
	local faction = false
	if unit:IsInCategory('UEF') then
		faction = 'UEF'
	elseif unit:IsInCategory('AEON') then
		faction = 'AEON'
	elseif unit:IsInCategory('CYBRAN') then
		faction = 'CYBRAN'
	elseif unit:IsInCategory('SERAPHIM') then
		faction = 'SERAPHIM'
	elseif unit:IsInCategory('NOMAD') then
		faction = 'NOMADS'
	end
	if faction then
		local upgList = upgradeTable[faction][upgType]
		if table.getsize(upgList) == 0 then
			return
		end
		for i, upgrade in upgList do
			--LOG('issuing ' ..upgrade)
			--get current command mode since issuing a unit command will cancel it so we need to reissue it
			local commandmode = import('/lua/ui/game/commandmode.lua')
			local currentCommand = commandmode.GetCommandMode()
			local orderData = {
				TaskName = "EnhanceTask",
				Enhancement = upgrade,
			}
			IssueUnitCommand({unit}, "UNITCOMMAND_Script", orderData, false)
			commandmode.StartCommandMode(currentCommand[1], currentCommand[2])
		end
		unit.SCUType = upgType
	end
end



end