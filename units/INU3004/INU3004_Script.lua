-- t3 arillery

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ArtilleryWeapon = import('/lua/nomadsweapons.lua').ArtilleryWeapon
local Utilities = import('/lua/utilities.lua')
local SupportedArtilleryWeapon = import('/lua/nomadsutils.lua').SupportedArtilleryWeapon

local SeraphimWeapons = import('/lua/seraphimweapons.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')  --added for effects

local DirectWeapon = SupportedArtilleryWeapon( ArtilleryWeapon )
ArtilleryWeapon = SupportedArtilleryWeapon( ArtilleryWeapon )


--ArtilleryWeapon = SupportedArtilleryWeapon(ArtilleryWeapon)




INU3004 = Class(NLandUnit) {
    Weapons = {
        SniperGun = Class(DirectWeapon) {
            SetOnTransport = function(self, transportstate)
                ArtilleryGun.SetOnTransport(self, transportstate)
                self.unit:SetScriptBit('RULEUTC_WeaponToggle', false)
            end,
        },
		ArtilleryGun = Class(ArtilleryWeapon) {},
    },
	
	OnCreate = function(self)
        NLandUnit.OnCreate(self)
        self:SetWeaponEnabledByLabel('ArtilleryGun', false)
                
        local bp = self:GetBlueprint().Weapon
        self.ArtilleryRange = bp[1].MaxRadius
        self.SniperRange = bp[2].MaxRadius
    end,
	
	OnScriptBitSet = function(self, bit)
        NLandUnit.OnScriptBitClear(self, bit)
        if bit == 1 then
			local bp = self:GetBlueprint()
            self:SetSpeedMult(bp.Physics.LandSpeedMultiplier * 0.75)
			self:SetWeaponEnabledByLabel('ArtilleryGun', true)
			self:SetWeaponEnabledByLabel('SniperGun', false)
			self:GetWeaponByLabel('TargetTracker'):ChangeMaxRadius(self.SniperRange)
            self:GetWeaponManipulatorByLabel('ArtilleryGun'):SetHeadingPitch(self:GetWeaponManipulatorByLabel('SniperGun'):GetHeadingPitch())
		end
	end,

    OnScriptBitClear = function(self, bit)
		NLandUnit.OnScriptBitSet(self, bit)
        if bit == 1 then
			local bp = self:GetBlueprint()	
            self:SetSpeedMult(bp.Physics.LandSpeedMultiplier)			
			self:SetWeaponEnabledByLabel('ArtilleryGun', false)
			self:SetWeaponEnabledByLabel('SniperGun', true)
			self:GetWeaponByLabel('TargetTracker'):ChangeMaxRadius(self.ArtilleryRange)
            self:GetWeaponManipulatorByLabel('SniperGun'):SetHeadingPitch(self:GetWeaponManipulatorByLabel('ArtilleryGun'):GetHeadingPitch())
		end
	end,
}

TypeClass = INU3004
