local ScriptTask = import('/lua/sim/ScriptTask.lua').ScriptTask
local TASKSTATUS = import('/lua/sim/ScriptTask.lua').TASKSTATUS
local AIRESULT = import('/lua/sim/ScriptTask.lua').AIRESULT

---@class NomadsAreaBombardment : ScriptTask
NomadsAreaBombardment = Class(ScriptTask) {

    ---@param self NomadsAreaBombardment
    StartTask = function(self)
        self.ScriptIsDone = false
        if self:IfBrainAllowsRun() then
            self:OrbitalStrike()
        else
            self:SetAIResult(AIRESULT.Ignored)
        end
    end,

    ---@param self NomadsAreaBombardment
    OrbitalStrike = function(self)
        local locations = self.TargetLocations
        local unit = self:GetUnit()

        unit:OrbitalStrikeTargets( locations )

        self:SetAIResult(AIRESULT.Success)
        self.ScriptIsDone = true
    end,

    ---@param self NomadsAreaBombardment
    ---@return boolean
    TaskTick = function(self)
        if self.ScriptIsDone then
            return TASKSTATUS.Done
        else
            return TASKSTATUS.Wait
        end
    end,
}
