local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local ArtilleryWeapon = import('/lua/nomadsweapons.lua').ArtilleryWeapon

--- Tech 3 Mobile Artillery
---@class XNL0304 : NLandUnit
XNL0304 = Class(NLandUnit) {
    Weapons = {
        ArtilleryGun = Class(ArtilleryWeapon) {
            SetMovingAccuracy = function(self, bool)
                local bp = self.Blueprint
                if bool then
                    self:SetFiringRandomness( bp.FiringRandomnessWhileMoving or (math.max(0, bp.FiringRandomness) * 4) )
                else
                    self:SetFiringRandomness( bp.FiringRandomness )
                end
            end,
        },
    },

    ---@param self XNL0304
    OnCreate = function(self)
        NLandUnit.OnCreate(self)
    end,

    ---@param self XNL0304
    ---@param new VerticalMovementState
    ---@param old VerticalMovementState
    OnMotionHorzEventChange = function( self, new, old )
        NLandUnit.OnMotionHorzEventChange( self, new, old )
        self:UpdateWeaponAccuracy( (new ~= 'Stopped' and new ~= 'Stopping') )
    end,

    ---@param self XNL0304
    ---@param moving boolean
    UpdateWeaponAccuracy = function(self, moving)
        if not self.Dead then
            self.WeaponInstances[1]:SetMovingAccuracy(moving)
        end
    end,
}
TypeClass = XNL0304