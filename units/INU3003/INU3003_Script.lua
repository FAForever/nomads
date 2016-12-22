# T2 EMP tank

local AddBombardModeToUnit = import('/lua/nomadutils.lua').AddBombardModeToUnit
local NLandUnit = import('/lua/nomadunits.lua').NLandUnit
local EMPGun = import('/lua/nomadweapons.lua').EMPGun

NLandUnit = AddBombardModeToUnit( NLandUnit )

INU3003 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(EMPGun) {
            FxMuzzleFlash = import('/lua/nomadeffecttemplate.lua').EMPGunMuzzleFlash_Tank,
        },
    },

    SetBombardmentMode = function(self, enable, changedByTransport)
        NLandUnit.SetBombardmentMode(self, enable, changedByTransport)
        self:SetScriptBit('RULEUTC_WeaponToggle', enable)
    end,

    OnScriptBitSet = function(self, bit)
        NLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then 
            NLandUnit.SetBombardmentMode(self, true, false)
        end
    end,

    OnScriptBitClear = function(self, bit)
        NLandUnit.OnScriptBitClear(self, bit)
        if bit == 1 then 
            NLandUnit.SetBombardmentMode(self, false, false)
        end
    end,
}

TypeClass = INU3003