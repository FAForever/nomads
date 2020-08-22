-- T1 frigate

local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local NTogglingUnit = import('/lua/nomadsunits.lua').NTogglingUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local TargetingLaser = import('/lua/kirvesweapons.lua').TargetingLaserInvisible

XNS0104 = Class(NSeaUnit, NTogglingUnit) {
    Weapons = {
        TargetPainter = Class(TargetingLaser) {
            OnWeaponFired = function(self)
                self.unit:SetWeaponAAMode(self.unit:DetermineTargetLayer(self))
                TargetingLaser.OnWeaponFired(self)
            end,
        },
        AAGun1 = Class(RocketWeapon1) {},
        AAGun2 = Class(RocketWeapon1) {},
        ArtilleryGun1 = Class(RocketWeapon1) {},
        ArtilleryGun2 = Class(RocketWeapon1) {},
    },
    
    OnCreate = function(self)
        NSeaUnit.OnCreate(self)
        self:SetScriptBit('RULEUTC_SpecialToggle', true)
        self:SetWeaponAAMode(false)
    end,
    
    EnableSpecialToggle = NTogglingUnit.EnableSpecialToggle,
    DisableSpecialToggle = NTogglingUnit.DisableSpecialToggle,
    --specify how many weapons there are that need toggling - usually its just one pair.
    ToggleWeaponPairs = {{'ArtilleryGun1','AAGun1'},{'ArtilleryGun2','AAGun2'},},
}

TypeClass = XNS0104