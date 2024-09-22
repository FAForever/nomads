local ScriptTask = import('/lua/sim/ScriptTask.lua').ScriptTask
local TASKSTATUS = import('/lua/sim/ScriptTask.lua').TASKSTATUS
local AIRESULT = import('/lua/sim/ScriptTask.lua').AIRESULT

---@class TargetLocation : ScriptTask
TargetLocation = Class(ScriptTask) {

    ---@param self TargetLocation
    StartTask = function(self)
        self.ScriptIsDone = false
        if self:IfBrainAllowsRun() then
            self:ScryLocation()
        else
            self:SetAIResult(AIRESULT.Ignored)
        end
    end,

    ---@param self TargetLocation
    ScryLocation = function(self)
        local unit = self:GetUnit()
        local locations = self.TargetLocations

        for k, loc in locations do
            if loc then
                unit:OnTargetLocation(loc)
                self:SetAIResult(AIRESULT.Success)
            else
                self:SetAIResult(AIRESULT.Fail)
            end
        end

        self.ScriptIsDone = true
    end,

    ---@param self TargetLocation
    ---@return number
    TaskTick = function(self)
        if self.ScriptIsDone then
            return TASKSTATUS.Done
        else
            return TASKSTATUS.Wait
        end
    end,
}
