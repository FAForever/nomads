-- T2 artillery

local SupportedArtilleryWeapon = import('/lua/nomadsutils.lua').SupportedArtilleryWeapon
local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local EnergyCannon1 = import('/lua/nomadsweapons.lua').EnergyCannon1

EnergyCannon1 = SupportedArtilleryWeapon( EnergyCannon1 )

INB2303 = Class(NStructureUnit) {
    Weapons = {
        MainGun = Class(EnergyCannon1) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
        NStructureUnit.OnStopBeingBuilt(self,builder,layer)
        local bp = self:GetBlueprint()
        if bp.Audio.Activate then
            self:PlaySound(bp.Audio.Activate)
        end
    end,
}

TypeClass = INB2303