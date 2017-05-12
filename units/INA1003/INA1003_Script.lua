-- T1 bomber

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local RocketWeapon1Bomber = import('/lua/nomadsweapons.lua').RocketWeapon1Bomber

INA1003 = Class(NAirUnit) {
    Weapons = {
        Rocket1 = Class(RocketWeapon1Bomber) {
            OnGotTarget = function(self)
                local speed = self:GetVelocity()
                if speed[1]^2+speed[3]^2 > 3 then
                    NAirUnit.OnGotTarget(self)
                end
            end
        },
        Rocket2 = Class(RocketWeapon1Bomber) {
            OnGotTarget = function(self)
                local speed = self:GetVelocity()
                if speed[1]^2+speed[3]^2 > 3 then
                    NAirUnit.OnGotTarget(self)
                end
            end
        },
        Rocket3 = Class(RocketWeapon1Bomber) {
            OnGotTarget = function(self)
                local speed = self:GetVelocity()
                if speed[1]^2+speed[3]^2 > 3 then
                    NAirUnit.OnGotTarget(self)
                end
            end
        },
        Rocket4 = Class(RocketWeapon1Bomber) {
            OnGotTarget = function(self)
                local speed = self:GetVelocity()
                if speed[1]^2+speed[3]^2 > 3 then
                    NAirUnit.OnGotTarget(self)
                end
            end
        },
    },
}

TypeClass = INA1003

