-- TODO: REMOVE THIS WHEN GOING TO FINAL VERSION AND NO MORE PROBLEMS FOUND

-- Fixing a problem in FAF that happens when the first returned value is nil. Making sure that doesn't happen.
local oldGetConstructEconomyModel = GetConstructEconomyModel

function GetConstructEconomyModel(builder, targetData, upgradeBaseData)  -- MIND THE ADDITIONAL ARGUMENT!!
    if not targetData.BuildTime or not targetData.BuildCostMass or not targetData.BuildCostEnergy then

        local logdata = { BT = targetData.BuildTime, BCM = targetData.BuildCostMass, BCE = targetData.BuildCostEnergy, }
        local focus = builder:GetFocusUnit()

        if focus then
            if focus.GetUnitId then
                logdata['ID'] = focus:GetUnitId()
            else
                logdata['ID'] = 'unknown'
            end

            if focus:IsUnitState('Enhancing') then
                logdata['Task'] = 'Enhancing'
            elseif focus:IsUnitState('Building') then
                logdata['Task'] = 'Building'
            elseif focus:IsUnitState('Upgrading') then
                logdata['Task'] = 'Upgrading'
            else
                logdata['Task'] = 'other'
            end
        else
            logdata['ID'] = 'unknown'
            logdata['Task'] = 'unknown'
        end
        
        WARN('*NOMADS DEBUG: assisting a construct that lacks GetConstructEconomyModel data. Log data: '..repr(logdata))
    end
    return oldGetConstructEconomyModel(builder, targetData, upgradeBaseData)
end
