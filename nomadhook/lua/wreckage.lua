do

local oldWreckage = Wreckage

Wreckage = Class(oldWreckage) {

    OnDamage = function(self, instigator, amount, vector, damageType)
        if self:BlackhHoleCanPropSuckIn() then
            if damageType == 'BlackholeDamage' or damageType == 'BlackholeDeathNuke' then
                if not self.BlackholeSuckedIn then
                    self.BlackholeSuckedIn = true
                    instigator:OnPropBeingSuckedIn( self )
                    self:OnBlackHoleSuckingIn(instigator)
                end
            end
        end
        oldWreckage.OnDamage(self, instigator, amount, vector, damageType)
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
        local maxHealth = self:GetMaxHealth()
        self:AdjustHealth(instigator, -amount)
        local health = self:GetHealth()
        if health <= 0 and self.BlackholeSuckedIn then
            -- let the black hole script destroy the wreckage
        else
            oldWreckage.DoTakeDamage(self, instigator, amount, vector, damageType)
        end
    end,
}

end