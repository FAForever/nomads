local oldURL0303 = URL0303

URL0303 = Class(oldURL0303) {

    OnStopBeingBuilt = function(self, builder, layer)
        CWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
        local bp = self:GetBlueprint().Defense.AntiMissile
        self.AntiMissile = MissileRedirect {  -- unit global var so can disable it when stunned
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }
        self.Trash:Add(self.AntiMissile)
    end,

    OnStunned = function(self, duration)
        oldURL0303.OnStunned(self, duration)
        self.AntiMissile:SetEnabled(false)
    end,

    OnStunnedOver = function(self)
        oldURL0303.OnStunnedOver(self)
        self.AntiMissile:SetEnabled(true)
    end,
}

TypeClass = URL0303
