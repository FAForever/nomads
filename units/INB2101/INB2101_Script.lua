-- T1 point defense

local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local GattlingWeapon1 = import('/lua/nomadsweapons.lua').GattlingWeapon1
local EffectUtils = import('/lua/effectutilities.lua')
local Effects = import('/lua/effecttemplates.lua')

INB2101 = Class(NStructureUnit) {
    Weapons = { 
        MainGun = Class(GattlingWeapon1) { 
            FxMuzzleScale = 2.25, 
        },
    },
}

TypeClass = INB2101