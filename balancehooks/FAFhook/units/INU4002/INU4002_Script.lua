do


local NExperimentalHoverLandUnit = import('/lua/nomadsunits.lua').NExperimentalHoverLandUnit

local oldINU4002 = INU4002
INU4002 = Class(oldINU4002) {

    DeathExplosionsOnWaterThread = function( self, overkillRatio, instigator)
        self:ForkThread( self.DeathExplosionsThread, overkillRatio, instigator, false )
        WaitTicks(Random(10, 25))
        NExperimentalHoverLandUnit.DeathThread(self, overkillRatio, instigator)
    end,
}

TypeClass = INU4002


end