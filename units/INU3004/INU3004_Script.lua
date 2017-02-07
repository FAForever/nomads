-- t3 arillery

local AddBombardModeToUnit = import('/lua/nomadsutils.lua').AddBombardModeToUnit
local SupportedArtilleryWeapon = import('/lua/nomadsutils.lua').SupportedArtilleryWeapon
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ArtilleryWeapon = import('/lua/nomadsweapons.lua').ArtilleryWeapon

NLandUnit = AddBombardModeToUnit(NLandUnit)
ArtilleryWeapon = SupportedArtilleryWeapon( ArtilleryWeapon )

INU3004 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(ArtilleryWeapon) {},
    },

    SetBombardmentMode = function(self, enable, changedByTransport)
        NLandUnit.SetBombardmentMode(self, enable, changedByTransport)
        self:SetScriptBit('RULEUTC_WeaponToggle', enable)
    end,

    OnScriptBitSet = function(self, bit)
        NLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
            self.SetBombardmentMode(self, true, false)
        end
    end,

    OnScriptBitClear = function(self, bit)
        NLandUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
            self.SetBombardmentMode(self, false, false)
        end
    end,
}

TypeClass = INU3004