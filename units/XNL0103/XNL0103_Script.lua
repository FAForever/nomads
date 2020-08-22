-- T1 mobile AntiAir / artillery Script

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local NTogglingUnit = import('/lua/nomadsunits.lua').NTogglingUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local TargetingLaser = import('/lua/kirvesweapons.lua').TargetingLaserInvisible

XNL0103 = Class(NLandUnit, NTogglingUnit) {
    Weapons = {
        TargetPainter = Class(TargetingLaser) {
            OnWeaponFired = function(self)
                self.unit:SetWeaponAAMode(self.unit:DetermineTargetLayer(self))
                TargetingLaser.OnWeaponFired(self)
            end,
        },
        AAGun = Class(RocketWeapon1) {},
        ArtilleryGun = Class(RocketWeapon1) {},
    },
    
    OnCreate = function(self)
        NLandUnit.OnCreate(self)
        self:SetScriptBit('RULEUTC_SpecialToggle', true)
        self:SetWeaponAAMode(false)
    end,
    
    EnableSpecialToggle = NTogglingUnit.EnableSpecialToggle,
    DisableSpecialToggle = NTogglingUnit.DisableSpecialToggle,
}

TypeClass = XNL0103