local ScriptTask = import('/lua/sim/ScriptTask.lua').ScriptTask
local TASKSTATUS = import('/lua/sim/ScriptTask.lua').TASKSTATUS
local AIRESULT = import('/lua/sim/ScriptTask.lua').AIRESULT
local VoiceOvers = import('/lua/ui/game/voiceovers.lua')

NomadIntelOvercharge = Class(ScriptTask) {
    
    StartTask = function(self)
        self:IfBrainAllowsRun( self.IntelOvercharge )
    end,

    IntelOvercharge = function(self)
        self:GetUnit():IntelOverchargeBeginCharging()
        if self.CommandData.SoundLaunched then
            AddVOEvent(self, self.CommandData.SoundLaunched)
        end
    end,
	  
    TaskTick = function(self)
        self:SetAIResult(AIRESULT.Success)
        return TASKSTATUS.Done
    end,
}
