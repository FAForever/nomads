local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local EnergyCannon1 = import('/lua/nomadsweapons.lua').EnergyCannon1

--- Tech 2 Stationary Artillery
---@class XNB2303 : NStructureUnit
XNB2303 = Class(NStructureUnit) {
    Weapons = {
        MainGun = Class(EnergyCannon1) {},
    },

    ---@param self XNB2303
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self,builder,layer)
        NStructureUnit.OnStopBeingBuilt(self,builder,layer)
        local bp = self.Blueprint
        if bp.Audio.Activate then
            self:PlaySound(bp.Audio.Activate)
        end
    end,
}
TypeClass = XNB2303