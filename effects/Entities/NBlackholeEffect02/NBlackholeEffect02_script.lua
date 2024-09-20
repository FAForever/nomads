local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

---@class NBlackholeEffect02 : NullShell
NBlackholeEffect02 = Class(NullShell) {

    ---@param self NBlackholeEffect02
    OnCreate = function(self)
        NullShell.OnCreate(self)
        self:ForkThread(self.EffectThread)
    end,

    ---@param self NBlackholeEffect02
    ---@param blackhole any
    ---@param distance Vector3
    SetTrigger = function(self, blackhole, distance)
        local fn = function(self, blackhole, distance)
            WaitTicks(1)
            local cDist = VDist3( self:GetPosition(), blackhole:GetPosition() )
            local pDist = cDist
            while self and blackhole and cDist > distance and pDist >= cDist do
                WaitTicks(1)
                pDist = cDist
                cDist = VDist3( self:GetPosition(), blackhole:GetPosition() )
            end
            self:Destroy()
        end
        self:ForkThread( fn, blackhole, distance )
    end,

    ---@param self NBlackholeEffect02
    EffectThread = function(self)
        for k, v in NomadsEffectTemplate.NukeBlackholeDustCloud02 do
            local emit = CreateEmitterOnEntity(self, self.Army, v )
            self.Trash:Add(emit)
        end
    end,
}
TypeClass = NBlackholeEffect02