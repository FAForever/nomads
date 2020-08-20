-- t3 arillery

local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ArtilleryWeapon = import('/lua/nomadsweapons.lua').ArtilleryWeapon
local Utilities = import('/lua/utilities.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

XNL0304 = Class(NLandUnit) {
    Weapons = {
        ArtilleryGun = Class(ArtilleryWeapon) {
            SetMovingAccuracy = function(self, bool)
                local bp = self:GetBlueprint()
                if bool then
                    self:SetFiringRandomness( bp.FiringRandomnessWhileMoving or (math.max(0, bp.FiringRandomness) * 4) )
                else
                    self:SetFiringRandomness( bp.FiringRandomness )
                end
            end,
        },
    },
    
    OnCreate = function(self)
        NLandUnit.OnCreate(self)
    end,
        
    OnMotionHorzEventChange = function( self, new, old )
        NLandUnit.OnMotionHorzEventChange( self, new, old )
        self:UpdateWeaponAccuracy( (new ~= 'Stopped' and new ~= 'Stopping') )
    end,

    UpdateWeaponAccuracy = function(self, moving)
        if not self.Dead then
            self:GetWeapon(1):SetMovingAccuracy(moving)
        end
    end,
}

TypeClass = XNL0304
