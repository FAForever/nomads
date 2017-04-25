do

local oldDRA0202 = DRA0202

DRA0202 = Class(oldDRA0202) {
    Weapons = {
        AntiAirMissiles = Class(CAAMissileNaniteWeapon) {},
        GroundMissile = Class(CIFMissileCorsairWeapon) {

            IdleState = State (CIFMissileCorsairWeapon.IdleState) {
                Main = function(self)
                    CIFMissileCorsairWeapon.IdleState.Main(self)
                end,

                OnGotTarget = function(self)
                    self.unit:SetBreakOffTriggerMult(2.0)
                    self.unit:SetBreakOffDistanceMult(8.0)
                    self.unit:SetSpeedMult( math.pow(0.67,2) ) -- bug in SetSpeedMult fixed, adjusting value to keep same speed
                    CIFMissileCorsairWeapon.IdleState.OnGotTarget(self)
                end,
            },

            OnGotTarget = function(self)
                self.unit:SetBreakOffTriggerMult(2.0)
                self.unit:SetBreakOffDistanceMult(8.0)
                self.unit:SetSpeedMult( math.pow(0.67,2) ) -- bug in SetSpeedMult fixed, adjusting value to keep same speed
                CIFMissileCorsairWeapon.OnGotTarget(self)
            end,

            OnLostTarget = function(self)
                self.unit:SetBreakOffTriggerMult(1.0)
                self.unit:SetBreakOffDistanceMult(1.0)
                self.unit:SetSpeedMult(1.0)
                CIFMissileCorsairWeapon.OnLostTarget(self)
            end,
        },
    },
}

TypeClass = DRA0202

end
