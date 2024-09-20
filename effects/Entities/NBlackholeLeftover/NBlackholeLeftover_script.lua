local Prop = import('/lua/sim/Prop.lua').Prop
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')

---@class NBlackholeLeftover : Prop
NBlackholeLeftover = Class(Prop) {

    PermanentFx = NomadsEffectTemplate.BlackholeLeftoverPerm,

    ---@param self NBlackholeLeftover
    OnCreate = function(self)
        Prop.OnCreate(self)
        self.FxScale = 1
        self:ForkThread( self.EffectThread )
        self:SetCanTakeDamage(true)
    end,

    ---@param self NBlackholeLeftover
    OnDestroy = function(self)
        Prop.OnDestroy(self)
    end,

    ---@param self NBlackholeLeftover
    ---@param instigator Unit
    ---@param amount number
    ---@param vector Vector3
    ---@param damageType DamageType
    OnDamage = function(self, instigator, amount, vector, damageType)
        if self.CanTakeDamage then
            Prop.OnDamage(self, instigator, amount, vector, damageType)
        end
    end,

    ---@param self NBlackholeLeftover
    ---@param bool boolean
    SetCanTakeDamage = function(self, bool)
        self.CanTakeDamage = bool
    end,

    ---@param self NBlackholeLeftover
    EffectThread = function(self)
        self.Emitters = EffectUtilities.CreateEffects( self, -1, self.PermanentFx )
        for k, emit in self.Emitters do
            emit:ScaleEmitter( self.FxScale )
            self.Trash:Add( emit )
        end
    end,

    ---@param self NBlackholeLeftover
    ---@param scale number
    ScaleEffects = function(self, scale)
        self.FxScale = scale or 1
        if self.Emitters then
            for k, emit in self.Emitters do
                emit:ScaleEmitter( self.FxScale )
            end
        end
    end,

    ---@param self NBlackholeLeftover
    ---@param scale number
    SetScale = function(self, scale)
        Prop.SetScale( self, scale )
        self:ScaleEffects( scale )
    end,

    ---@param self NBlackholeLeftover
    ---@param fn any
    ---@param ... unknown
    ---@return thread|nil
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