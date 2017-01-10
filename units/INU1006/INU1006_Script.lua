-- T1 mobile AntiAir / artillery Script

local NLandUnit = import('/lua/nomadunits.lua').NLandUnit
local RocketWeapon1 = import('/lua/nomadweapons.lua').RocketWeapon1

INU1006 = Class(NLandUnit) {
    Weapons = {
	AAGun = Class(RocketWeapon1) {
            SetOnTransport = function(self, transportstate)
                RocketWeapon1.SetOnTransport(self, transportstate)
                self.unit:SetScriptBit('RULEUTC_WeaponToggle', true)
            end,
        },
	ArtilleryGun = Class(RocketWeapon1) {},
    },
    
    OnScriptBitSet = function(self, bit)
        NLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
            self:SetWeaponEnabledByLabel('AAGun', false)
        end
    end,

    OnScriptBitClear = function(self, bit)
        NLandUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
            self:SetWeaponEnabledByLabel('AAGun', true)
        end
    end,
}

TypeClass = INU1006