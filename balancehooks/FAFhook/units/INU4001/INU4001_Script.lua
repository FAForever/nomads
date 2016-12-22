do


local NExperimentalHoverLandUnit = import('/lua/nomadunits.lua').NExperimentalHoverLandUnit

local oldINU4001 = INU4001
INU4001 = Class(oldINU4001) {

    DeathExplosionsOnWaterThread = function( self, overkillRatio, instigator)
        self:ForkThread( self.DeathExplosionsThread, overkillRatio, instigator, false )
        WaitTicks(Random(10, 25))
        NExperimentalHoverLandUnit.DeathThread(self, overkillRatio, instigator)
    end,
}

TypeClass = INU4001


end