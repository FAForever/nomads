
function DisplayResources(bp, time, energy, mass)

    # Cost Group
    if time > 0 then
        local consumeEnergy = -energy / time
        local consumeMass = -mass / time
        View.BuildCostGroup.EnergyValue:SetText( string.format("%d (%d)",-energy,consumeEnergy) )
        View.BuildCostGroup.MassValue:SetText( string.format("%d (%d)",-mass,consumeMass) )
        
        View.BuildCostGroup.EnergyValue:SetColor( "FFF05050" )
        View.BuildCostGroup.MassValue:SetColor( "FFF05050" )
    end

    # Upkeep Group

    # check for UI unitview overrides
    local plusEnergyRate = bp.Display.UIUnitViewOverrides.ProductionPerSecondEnergy or              bp.Economy.ProductionPerSecondEnergy or bp.ProductionPerSecondEnergy
    local negEnergyRate = bp.Display.UIUnitViewOverrides.MaintenanceConsumptionPerSecondEnergy or   bp.Economy.MaintenanceConsumptionPerSecondEnergy or bp.MaintenanceConsumptionPerSecondEnergy
    local plusMassRate = bp.Display.UIUnitViewOverrides.ProductionPerSecondMass or                  bp.Economy.ProductionPerSecondMass or bp.ProductionPerSecondMass
    local negMassRate = bp.Display.UIUnitViewOverrides.MaintenanceConsumptionPerSecondMass or       bp.Economy.MaintenanceConsumptionPerSecondMass or bp.MaintenanceConsumptionPerSecondMass

    local upkeepEnergy = GetYield(negEnergyRate, plusEnergyRate)
    local upkeepMass = GetYield(negMassRate, plusMassRate)
    local showUpkeep = false
    if upkeepEnergy != 0 or upkeepMass != 0 then
        View.UpkeepGroup.Label:SetText(LOC("<LOC uvd_0002>Yield"))
        View.UpkeepGroup.EnergyValue:SetText( string.format("%d",upkeepEnergy) )
        View.UpkeepGroup.MassValue:SetText( string.format("%d",upkeepMass) )
        if upkeepEnergy >= 0 then
            View.UpkeepGroup.EnergyValue:SetColor( "FF50F050" )
        else
            View.UpkeepGroup.EnergyValue:SetColor( "FFF05050" )
        end
    
        if upkeepMass >= 0 then
            View.UpkeepGroup.MassValue:SetColor( "FF50F050" )
        else
            View.UpkeepGroup.MassValue:SetColor( "FFF05050" )
        end
        showUpkeep = true
    elseif bp.Economy and (bp.Economy.StorageEnergy != 0 or bp.Economy.StorageMass != 0) then
        View.UpkeepGroup.Label:SetText(LOC("<LOC uvd_0006>Storage"))
        local upkeepEnergy = bp.Economy.StorageEnergy or 0
        local upkeepMass = bp.Economy.StorageMass or 0
        View.UpkeepGroup.EnergyValue:SetText( string.format("%d",upkeepEnergy) )
        View.UpkeepGroup.MassValue:SetText( string.format("%d",upkeepMass) )
        View.UpkeepGroup.EnergyValue:SetColor( "FF50F050" )
        View.UpkeepGroup.MassValue:SetColor( "FF50F050" )
        showUpkeep = true
    end
    
    return showUpkeep 
end

--hooked to show/hide capacitor
function ShowView(showUpKeep, enhancement, showecon, showShield, showCapacitor)
    import('/lua/ui/game/unitview.lua').ShowROBox(false, false)
    View:Show() --changed
    
    View.UpkeepGroup:SetHidden(not showUpKeep)
    
    View.BuildCostGroup:SetHidden(not showecon)
    View.UpkeepGroup:SetHidden(not showUpKeep)
    View.TimeStat:SetHidden(not showecon)
    View.HealthStat:SetHidden(not showecon)
        
    View.HealthStat:SetHidden(enhancement)
    
    View.ShieldStat:SetHidden(not showShield)

    View.CapacitorStat:SetHidden(not showCapacitor)
    
    if View.Description then
        View.Description:SetHidden(ViewState == "limited" or View.Description.Value[1]:GetText() == "")
    end
end


--hooked to show/hide capacitor
function ShowEnhancement(bp, bpID, iconID, iconPrefix, userUnit)
    if not CheckFormat() then
        View:Hide()
        return
    end

    -- Name / Description
    View.UnitImg:SetTexture(UIUtil.UIFile(iconPrefix..'_btn_up.dds'))
    
    LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 10)
    View.UnitShortDesc:SetFont(UIUtil.bodyFont, 14)

    local slotName = enhancementSlotNames[string.lower(bp.Slot)]
    slotName = slotName or bp.Slot -- ok

    if bp.Name != nil then
        View.UnitShortDesc:SetText(LOCF("%s: %s", bp.Name, slotName))
    else
        View.UnitShortDesc:SetText(LOC(slotName))
    end-- ok
    
    if View.UnitShortDesc:GetStringAdvance(View.UnitShortDesc:GetText()) > View.UnitShortDesc.Width() then
        LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 14)
        View.UnitShortDesc:SetFont(UIUtil.bodyFont, 10)
    end --ok
    
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
        -- If SubCommander enhancement, then remove extension. (ual0301_Engineer --> ual0301)
        if string.find( bpID, '0301_' ) then
            bpID = string.sub(bpID, 1, string.find(bpID, "_[^_]*$")-1 )
        end
        local tempDescID = bpID.."-"..iconID
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
    end --changed
    
    local showShield = false
    if bp.ShieldMaxHealth then
        showShield = true
        View.ShieldStat.Value:SetText(bp.ShieldMaxHealth)
    end

    local showCapacitor = false
    if bp.CapacitorNewChargeTime or bp.CapacitorNewDuration or bp.CapacitorNewEnergyDrainPerSecond then
        showCapacitor = true
        showShield = false

        local text = ''
        if bp.CapacitorNewDuration then
            text = text .. tostring(bp.CapacitorNewDuration)
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

    ShowView(showUpKeep, true, showecon, showShield, showCapacitor)
    if time == 0 and energy == 0 and mass == 0 then
        View.BuildCostGroup:Hide()
        View.TimeStat:Hide()
    end
end

--hooked to show/hide capacitor
function Show(bp, buildingUnit, bpID)
    if not CheckFormat() then
        View:Hide()
        return
    end

    -- Name / Description
    LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 10)
    View.UnitShortDesc:SetFont(UIUtil.bodyFont, 14)
    local description = LOC(bp.Description)
    if GetTechLevelString(bp) then
        description = LOCF('Tech %d %s', GetTechLevelString(bp), description)
    end
    if bp.General.UnitName ~= nil then
        View.UnitShortDesc:SetText(LOCF("%s: %s", bp.General.UnitName, description))
    else
        View.UnitShortDesc:SetText(LOCF("%s", description))
    end
    if View.UnitShortDesc:GetStringAdvance(View.UnitShortDesc:GetText()) > View.UnitShortDesc.Width() then
        LayoutHelpers.AtTopIn(View.UnitShortDesc, View, 14)
        View.UnitShortDesc:SetFont(UIUtil.bodyFont, 10)
    end --ok
    local showecon = true
    local showUpKeep = false
    local showAbilities = false
    if buildingUnit ~= nil then
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
    end --changed
        
    -- Health stat
    View.HealthStat.Value:SetText(string.format("%d", bp.Defense.MaxHealth))

    if View.Description then
        WrapAndPlaceText(bp.Air,
            bp.Physics,
            bp.Weapon,
            bp.Display.Abilities,
            LOC(UnitDescriptions[bpID]),
            View.Description)
    end
    local showShield = false
    if bp.Defense.Shield and bp.Defense.Shield.ShieldMaxHealth then
        showShield = true
        View.ShieldStat.Value:SetText(bp.Defense.Shield.ShieldMaxHealth)
    end --changed

    local showCapacitor = false
    if (bp.Display.UIUnitViewOverrides and bp.Display.UIUnitViewOverrides.CapacitorDuration) or (bp.Abilities.Capacitor and bp.Abilities.Capacitor.Duration) then
        showCapacitor = true
        showShield = false
        local text = ''
        if bp.Display.UIUnitViewOverrides and bp.Display.UIUnitViewOverrides.CapacitorDuration then
            text = tostring(bp.Display.UIUnitViewOverrides.CapacitorDuration)
        else
            text = tostring(bp.Abilities.Capacitor.Duration)
        end
        View.CapacitorStat.Value:SetText(text)
    end
    
    local iconName = GameCommon.GetCachedUnitIconFileNames(bp)
    View.UnitImg:SetTexture(iconName)
    View.UnitImg.Height:Set(46)
    View.UnitImg.Width:Set(48)
    
    ShowView(showUpKeep, false, showecon, showShield, showCapacitor)
end
