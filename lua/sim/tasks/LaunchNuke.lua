local ScriptTask = import('/lua/sim/ScriptTask.lua').ScriptTask
local TASKSTATUS = import('/lua/sim/ScriptTask.lua').TASKSTATUS
local AIRESULT = import('/lua/sim/ScriptTask.lua').AIRESULT

LaunchNuke = Class(ScriptTask) {

    StartTask = function(self)
        self.ScriptIsDone = false
        if not self:IfBrainAllowsRun( self.LaunchMissile ) then
            self:SetAIResult(AIRESULT.Ignored)
        end
    end,

    LaunchMissile = function(self)
        -- making this support 1 location only on purpose. Nuke launchers cannot handle more than 2 IssueNuke commads simultaniously (they get queued)
        local loc = self:GetLocations()[1]
        local unit = self:GetUnit()

        if loc then
            IssueNuke( {unit}, loc )
            self:SetAIResult(AIRESULT.Success)
        else
            self:SetAIResult(AIRESULT.Fail)
        end

        self.ScriptIsDone = true
    end,

    TaskTick = function(self)
        if self.ScriptIsDone then
            return TASKSTATUS.Done
        else
            return TASKSTATUS.Wait
        end
    end,
}
