local NEnergyStorageUnit = import('/lua/nomadsunits.lua').NEnergyStorageUnit

--- Tech 1 Energy Storage
---@class XNB1105 : NEnergyStorageUnit
XNB1105 = Class(NEnergyStorageUnit) {

    ---@param self XNB1105
    OnCreate = function(self)
        NEnergyStorageUnit.OnCreate(self)
        self.Trash:Add(CreateStorageManip(self, 'sticks_in', 'ENERGY', 0, 0, 0, 0, 0.75, 0))
    end,

    ---@param self XNB1105
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        if self.TarmacBag.CurrentBP['AlbedoKilled'] then
            self.TarmacBag.CurrentBP.Albedo = self.TarmacBag.CurrentBP.AlbedoKilled
        end
        NEnergyStorageUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = XNB1105