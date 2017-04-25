
function GetUpkeep(bp)
    -- check for UI unitview overrides
    local plusEnergyRate = bp.Display.UIUnitViewOverrides.ProductionPerSecondEnergy
                            or bp.Economy.ProductionPerSecondEnergy
                            or bp.ProductionPerSecondEnergy
    local negEnergyRate = bp.Display.UIUnitViewOverrides.MaintenanceConsumptionPerSecondEnergy
                            or bp.Economy.MaintenanceConsumptionPerSecondEnergy
                            or bp.MaintenanceConsumptionPerSecondEnergy
    local plusMassRate = bp.Display.UIUnitViewOverrides.ProductionPerSecondMass
                            or bp.Economy.ProductionPerSecondMass
                            or bp.ProductionPerSecondMass
    local negMassRate = bp.Display.UIUnitViewOverrides.MaintenanceConsumptionPerSecondMass
                            or bp.Economy.MaintenanceConsumptionPerSecondMass
                            or bp.MaintenanceConsumptionPerSecondMass

    local upkeepEnergy = GetYield(negEnergyRate, plusEnergyRate)
    local upkeepMass = GetYield(negMassRate, plusMassRate)

    return upkeepEnergy, upkeepMass
end

--hooked to show/hide capacitor
local oldShowView = ShowView
function ShowView(showUpKeep, enhancement, showecon, showShield, showCapacitor)
    oldShowView(showUpKeep, enhancement, showecon, showShield)

    --Can only have capacitor or shield, right?
    if showCapacitor then
        View.ShieldStat:SetHidden(true)
    end

    View.CapacitorStat:SetHidden(not showCapacitor)

end


--hooked to show/hide capacitor
local oldShowEnhancement = ShowEnhancement
function ShowEnhancement(bp, bpID, iconID, iconPrefix, userUnit)
    oldShowEnhancement(bp, bpID, iconID, iconPrefix, userUnit)

    local showShield = true
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

    if not showShield then
        View.ShieldStat:SetHidden(true)
    end
    View.CapacitorStat:SetHidden(not showCapacitor)
end

--hooked to show/hide capacitor
local oldShow = Show
function Show(bp, buildingUnit, bpID)
    oldShow(bp, buildingUnit, bpID)

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


    View.CapacitorStat:SetHidden(not showCapacitor)
end
