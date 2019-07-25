local oldWreckage = Wreckage
Wreckage = Class(oldWreckage) {
    OnDamage = function(self, instigator, amount, vector, damageType)
        if not self.CanTakeDamage then return end

        if damageType == 'BlackholeDamage' or damageType == 'BlackholeDeathNuke' then
            if not self.BlackholeSuckedIn then
                self.BlackholeSuckedIn = true
                instigator.NukeEntity:OnPropBeingSuckedIn(self)
                self:OnBlackHoleSuckingIn(instigator)
            end
        end
        oldWreckage.OnDamage(self, instigator, amount, vector, damageType)
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
        self:AdjustHealth(instigator, -amount)
        local health = self:GetHealth()

        if health <= 0 then 
            if self.BlackholeSuckedIn then
                -- let the black hole script destroy the wreckage
            else
                self:DoPropCallbacks('OnKilled')
                self:Destroy()
            end
        else
            self:UpdateReclaimLeft()
        end
    end,
}
