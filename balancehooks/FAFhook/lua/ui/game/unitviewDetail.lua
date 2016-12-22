do


function ShowEnhancement(bp, bpID, iconID, iconPrefix, userUnit)
    if CheckFormat() then
        -- Name / Description
        View.UnitImg:SetTexture(UIUtil.UIFile(iconPrefix..'_btn_up.dds'))
        
        LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 10)
        View.UnitShortDesc:SetFont(UIUtil.bodyFont, 14)

        local slotName = enhancementSlotNames[string.lower(bp.Slot)]
        slotName = slotName or bp.Slot

        if bp.Name ~= nil then
            View.UnitShortDesc:SetText(LOCF("%s: %s", bp.Name, slotName))
        else
            View.UnitShortDesc:SetText(LOC(slotName))
        end
        if View.UnitShortDesc:GetStringAdvance(View.UnitShortDesc:GetText()) > View.UnitShortDesc.Width() then
            LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 14)
            View.UnitShortDesc:SetFont(UIUtil.bodyFont, 10)
        end
        
        local showecon = true
        local showAbilities = false
        local showUpKeep = false
        local time, energy, mass
        if bp.Icon ~= nil and not string.find(bp.Name, 'Remove') then
            time, energy, mass = import('/lua/game.lua').GetConstructEconomyModel(userUnit, bp)
            time = math.max(time, 1)
            showUpKeep = DisplayResources(bp, time, energy, mass)
            View.TimeStat.Value:SetFont(UIUtil.bodyFont, 14)
            View.TimeStat.Value:SetText(string.format("%s", FormatTime(time)))
            if string.len(View.TimeStat.Value:GetText()) > 5 then
                View.TimeStat.Value:SetFont(UIUtil.bodyFont, 10)
            end
        else
            showecon = false
            if View.Description then
                View.Description:Hide()
                for i, v in View.Description.Value do
                    v:SetText("")
                end
            end
        end
        
        if View.Description then
            local tempDescID = bpID.."-"..iconID

            # if unit is an enhancement preset unit then use the base units blueprint id for the enhancement tooltips
            if userUnit and userUnit:GetBlueprint().EnhancementPresetAssigned then
                tempDescID = userUnit:GetBlueprint().EnhancementPresetAssigned.BaseBlueprintId .. "-" .. iconID
            end

            if UnitDescriptions[tempDescID] and not string.find(bp.Name, 'Remove') then
                local tempDesc = LOC(UnitDescriptions[tempDescID])
                WrapAndPlaceText(nil, nil, nil, nil, tempDesc, View.Description)
            else
                WARN('No description found for unit: ', bpID, ' enhancement: ', iconID)
                View.Description:Hide()
                for i, v in View.Description.Value do
                    v:SetText("")
                end
            end
        end
        
        local showShield = false
        if bp.ShieldMaxHealth then
            showShield = true
            View.ShieldStat.Value:SetText(bp.ShieldMaxHealth)
        end
    
        ShowView(showUpKeep, true, showecon, showShield)
        if time == 0 and energy == 0 and mass == 0 then
            View.BuildCostGroup:Hide()
            View.TimeStat:Hide()
        end
    else
        Hide()
    end
end

function Show(bp, buildingUnit, bpID)
    if CheckFormat() then
        # Name / Description
        if false then
            local foo, iconName = GameCommon.GetCachedUnitIconFileNames(bp)
            if iconName then
                View.UnitIcon:SetTexture(iconName)
            else
                View.UnitIcon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))    
            end
        end
        LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 10)
        View.UnitShortDesc:SetFont(UIUtil.bodyFont, 14)
        local description = LOC(bp.Description)
        if GetTechLevelString(bp) then
            description = LOCF('Tech %d %s', GetTechLevelString(bp), description)
        end
        if bp.General.UnitName != nil then
            View.UnitShortDesc:SetText(LOCF("%s: %s", bp.General.UnitName, description))
        else
            View.UnitShortDesc:SetText(LOCF("%s", description))
        end
        if View.UnitShortDesc:GetStringAdvance(View.UnitShortDesc:GetText()) > View.UnitShortDesc.Width() then
            LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 14)
            View.UnitShortDesc:SetFont(UIUtil.bodyFont, 10)
        end
        local showecon = true
        local showUpKeep = false
        local showAbilities = false
        if buildingUnit != nil then


	   -- Differential upgrading. Check to see if building this would be an upgrade
	   local targetBp = bp
	   local builderBp = buildingUnit:GetBlueprint()
	   
	   local performUpgrade = false
	   
	   if targetBp.General.UpgradesFrom == builderBp.BlueprintId then
	      performUpgrade = true
	   elseif targetBp.General.UpgradesFrom == builderBp.General.UpgradesTo then
	      performUpgrade = true
	   elseif targetBp.General.UpgradesFromBase ~= "none" then
	      -- try testing against the base
	      if targetBp.General.UpgradesFromBase == builderBp.BlueprintId then
		 performUpgrade = true
	      elseif targetBp.General.UpgradesFromBase == builderBp.General.UpgradesFromBase then
		 performUpgrade = true
	      end
	   end

	   local time, energy, mass

	   if performUpgrade then
	      time, energy, mass = import('/lua/game.lua').GetConstructEconomyModel(buildingUnit, bp.Economy, builderBp.Economy)
	   else
	      time, energy, mass = import('/lua/game.lua').GetConstructEconomyModel(buildingUnit, bp.Economy)
	   end

            time = math.max(time, 1)
            showUpKeep = DisplayResources(bp, time, energy, mass)
            View.TimeStat.Value:SetFont(UIUtil.bodyFont, 14)
            View.TimeStat.Value:SetText(string.format("%s", FormatTime(time)))
            if string.len(View.TimeStat.Value:GetText()) > 5 then
                View.TimeStat.Value:SetFont(UIUtil.bodyFont, 10)
            end
        else
            showecon = false
        end
            
        # Health stat
        local MaxHealth = bp.Display.UIUnitViewOverrides.MaxHealth or bp.Defense.MaxHealth
        View.HealthStat.Value:SetText(string.format("%d", MaxHealth))
    
        if View.Description then
            WrapAndPlaceText(bp.Air,
            bp.Physics,
            bp.Weapon,
            bp.Display.Abilities,
            LOC(UnitDescriptions[bpID]),
            View.Description)
        end

        local showShield = false
        if (bp.Display.UIUnitViewOverrides and bp.Display.UIUnitViewOverrides.ShieldMaxHealth) or (bp.Defense.Shield and bp.Defense.Shield.ShieldMaxHealth) then
            showShield = true
            local text = ''
            if bp.Display.UIUnitViewOverrides and bp.Display.UIUnitViewOverrides.ShieldMaxHealth then
                text = tostring(bp.Display.UIUnitViewOverrides.ShieldMaxHealth)
            else
                text = tostring(bp.Defense.Shield.ShieldMaxHealth)
            end
            View.ShieldStat.Value:SetText(text)
        end

        local showCapacitor = false
        if (bp.Display.UIUnitViewOverrides and bp.Display.UIUnitViewOverrides.CapacitorDuration) or (bp.Abilities.Capacitor and bp.Abilities.Capacitor.Duration) then
            showCapacitor = true
            showShield = false
            local text = ''
            if bp.Display.UIUnitViewOverrides and bp.Display.UIUnitViewOverrides.CapacitorDuration then
                text = tostring(bp.Display.UIUnitViewOverrides.CapacitorDuration)
            else
                text = text .. '-'
            end
            text = text .. '/'
            if bp.CapacitorNewChargeTime then
                text = text .. tostring(bp.CapacitorNewChargeTime)
            else
                text = text .. '-'
            end
            text = text .. '/'
            if bp.CapacitorNewEnergyDrainPerSecond then
                text = text .. tostring(bp.CapacitorNewEnergyDrainPerSecond)
            else
                text = text .. '-'
            end
            View.CapacitorStat.Value:SetText(text)
        end
        
        local iconName = GameCommon.GetCachedUnitIconFileNames(bp)
        View.UnitImg:SetTexture(iconName)
        View.UnitImg.Height:Set(46)
        View.UnitImg.Width:Set(48)
        
        ShowView(showUpKeep, false, showecon, showShield, showCapacitor)
    else
        Hide()
    end
end


end