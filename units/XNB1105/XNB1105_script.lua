-- energy storage

local NEnergyStorageUnit = import('/lua/nomadsunits.lua').NEnergyStorageUnit

XNB1105 = Class(NEnergyStorageUnit) {

    OnCreate = function(self)
        NEnergyStorageUnit.OnCreate(self)
        self.Trash:Add(CreateStorageManip(self, 'sticks_in', 'ENERGY', 0, 0, 0, 0, 0.75, 0))
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.TarmacBag.CurrentBP['AlbedoKilled'] then
            self.TarmacBag.CurrentBP.Albedo = self.TarmacBag.CurrentBP.AlbedoKilled
        end
        NEnergyStorageUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = XNB1105