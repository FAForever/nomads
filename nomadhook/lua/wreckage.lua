local oldWreckage = Wreckage

---@class Wreckage : oldWreckage
Wreckage = Class(oldWreckage) {

    ---@param self Wreckage
    ---@param instigator Unit
    ---@param amount number
    ---@param vector Vector3
    ---@param damageType string
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

    ---@param self Wreckage
    ---@param instigator Unit
    ---@param amount number
    ---@param vector Vector3 # Unused
    ---@param damageType string # Unused
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
