# fighter bomber

local NAirUnit = import('/lua/nomadunits.lua').NAirUnit
local RocketWeapon1 = import('/lua/nomadweapons.lua').RocketWeapon1
local ConcussionBombWeapon = import('/lua/nomadweapons.lua').ConcussionBombWeapon
local DepthChargeBombWeapon1 = import('/lua/nomadweapons.lua').DepthChargeBombWeapon1

INA2002 = Class(NAirUnit) {
    Weapons = {
        Bomb = Class(ConcussionBombWeapon) {

            IdleState = State (ConcussionBombWeapon.IdleState) {
                OnGotTarget = function(self)
                    self.unit:ChangeSpeedFor('GroundAttack')
                    ConcussionBombWeapon.IdleState.OnGotTarget(self)
                end,            
            },

            # Ideally RackSalvoFiringState should be hooked here but that creates errors in the log for some unknown reason. This function
            # is called pretty much immediately in RackSalvoFiringState so this is the next best thing, though not ideal.
            DestroyRecoilManips = function(self)
                ConcussionBombWeapon.DestroyRecoilManips(self)
                self.unit:OnBombDropped('Bomb')
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
        DepthCharge = Class(DepthChargeBombWeapon1) {

            IdleState = State (DepthChargeBombWeapon1.IdleState) {
                OnGotTarget = function(self)
                    self.unit:ChangeSpeedFor('DepthChargeAttack')
                    DepthChargeBombWeapon1.IdleState.OnGotTarget(self)
                end,            
            },

            # Ideally RackSalvoFiringState should be hooked here but that creates errors in the log for some unknown reason. This function
            # is called pretty much immediately in RackSalvoFiringState so this is the next best thing, though not ideal.
            DestroyRecoilManips = function(self)
                DepthChargeBombWeapon1.DestroyRecoilManips(self)
                self.unit:OnBombDropped('DepthCharge')
            end,
        
            OnGotTarget = function(self)
                self.unit:ChangeSpeedFor('GroundAttack')
                DepthChargeBombWeapon1.OnGotTarget(self)
            end,
        
            OnLostTarget = function(self)
                self.unit:ChangeSpeedFor('AirAttack')
                DepthChargeBombWeapon1.OnLostTarget(self)
            end,
        },
        AGRockets = Class(RocketWeapon1) {},
        AARockets = Class(RocketWeapon1) {},
    },

    OnCreate = function(self)
        NAirUnit.OnCreate(self)
        self.Rack2Manip = CreateSlaver(self, 'barrel.002', 'barrel.001')
    end,

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

    GetSpeedModifier = function(self)
        # Copied from CBFP v4, a fix for F/B. Also requires some changes in the weapons above.
        # this returns 1 when the plane has fuel or 0.25 when it doesn't have fuel. The movement speed penalty for
        # running out of fuel is 75% so planes with no fuel fly at 25% of max speed.
        if self:GetFuelRatio() <= 0 then
            return 0.25
        end
        return 1
    end,

    OnBombDropped = function(self, label)
        #LOG('*DEBUG: OnBombDropped '..repr(label))
        local otherWepLabel
        if label == 'DepthCharge' then
            otherWepLabel = 'Bomb'
        else
            otherWepLabel = 'DepthCharge'
        end

        local fn = function(self, label)
            local wep = self:GetWeaponByLabel(label)
            local rof = wep:GetRateOfFire()
            wep:SuspendWeaponFire(true)
            #LOG('*DEBUG: OnBombDropped disabling weapon '..repr(label)..' for '..repr(1/rof)..' seconds')
            WaitSeconds(1/rof)
            #LOG('*DEBUG: OnBombDropped enabling weapon '..repr(label))
            wep:SuspendWeaponFire(false)
        end

        self:ForkThread( fn, otherWepLabel )
    end,
}

TypeClass = INA2002