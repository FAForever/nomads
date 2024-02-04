do

local oldMissileRedirect = MissileRedirect
MissileRedirect = Class(MissileRedirect) {
    -- Adding a bit more functionality, mainly needed for disabling this ability when parent unit is EMPed.

    OnCreate = function(self, spec)
        oldMissileRedirect.OnCreate(self, spec)
        self.RecoveryTime = spec.RecoveryTime or 0
        self.Enabled = true
        self.EffectTrashBag = TrashBag()
    end,

    SetEnabled = function(self, enable)
        if enable and not self.Enabled then
            ChangeState(self, self.RecoverState)
            self.Enabled = enable
            self:OnEnabled()
        elseif not enable and self.Enabled then
            ChangeState(self, self.DeactivatedState)
            self.Enabled = enable
            self:OnDisabled()
        end
    end,

    DeactivatedState = State {
        Main = function(self)
            self:DestroyRedirectFx()
        end,

        OnCollisionCheck = function(self, other)
            return false
        end,
    },

    RedirectingState = State {
        Main = function(self)
            if not self or self:BeenDestroyed() or not self.EnemyProj or self.EnemyProj:BeenDestroyed() or not self.Owner or self.Owner.Dead then
                return
            end

            self:PlayRedirectFx()

            if self.Enemy then   -- Set collision to friends active so that when the missile reaches its source it can deal damage.
                self.EnemyProj.DamageData.CollideFriendly = true
                self.EnemyProj.DamageData.DamageFriendly = true
                self.EnemyProj.DamageData.DamageSelf = true
            end

            if self.Enemy and not self.Enemy:BeenDestroyed() then  -- if target lives then return to sender, destroy missile otherwise
                WaitSeconds(1/self.RedirectRateOfFire)
                if not self.EnemyProj:BeenDestroyed() then
                    self.EnemyProj:TrackTarget(false)
                end
            else
                WaitSeconds(1/self.RedirectRateOfFire)
                local vectordam = {}
                vectordam.x = 0
                vectordam.y = 1
                vectordam.z = 0
                self.EnemyProj:DoTakeDamage(self.Owner, 30, vectordam, 'Fire')
            end

            self:DestroyRedirectFx()

            ChangeState(self, self.RecoverState)
        end,

        OnCollisionCheck = function(self, other)
            return false
        end,
    },

    RecoverState = State {  -- A waiting time before being able to fire again
        Main = function(self)
            if self.RecoveryTime > 0 then
                WaitSeconds( self.RecoveryTime )
            end
            ChangeState(self, self.WaitingState)
        end,

        OnCollisionCheck = function(self, other)
            return false
        end,
    },

    OnEnabled = function(self)
    end,

    OnDisabled = function(self)
    end,

    PlayRedirectFx = function(self)
        self:DestroyRedirectFx()

        for k, v in self.RedirectBeams do
            self.EffectTrashBag:Add( AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, self.Army, v) )
        end
    end,

    DestroyRedirectFx = function(self)
        self.EffectTrashBag:Destroy()
    end,
}


end