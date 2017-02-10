-- mass storage

local NMassStorageUnit = import('/lua/nomadunits.lua').NMassStorageUnit

INB1106 = Class(NMassStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        NMassStorageUnit.OnStopBeingBuilt( self, builder, layer )
        self.Trash:Add( CreateStorageManip( self, 'center', 'MASS', 0, -0.5, 0, 0, 0, 0 ) )
    end,
}

TypeClass = INB1106