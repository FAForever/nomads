do

local oldXSA0202 = XSA0202

XSA0202 = Class(oldXSA0202) {
    Weapons = {
        ShleoAAGun01 = Class(SAAShleoCannonWeapon) {
            FxMuzzleFlash = {'/effects/emitters/sonic_pulse_muzzle_flash_02_emit.bp',},
        },
        ShleoAAGun02 = Class(SAAShleoCannonWeapon) {
            FxMuzzleFlash = {'/effects/emitters/sonic_pulse_muzzle_flash_02_emit.bp',},
        },
        Bomb = Class(SDFBombOtheWeapon) {
                
            IdleState = State (SDFBombOtheWeapon.IdleState) {
                Main = function(self)
                    SDFBombOtheWeapon.IdleState.Main(self)
                end,
                
                OnGotTarget = function(self)
                    self.unit:SetBreakOffTriggerMult(2.0)
                    self.unit:SetBreakOffDistanceMult(8.0)
                    self.unit:SetSpeedMult( math.pow(0.67,2) ) -- bug in SetSpeedMult fixed, adjusting value to keep same speed
                    SDFBombOtheWeapon.OnGotTarget(self)
                end,                
            },
        
            OnGotTarget = function(self)
                self.unit:SetBreakOffTriggerMult(2.0)
                self.unit:SetBreakOffDistanceMult(8.0)
                self.unit:SetSpeedMult( math.pow(0.67,2) ) -- bug in SetSpeedMult fixed, adjusting value to keep same speed
                SDFBombOtheWeapon.OnGotTarget(self)
            end,
        
            OnLostTarget = function(self)
                self.unit:SetBreakOffTriggerMult(1.0)
                self.unit:SetBreakOffDistanceMult(1.0)
                self.unit:SetSpeedMult(1.0)
                SDFBombOtheWeapon.OnLostTarget(self)
            end,  	
        },
    },
}

TypeClass = XSA0202

end
