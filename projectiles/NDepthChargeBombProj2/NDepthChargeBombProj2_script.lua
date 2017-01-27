local DepthChargeBomb = import('/lua/nomadsprojectiles.lua').DepthChargeBomb

NDepthChargeBombs2 = Class(DepthChargeBomb) {

    OnCreate = function(self)
        DepthChargeBomb.OnCreate(self)
        self:SetVelocity(0,-1,0)
    end,
}

TypeClass = NDepthChargeBombs2