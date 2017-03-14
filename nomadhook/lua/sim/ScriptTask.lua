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

    IsEnabled = function(self, type)
        local brain = self:GetAIBrain()
        return brain:GetSpecialAbilityParam( self.CommandData.TaskName, 'enabled') or false
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

        local params = self:GetParams()
        if not params.DoRangeCheck then
            return true
        end

        -- almost same script as in worldview.lua
        -- checking all rangecheckunits if given location is within range
        local TaskName = self.CommandData.TaskName
        local brain = self:GetAIBrain()
        local RangeCheckUnits = brain:GetSpecialAbilityRangeCheckUnits(TaskName)
        local InRange = false

        if RangeCheckUnits then
            local unit, maxDist, minDist, posU, dist
            for k, unit in RangeCheckUnits do
                maxDist = unit:GetBlueprint().SpecialAbilities[TaskName].MaxRadius
                minDist = 0  -- TODO: minimum radius distance check currently not implemented
                if not maxDist or maxDist < 0 then   -- unlimited range
                    InRange = true
                    break
                elseif maxDist == 0 then             -- skip unit
                    continue
                elseif maxDist > 0 then              -- unit counts towards range check, do check
                    posU = unit:GetPosition()
                    dist = VDist2( posU[1], posU[3], loc[1], loc[3] )
                    InRange = (dist >= minDist and dist <= maxDist)
                    if InRange then
                        break
                    end
                end
            end
        end

        return InRange
    end,

    IfBrainAllowsRun = function(self, fn, arg1, arg2, arg3, arg4, arg5)
        -- checks if the brain allows running this taskscript. If yes, do it. If no, display warning of potential cheating.
        if self:IsEnabled() and not self:IsCoolingDown() then

            -- check range if specified and use it to allow or disallow this
            local ok = true
            local locs = self:GetLocations()
            for _, loc in locs do
                if not self:IsInRange(loc) then
                    ok = false
                    break
                end
            end

            if ok then
                self:StartCooldown()
                fn(self, arg1, arg2, arg3, arg4, arg5)
                return true
            else
                WARN('Army '..repr(self:GetAIBrain():GetArmyIndex())..' tried to invoke task script '..self.CommandData.TaskName..' on a location that is out of range!')
            end
        else
            WARN('Army '..repr(self:GetAIBrain():GetArmyIndex())..' tried to invoke currently unavailable task script '..self.CommandData.TaskName)
        end

        self:SetAIResult(AIRESULT.Fail)
        return false
    end,

    StartCooldown = function(self)
        local params = self:GetParams()
        if params.CoolDownTime and params.CoolDownTime > 0 then
            local tick = GetGameTick() + ( params.CoolDownTime * 10 )    -- 10 because seconds -> ticks
            local brain = self:GetAIBrain()
            brain:SetSpecialAbilityParam( self.CommandData.TaskName, 'CooledDownTick', tick )
            StartAbilityCoolDown( brain:GetArmyIndex(), self.CommandData.TaskName )
        end
    end,

    GetParams = function(self)
        return self.CommandData.ExtraInfo
    end,

    GetLocations = function(self)
        return self.TargetLocations
    end,

    TaskTick = function(self)
        LOG('ScriptTask default TaskTick: aborting and failing task')
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