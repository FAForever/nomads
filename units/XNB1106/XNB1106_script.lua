local NMassStorageUnit = import('/lua/nomadsunits.lua').NMassStorageUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NMassStorageUnit = AddRapidRepair(NMassStorageUnit)

--- Tech 1 Mass Storage
---@class XNB1106 : NMassStorageUnit
XNB1106 = Class(NMassStorageUnit) {

    ---@param self XNB1106
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        NMassStorageUnit.OnStopBeingBuilt( self, builder, layer )
        self.Trash:Add( CreateStorageManip( self, 'center', 'MASS', 0, -0.5, 0, 0, 0, 0 ) )
    end,
}
TypeClass = XNB1106