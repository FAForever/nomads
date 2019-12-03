local ScriptTask = import('/lua/sim/ScriptTask.lua').ScriptTask
local TASKSTATUS = import('/lua/sim/ScriptTask.lua').TASKSTATUS
local AIRESULT = import('/lua/sim/ScriptTask.lua').AIRESULT

NomadsIntelProbe = Class(ScriptTask) {

    StartTask = function(self)
        if self:IfBrainAllowsRun() then
            self:StartCooldown()
            self:IntelProbe()
        else
            self:SetAIResult(AIRESULT.Ignored)
        end
    end,

    IntelProbe = function(self)
        local brain = self:GetAIBrain()
        local data = {
            Lifetime = brain:GetSpecialAbilityParam( self.CommandData.TaskName, 'Lifetime') or self.CommandData.ExtraInfo['Lifetime'] or 60,
        }

        local location = self.TargetLocations[1]
        local unit = self:GetUnit()
        if not unit then self:SetAIResult(AIRESULT.Fail) return end

        --TODO:make this task not fail?
        self.IntelProbeProjectile = unit:RequestProbe(location, 'IntelProbe', data)
        if self.IntelProbeProjectile then
            self:SetAIResult(AIRESULT.Unknown)
        else
            self:SetAIResult(AIRESULT.Fail)
        end
    end,
    
    TaskTick = function(self)
        if self.IntelProbeProjectile and not self.IntelProbeProjectile:BeenDestroyed() then
            return TASKSTATUS.Wait
        else
            self:SetAIResult(AIRESULT.Success)
            return TASKSTATUS.Done
        end
    end,
}
