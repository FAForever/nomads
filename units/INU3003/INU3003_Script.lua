-- T2 EMP tank

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local EMPGun = import('/lua/nomadsweapons.lua').EMPGun


INU3003 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(EMPGun) {
            FxMuzzleFlash = import('/lua/nomadseffecttemplate.lua').EMPGunMuzzleFlash_Tank,
        },
    },
}

TypeClass = INU3003
