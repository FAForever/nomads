do

AbilityDefinition = import('/lua/abilitydefinition.lua').abilities


#local OldVerifyScriptCommand = VerifyScriptCommand

function VerifyScriptCommand(data)
    #LOG('USerScriptCommand data = '..repr(data))

    local modeData = CM.GetCommandMode()[2]
    local TaskName = modeData.TaskName
    local abilDef = AbilityDefinition[ TaskName ]

    local result = {
        Behaviour = modeData.Behaviour or 1,
        ExtraInfo = abilDef.ExtraInfo or {},
        Location = data.Target.Position,
        TaskName = TaskName,
        Units = {},
        UnitIds = {},
        UserValidated = false,
    }

    # get units associated with this task
    if abilDef.GetAllUnitsFile then
        result.UnitIds = import(abilDef.GetAllUnitsFile).GetAllUnitsScript( TaskName )
        for k, id in result.UnitIds do
            table.insert( result.Units, GetUnitById(id) )
        end
    elseif modeData.SelectedUnits then
        result.UnitIds = modeData.SelectedUnits
        for k, id in result.UnitIds do
            table.insert( result.Units, GetUnitById(id) )
        end
    end

    # allow customized manipulations
    if abilDef.UserProcessFile then
        result = import(abilDef.UserProcessFile).ProcessUserCommandScript(TaskName, result)
    end

    # reticule things - retrieve from UI, assign a reticule position to a unit, remove excess units from task list
    local ReticulePositions
    local views = import('/lua/ui/game/worldview.lua').GetWorldViews()
    for k, view in views do
        if view:GetAbilityData('Name') == TaskName then
            ReticulePositions = view:GetTargetLocations()
            break
        end
    end
    if ReticulePositions then
        # assign target positions to units and remove excess units. Units are in excess when there's no reticule mapped to them, no need
        # to give them the script command.
        local map
        if abilDef.MapReticulesToUnitIdsFile then
            map = import(abilDef.MapReticulesToUnitIdsFile).MapReticulesToUnitIdsScript(TaskName, ReticulePositions, result.Units, result.UnitIds)
        else
            map = import('/lua/user/tasks/Tasks.lua').MapReticulesToUnitIdsScript(TaskName, ReticulePositions, result.Units, result.UnitIds)
        end
        if map then
            result.UnitIds = {}
            result.Units = {}
            result.ExtraInfo.Targets = {}
            local TargetData = {}
            for RetId, UId in map do
                table.insert(result.ExtraInfo.Targets, {
                    Position = ReticulePositions[RetId],
                    ReticuleId = RetId,
                    UnitId = UId,
                })
                if not table.find(result.UnitIds, UId) then
                    table.insert(result.UnitIds, UId)
                    table.insert(result.Units, GetUnitById(UId))
                end
            end
        end
    end

    # make sure it is verified. If not the UI won't accept the mouse click and forces the user to either alter the order (click in range) or
    # cancel the whole order.
    if abilDef.UserVerifyFile then
        result = import( abilDef.UserVerifyFile ).VerifyScriptCommand( result )
    else
        result = import( '/lua/user/tasks/Tasks.lua' ).VerifyScriptCommand( result )
    end

    if result.Units then   # to prevent game crashes
        result.Units = nil
    end

    #LOG('USerScriptCommand result = '..repr(result))
    return result
end



end
