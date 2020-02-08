local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

NBlackholeEffect02 = Class(NullShell) {

    OnCreate = function(self)
        NullShell.OnCreate(self)
        self:ForkThread(self.EffectThread)
    end,

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

    EffectThread = function(self)
        for k, v in NomadsEffectTemplate.NukeBlackholeDustCloud02 do
            local emit = CreateEmitterOnEntity(self, self.Army, v )
            self.Trash:Add(emit)
        end
    end,
}

TypeClass = NBlackholeEffect02
