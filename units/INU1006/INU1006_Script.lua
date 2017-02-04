-- T1 mobile AntiAir / artillery Script

local AddBombardModeToUnit = import('/lua/nomadsutils.lua').AddBombardModeToUnit
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local TargetingLaser = import('/lua/kirvesweapons.lua').TargetingLaserInvisible

NLandUnit = AddBombardModeToUnit(NLandUnit)

INU1006 = Class(NLandUnit) {
    Weapons = {
        TargetPainter = Class(TargetingLaser) {
            -- Unit in range. Cease ground fire and turn on AA
            OnWeaponFired = function(self)
                if not self.AA then
                    self.unit:SetWeaponEnabledByLabel('ArtilleryGun', false)
                    self.unit:SetWeaponEnabledByLabel('AAGun', true)
                    self.unit:GetWeaponManipulatorByLabel('AAGun'):SetHeadingPitch(self.unit:GetWeaponManipulatorByLabel('ArtilleryGun'):GetHeadingPitch())
                    self.AA = true
                end
                TargetingLaser.OnWeaponFired(self)
            end,

            IdleState = State(TargetingLaser.IdleState) {
                -- Start with the AA gun off to reduce twitching of ground fire
                Main = function(self)
                    self.unit:SetWeaponEnabledByLabel('ArtilleryGun', true)
                    self.unit:SetWeaponEnabledByLabel('AAGun', false)
                    self.unit:GetWeaponManipulatorByLabel('ArtilleryGun'):SetHeadingPitch(self.unit:GetWeaponManipulatorByLabel('AAGun'):GetHeadingPitch())
                    self.AA = false
                    TargetingLaser.IdleState.Main(self)
                end,
            },
        },
        AAGun = Class(RocketWeapon1) {},
        ArtilleryGun = Class(RocketWeapon1) {},
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

TypeClass = INU1006