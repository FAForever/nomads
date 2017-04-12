-- fighter bomber

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local ConcussionBombWeapon = import('/lua/nomadsweapons.lua').ConcussionBombWeapon

INA2002 = Class(NAirUnit) {
    Weapons = {
        Bomb = Class(ConcussionBombWeapon) {

            IdleState = State (ConcussionBombWeapon.IdleState) {
                OnGotTarget = function(self)
                    self.unit:ChangeSpeedFor('GroundAttack')
                    ConcussionBombWeapon.IdleState.OnGotTarget(self)
                end,
            },

            -- Ideally RackSalvoFiringState should be hooked here but that creates errors in the log for some unknown reason. This function
            -- is called pretty much immediately in RackSalvoFiringState so this is the next best thing, though not ideal.
            DestroyRecoilManips = function(self)
                ConcussionBombWeapon.DestroyRecoilManips(self)
            end,

            OnGotTarget = function(self)
                self.unit:ChangeSpeedFor('GroundAttack')
                ConcussionBombWeapon.OnGotTarget(self)
            end,

            OnLostTarget = function(self)
                self.unit:ChangeSpeedFor('AirAttack')
                ConcussionBombWeapon.OnLostTarget(self)
            end,
        },
        AGRockets = Class(RocketWeapon1) {},
        AARockets = Class(RocketWeapon1) {},
    },
    ChangeSpeedFor = function(self, reason)
    # changes the units speed, ground attacks require a slower aircraft (appearantly)
        if reason == 'GroundAttack' then
            self:SetBreakOffTriggerMult(2.0)
            self:SetBreakOffDistanceMult(8.0)
            self:SetSpeedMult( math.pow(0.67,2) * self:GetSpeedModifier()) # bug in SetSpeedMult fixed, using math.pow to adjust value to keep same speed
        elseif reason == 'DepthChargeAttack' then
            self:SetBreakOffTriggerMult(2.75)
            self:SetBreakOffDistanceMult(12.0)
            self:SetSpeedMult(0.6 * self:GetSpeedModifier()) # the speed multi here is ok, we've already considered the bug is now fixed
        else
            self:SetBreakOffTriggerMult(1.0)
            self:SetBreakOffDistanceMult(1.0)
            self:SetSpeedMult(1.0 * self:GetSpeedModifier())
        end
    end,


    OnCreate = function(self)
        NAirUnit.OnCreate(self)
        self.Rack2Manip = CreateSlaver(self, 'barrel.002', 'barrel.001')
    end,


    GetSpeedModifier = function(self)
        -- Copied from CBFP v4, a fix for F/B. Also requires some changes in the weapons above.
        -- this returns 1 when the plane has fuel or 0.25 when it doesn't have fuel. The movement speed penalty for
        -- running out of fuel is 75% so planes with no fuel fly at 25% of max speed.
        if self:GetFuelRatio() <= 0 then
            return 0.25
        end
        return 1
    end,

}

TypeClass = INA2002