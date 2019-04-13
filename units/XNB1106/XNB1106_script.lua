-- mass storage

local NMassStorageUnit = import('/lua/nomadsunits.lua').NMassStorageUnit

XNB1106 = Class(NMassStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        NMassStorageUnit.OnStopBeingBuilt( self, builder, layer )
        self.Trash:Add( CreateStorageManip( self, 'center', 'MASS', 0, -0.5, 0, 0, 0, 0 ) )
    end,
}

TypeClass = XNB1106