local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local Utilities = import('/lua/utilities.lua')

-- Upvalue for Perfomance
local CreateRotator = CreateRotator
local WaitSeconds = WaitSeconds
local TrashBagAdd = TrashBag.Add
local MathMax = math.max
local MathMin = math.min
local MathAtan2 = math.atan2




--- Tech 3 Mobile Anti-Air
---@class XNL0302 : NLandUnit
XNL0302 = Class(NLandUnit) {

    Weapons = {
        MainGun = Class(RocketWeapon1) {
            CreateProjectileAtMuzzle = function(self, muzzle)
                RocketWeapon1.CreateProjectileAtMuzzle(self, muzzle)
                self.unit:RotateRevolver()
            end,
        },
    },

    ---@param self XNL0302
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        NLandUnit.OnStopBeingBuilt(self,builder,layer)

        -- set up the revolver. the var 'pause' determines the time the revolver is still, between shots, in seconds
        local pause = 0.2
        local weaponBp = self:GetWeaponByLabel('MainGun').Blueprint
        local trash = self.Trash

        self.RevolverManipSpeed = 90 / ((1 /  weaponBp.RateOfFire) - pause)
        if weaponBp.MuzzleSalvoSize > 1 and weaponBp.MuzzleSalvoDelay >= 0.1 then
             self.RevolverManipSpeed = 90 /  math.max( 0.1, weaponBp.MuzzleSalvoDelay - pause )
        end
        self.RevolverManip = CreateRotator(self, 'Revolver', 'z', 0)

        -- set up rotators for the wheels
        self.TreadBlock01 = CreateRotator(self, 'Wheel_LF', 'y', nil):SetCurrentAngle(0)
        self.TreadBlock02 = CreateRotator(self, 'Wheel_RF', 'y', nil):SetCurrentAngle(0)
        self.TreadBlock03 = CreateRotator(self, 'Wheel_LB', 'y', nil):SetCurrentAngle(0)
        self.TreadBlock04 = CreateRotator(self, 'Wheel_RB', 'y', nil):SetCurrentAngle(0)
        TrashBagAdd(trash,(self.TreadBlock02))
        TrashBagAdd(trash,(self.TreadBlock03))
        TrashBagAdd(trash,(self.TreadBlock01))
        TrashBagAdd(trash,(self.TreadBlock04))
        self:ForkThread(self.TreadManipulationThread)
    end,

    ---@param self XNL0302
    RotateRevolver = function(self)
        local angle = self.RevolverManip:GetCurrentAngle() + 90
        self.RevolverManip:SetGoal( angle ):SetSpeed( self.RevolverManipSpeed )
    end,

    ---@param self XNL0302
    TreadManipulationThread = function(self)
        local GoalAngle = 0
        local nav = self:GetNavigator()
        local maxRot = self.Blueprint.Display.MovementEffects.WheelRotationMax or 45

        while not self.Dead do

            local target = nav:GetCurrentTargetPos()
            local MyPos = self:GetPosition()
            target.y = 0
            target.x = target.x - MyPos.x
            target.z = target.z - MyPos.z
            target = Utilities.NormalizeVector(target)
            GoalAngle = ( MathAtan2( target.x, target.z ) - self:GetHeading() ) * 180 / math.pi

            -- sometimes the angle is more than 180 degrees which makes the wheels rotate in the wrong direction.
            -- subtracting or adding 360 works.
            if GoalAngle > 180 then
                GoalAngle = GoalAngle - 360
            elseif GoalAngle < -180 then
                GoalAngle = GoalAngle + 360
            end

            -- limit rotation to 50 degrees
            GoalAngle = MathMax( -maxRot, MathMin( GoalAngle, maxRot ) )

            self.TreadBlock01:SetSpeed(100)
            self.TreadBlock02:SetSpeed(100)
            self.TreadBlock03:SetSpeed(100)
            self.TreadBlock04:SetSpeed(100)
            self.TreadBlock01:SetGoal(GoalAngle)
            self.TreadBlock02:SetGoal(GoalAngle)
            self.TreadBlock03:SetGoal(GoalAngle)
            self.TreadBlock04:SetGoal(GoalAngle)

            WaitSeconds(0.2)
        end
    end,
}

TypeClass = XNL0302