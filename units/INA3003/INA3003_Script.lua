-- T3 ASF

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local AirToAirGun1 = import('/lua/nomadsweapons.lua').AirToAirGun1

INA3003 = Class(NAirUnit) {
    Weapons = {
        MainGun = Class(AirToAirGun1) {
            OnStartTracking = function(self, label)
                AirToAirGun1.OnStartTracking(self, label)
                self.unit.animator:SetRate(0.2)
            end,
        
            OnStopTracking = function(self, label)
                AirToAirGun1.OnStopTracking(self, label)
                self.unit.animator:SetRate(-0.2)
            end,
        },
    },

    OnCreate = function(self)
        NAirUnit.OnCreate(self)
        local bp = self:GetBlueprint()
        self.animator = CreateAnimator(self)
        self.Trash:Add(self.animator)
        self.animator:PlayAnim(bp.Display.AnimationOpen, false):SetRate(0)
    end,
}

TypeClass = INA3003