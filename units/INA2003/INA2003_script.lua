-- T2 torpedo gunship

local SupportingArtilleryAbility = import('/lua/nomadsutils.lua').SupportingArtilleryAbility
local AddFlares = import('/lua/nomadsutils.lua').AddFlares
local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local StingrayCannon1 = import('/lua/nomadsweapons.lua').StingrayCannon1
local DroppedTorpedoWeapon1  = import('/lua/nomadsweapons.lua').DroppedTorpedoWeapon1

-- add supporting artillery ability and aa missile flares
NAirUnit = SupportingArtilleryAbility( NAirUnit )
NAirUnit = AddFlares( NAirUnit )

INA2003 = Class(NAirUnit) {
     Weapons = {
        MainGun = Class(StingrayCannon1) {},
        Torpedo = Class(DroppedTorpedoWeapon1) {},
    },

    OnMotionVertEventChange = function( self, new, old )
        NAirUnit.OnMotionVertEventChange( self, new, old )

        -- special abilities only available when on cruising height
        if new == 'Top' then
            -- unit reaching target altitude, coming from surface
            self:EnableArtillerySupport(true)
            self:SetFlaresEnabled(true)
        elseif new == 'Down' then
            -- unit starts landing
            self:EnableArtillerySupport(false)
            self:SetFlaresEnabled(false)
        end
    end,
}

TypeClass = INA2003