local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1

--- Tech 2 Fighter Bomber
---@class XNA0202 : NAirUnit
XNA0202 = Class(NAirUnit) {
    Weapons = {
	    AGRockets = Class(RocketWeapon1) {

            IdleState = State (RocketWeapon1.IdleState) {
                OnGotTarget = function(self)
                    self.unit:ChangeSpeedFor('GroundAttack')
                    RocketWeapon1.IdleState.OnGotTarget(self)
                end,
            },

            DestroyRecoilManips = function(self)
                RocketWeapon1.DestroyRecoilManips(self)
            end,

            OnGotTarget = function(self)
                self.unit:ChangeSpeedFor('GroundAttack')
                RocketWeapon1.OnGotTarget(self)
            end,

            OnLostTarget = function(self)
                self.unit:ChangeSpeedFor('AirAttack')
                RocketWeapon1.OnLostTarget(self)
            end,
        },
        AARockets = Class(RocketWeapon1) {},
    },

    ---@param self XNA0202
    ---@param reason string
    ChangeSpeedFor = function(self, reason)
        if reason == 'GroundAttack' then
            self:SetBreakOffTriggerMult(2.0)
            self:SetBreakOffDistanceMult(8.0)
            self:SetSpeedMult(0.67)
        else
            self:SetBreakOffTriggerMult(1.0)
            self:SetBreakOffDistanceMult(1.0)
            self:SetSpeedMult(1.0)
        end
    end,

    ---@param self XNA0202
    OnCreate = function(self)
        NAirUnit.OnCreate(self)
        self.Rack2Manip = CreateSlaver(self, 'barrel.002', 'barrel.001')
    end,
}
TypeClass = XNA0202