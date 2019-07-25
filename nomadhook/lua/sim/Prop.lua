-- some code for black hole effects. Doesn't support multiple blackholes around the same area because of the boolean but that's ok.
local oldProp = Prop
Prop = Class(oldProp) {
    BlackHoleDestroys = true,

    OnDamage = function(self, instigator, amount, direction, damageType)
        if not self.CanTakeDamage then return end

        if damageType == 'BlackholeDamage' or damageType == 'BlackholeDeathNuke' then
            if not self.BlackholeSuckedIn then
                self.BlackholeSuckedIn = true
                instigator.NukeEntity:OnPropBeingSuckedIn(self)
                self:OnBlackHoleSuckingIn(instigator)
            end
        end
        oldProp.OnDamage(self, instigator, amount, direction, damageType)
    end,

    OnBlackHoleSuckingIn = function(self, blackhole)
    end,

    OnBlackHoleDissipated = function(self)
        self.BlackholeSuckedIn = false
        if self.BlackHoleDestroys then
            self:DoPropCallbacks('OnKilled')
            self:Destroy()
        end
    end,

    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,
}
