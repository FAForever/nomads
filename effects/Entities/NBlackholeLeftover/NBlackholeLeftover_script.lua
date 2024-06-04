local Prop = import('/lua/sim/Prop.lua').Prop
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')

---@class NBlackholeLeftover : Prop
NBlackholeLeftover = Class(Prop) {

    PermanentFx = NomadsEffectTemplate.BlackholeLeftoverPerm,

    OnCreate = function(self)
        Prop.OnCreate(self)
        self.FxScale = 1
        self:ForkThread( self.EffectThread )
        self:SetCanTakeDamage(true)
    end,

    OnDestroy = function(self)
        Prop.OnDestroy(self)
    end,

    OnDamage = function(self, instigator, amount, vector, damageType)
        if self.CanTakeDamage then
            Prop.OnDamage(self, instigator, amount, vector, damageType)
        end
    end,

    SetCanTakeDamage = function(self, bool)
        self.CanTakeDamage = bool
    end,

    EffectThread = function(self)
        self.Emitters = EffectUtilities.CreateEffects( self, -1, self.PermanentFx )
        for k, emit in self.Emitters do
            emit:ScaleEmitter( self.FxScale )
            self.Trash:Add( emit )
        end
    end,

    ScaleEffects = function(self, scale)
        self.FxScale = scale or 1
        if self.Emitters then
            for k, emit in self.Emitters do
                emit:ScaleEmitter( self.FxScale )
            end
        end
    end,

    SetScale = function(self, scale)
        Prop.SetScale( self, scale )
        self:ScaleEffects( scale )
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
