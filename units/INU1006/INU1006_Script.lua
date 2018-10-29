-- T1 mobile AntiAir / artillery Script

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local TargetingLaser = import('/lua/kirvesweapons.lua').TargetingLaserInvisible

INU1006 = Class(NLandUnit) {
    Weapons = {
        TargetPainter = Class(TargetingLaser) {
            -- Unit in range. Cease ground fire and turn on AA
            OnWeaponFired = function(self)
                if self.AA == false then
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
                    if self.AA == true or self.AA == nil then
                        self.unit:SetWeaponEnabledByLabel('ArtilleryGun', true)
                        self.unit:SetWeaponEnabledByLabel('AAGun', false)
                        self.unit:GetWeaponManipulatorByLabel('ArtilleryGun'):SetHeadingPitch(self.unit:GetWeaponManipulatorByLabel('AAGun'):GetHeadingPitch())
                        self.AA = false
                    end
                    TargetingLaser.IdleState.Main(self)
                end,
            },
        },
        AAGun = Class(RocketWeapon1) {},
        ArtilleryGun = Class(RocketWeapon1) {},
    },

    OnCreate = function(self)
        NLandUnit.OnCreate(self)
    end,
}

TypeClass = INU1006
