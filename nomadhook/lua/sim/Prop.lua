-- some code for black hole effects. Doesn't support multiple blackholes around the same area because of the boolean but that's ok.

do

local oldProp = Prop

Prop = Class(oldProp) {

    BlackHoleDestroys = true,

    OnCreate = function(self)
        oldProp.OnCreate(self)
        self.BlackholeSuckedIn = false
    end,

    BlackhHoleCanPropSuckIn = function(self)
        -- some props should not be sucked in, like mass deposits. These have the INVULNERABLE category, so just check
        -- for that. Mass deposit BlueprintId = /env/common/props/massdeposit01_prop.bp and hydrocarbon BlueprintId is
        -- /env/common/props/hydrocarbondeposit01_prop.bp .
        local bp = self:GetBlueprint()
        if bp and bp.Categories and table.find(bp.Categories, 'INVULNERABLE') then
            return false
        end
        return true
    end,

    OnDamage = function(self, instigator, amount, direction, damageType)
        if self:BlackhHoleCanPropSuckIn() then
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