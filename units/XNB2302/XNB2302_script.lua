-- T3 artillery
--this one is supposed to be N...FactoryUnit to use buildeffects, but for some reason it crashes game, will make buildable effects later, for now i need unit to work
local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local NUtils = import('/lua/nomadsutils.lua')

XNB2302 = Class(NStructureUnit) {
    
    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
    end,
    
    OnDestroy = function(self)
        NStructureUnit.OnDestroy(self)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        NStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    
    OnStopBeingBuilt = function(self, builder, layer)
        NStructureUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}

TypeClass = XNB2302
