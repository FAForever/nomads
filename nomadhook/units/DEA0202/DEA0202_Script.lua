do

local oldDEA0202 = DEA0202

DEA0202 = Class(oldDEA0202) {
    Weapons = {
        RightBeam = Class(TAirToAirLinkedRailgun) {},
        LeftBeam = Class(TAirToAirLinkedRailgun) {},
        Bomb = Class(TIFCarpetBombWeapon) {

            IdleState = State (TIFCarpetBombWeapon.IdleState) {
                Main = function(self)
                    TIFCarpetBombWeapon.IdleState.Main(self)
                end,
                
                OnGotTarget = function(self)
                    self.unit:SetBreakOffTriggerMult(2.0)
                    self.unit:SetBreakOffDistanceMult(8.0)
                    self.unit:SetSpeedMult( math.pow(0.67,2) ) -- bug in SetSpeedMult fixed, adjusting value to keep same speed
                    TIFCarpetBombWeapon.IdleState.OnGotTarget(self)
                end,
                OnFire = function(self)
                    self.unit:RotateWings(self:GetCurrentTarget())
                    TIFCarpetBombWeapon.IdleState.OnFire(self)
                end,                
            },
            
            OnFire = function(self)
                self.unit:RotateWings(self:GetCurrentTarget())
                TIFCarpetBombWeapon.OnFire(self)
            end,
                    
            OnGotTarget = function(self)
                self.unit:SetBreakOffTriggerMult(2.0)
                self.unit:SetBreakOffDistanceMult(8.0)
                self.unit:SetSpeedMult( math.pow(0.67,2) ) -- bug in SetSpeedMult fixed, adjusting value to keep same speed
                TIFCarpetBombWeapon.OnGotTarget(self)
            end,
        
            OnLostTarget = function(self)
                self.unit:SetBreakOffTriggerMult(1.0)
                self.unit:SetBreakOffDistanceMult(1.0)
                self.unit:SetSpeedMult(1.0)
                TIFCarpetBombWeapon.OnLostTarget(self)
            end,        
        },
    },
}

TypeClass = DEA0202

end
