-- some code for black hole effects. Doesn't support multiple blackholes around the same area because of the boolean but that's ok.

do

local oldProp = Prop

Prop = Class(oldProp) {

    BlackHoleDestroys = true,

    OnCreate = function(self)
        oldProp.OnCreate(self)
        self.BlackholeSuckedIn = false
    end,

    OnDamage = function(self, instigator, amount, direction, damageType)
        if self.CanTakeDamage then
            if damageType == 'BlackholeDamage' or damageType == 'BlackholeDeathNuke' then
                if not self.BlackholeSuckedIn then
                    self.BlackholeSuckedIn = true
                    
                    if instigator.NukeEntity.OnPropBeingSuckedIn then
                        instigator.NukeEntity:OnPropBeingSuckedIn(self)
                    else
                        WARN('could not find instigator nuke entity for prop to be sucked into black hole')
                    end
                    self:OnBlackHoleSuckingIn(instigator)
                end
            end
        end
        oldProp.OnDamage(self, instigator, amount, direction, damageType)
    end,

    OnBlackHoleSuckingIn = function(self, blackhole)
    end,

    OnBlackHoleDissipated = function(self)
        self.BlackholeSuckedIn = false
        if self.BlackHoleDestroys then
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


end