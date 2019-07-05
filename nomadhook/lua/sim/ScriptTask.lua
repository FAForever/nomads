do

-- TaskTick = function(self)
--     return TASKSTATUS.Done
-- end,
-- TASKSTATUS = {
--     Done = -1,
--     Suspend = -2,
--     Abort = -3,
--     Delay = -4,   -- Do other tasks first
--     Repeat = 0,
--     Wait = 1,     -- Waiting for more than 1 tick: TASKSTATUS.Wait + 3 (wait 4 ticks)
-- }
--
-- self:SetAIResult(AIRESULT.Fail)
-- AIRESULT = {
--     Unknown=0,    -- Command in progress; result has not been set yet
--     Success=1,    -- Successfully carried out the order.
--     Fail=2,       -- Failed to carry out the order.
--     Ignored=3,    -- The order made no sense for this type of unit, and was ignored.
-- }

local oldScriptTask = ScriptTask

ScriptTask = Class(oldScriptTask) {

    OnCreate = function(self, commandData)
        --LOG('*DEBUG: ScriptTask data = '..repr(commandData))

        if commandData.ExtraInfo.Targets then
            self.TargetLocations = {}
            self.Targets = {}
            local unit = self:GetUnit()
            local unitId = unit:GetEntityId()

            for _, data in commandData.ExtraInfo.Targets do
                if data.UnitId == unitId then
                    table.insert(self.TargetLocations, data.Position)
                    table.insert(self.Targets, {
                        Position = data.Position,
                        ReticuleId = data.ReticuleId,
                    })
                end
            end

            if table.getsize(self.TargetLocations) < 1 then
                WARN('*DEBUG: ScriptTask: was invoked but no reticule specified for unit '..repr(unit:GetUnitId())..' '..repr(unitId)..' '..repr(commandData))
                self:SetAIResult(AIRESULT.Fail)
            end
        else
            self.TargetLocations = { commandData.Location, }
            self.Targets = {
                Position = commandData.Location,
                ReticuleId = -1,
            }
        end

        -- we don't want scripttasks to use OnCreate (the scripts shouldn't use data from commandData but the functions below). Using StartTask instead.
        local ret = oldScriptTask.OnCreate(self, commandData)
        self:StartTask()
        return ret
    end,

    StartTask = function(self)
    end,

    GetAIBrain = function(self)
        return GetArmyBrain( self:GetArmy() )
    end,

    GetArmy = function(self)
        return self:GetUnit():GetArmy()
    end,

    IsEnabled = function(self)
        local brain = self:GetAIBrain()
        return (brain.BrainSpecialAbilities[self.CommandData.TaskName] ~= nil) or false
    end,

    IsCoolingDown = function(self)
        local brain = self:GetAIBrain()
        local CooledDownTick = brain:GetSpecialAbilityParam( self.CommandData.TaskName, 'CooledDownTick') or -1
        return (GetGameTick() < CooledDownTick)
    end,

    IsInRange = function(self, loc)

        -- this function is run by the engine when in command mode. not sure what it does or how useful it is without the loc argument
        -- (the engine doesn't specify it). Use an alternative in range check. Returning true here is just for the engine.
        if not loc then
            return true
        end

        local params = self.CommandData.ExtraInfo
        if not params.DoRangeCheck then
            return true
        end

        -- should be the same as in worldview.lua --TODO:make sure that is is.
        -- checking all rangecheckunits if given location is within range
        local TaskName = self.CommandData.TaskName
        
        local abilityTable = self:GetAIBrain().UnitSpecialAbilities
        
        local maxDist, minDist, posU, dist
        for unitID, abilityTypes in abilityTable do
            if abilityTypes[TaskName] and (not (abilityTypes[TaskName]['Enabled'] == false)) then
                local unit = GetEntityById(unitID)
                
                maxDist = unit:GetBlueprint().SpecialAbilities[TaskName].MaxRadius
                minDist = 0  -- TODO: check if minradius is currently implemented
                if not maxDist or maxDist < 0 then   -- unlimited range
                    return true
                elseif maxDist == 0 then             -- skip unit
                    continue
                elseif maxDist > 0 then              -- unit counts towards range check, do check
                    posU = unit:GetPosition()
                    dist = VDist2( posU[1], posU[3], loc[1], loc[3] )
                    if (dist >= minDist and dist <= maxDist) then return true end
                end
            end
        end

        return false
    end,


    -- checks if the brain allows running this taskscript. If yes, do it. If no, display warning of potential cheating.
    IfBrainAllowsRun = function(self)
        if self:IsEnabled() and not self:IsCoolingDown() then
            -- check range if specified and use it to allow or disallow this
            local locations = self.TargetLocations
            for _, loc in locations do
                if not self:IsInRange(loc) then
                    WARN('Army '..repr(self:GetAIBrain():GetArmyIndex())..' tried to invoke task script '..self.CommandData.TaskName..' on a location that is out of range!')
                    return false
                end
            end

            return true
        end

        WARN('Army '..repr(self:GetAIBrain():GetArmyIndex())..' tried to invoke currently unavailable task script '..self.CommandData.TaskName)
        self:SetAIResult(AIRESULT.Fail)
        return false
    end,

    StartCooldown = function(self)
        local params = self.CommandData.ExtraInfo
        if params.CoolDownTime and params.CoolDownTime > 0 then
            local tick = GetGameTick() + ( params.CoolDownTime * 10 )    -- 10 because seconds -> ticks
            local brain = self:GetAIBrain()
            brain:SetSpecialAbilityParam( self.CommandData.TaskName, 'CooledDownTick', tick )
            StartAbilityCoolDown( brain:GetArmyIndex(), self.CommandData.TaskName )
        end
    end,

    TaskTick = function(self)
        WARN('ScriptTask default TaskTick: aborting and failing task')
        self:SetAIResult(AIRESULT.Fail)
        return TASKSTATUS.Abort
    end,

    setAIResult = function(self, var)
        self._CurAIResult = var
        return oldScriptTask.setAIResult(var)
    end,

    GetCurrentSetAIResult = function(self)
        return self._CurAIResult or nil
    end,
}

end