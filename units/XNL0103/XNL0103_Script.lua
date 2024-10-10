local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local NTogglingUnit = import('/lua/nomadsunits.lua').NTogglingUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local TargetingLaser = import('/lua/kirvesweapons.lua').TargetingLaserInvisible

--- Tech 1 Mobile Anti-Air/Artillery
---@class XNL0103 : NLandUnit, NTogglingUnit
XNL0103 = Class(NLandUnit, NTogglingUnit) {
    EnableSpecialToggle = NTogglingUnit.EnableSpecialToggle,
    DisableSpecialToggle = NTogglingUnit.DisableSpecialToggle,

    Weapons = {
        TargetPainter = Class(TargetingLaser) {
            OnWeaponFired = function(self)
                local unit = self.unit

                unit:SetWeaponAAMode(unit:DetermineTargetLayer(self))
                TargetingLaser.OnWeaponFired(self)
            end,
        },
        AAGun = Class(RocketWeapon1) {},
        ArtilleryGun = Class(RocketWeapon1) {},
    },

    ---@param self XNL0103
    OnCreate = function(self)
        NLandUnit.OnCreate(self)
        self:SetScriptBit('RULEUTC_SpecialToggle', true)
        self:SetWeaponAAMode(false)
    end,
}
TypeClass = XNL0103