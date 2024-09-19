local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local DarkMatterWeapon1 = import('/lua/nomadsweapons.lua').DarkMatterWeapon1
local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit

--- Tech 1 Gunship
---@class XNA0105 : NAirUnit
XNA0105 = Class(NAirUnit) {
    Weapons = {
        Gun1 = Class(DarkMatterWeapon1) {},
        Gun2 = Class(DarkMatterWeapon1) {},
    },

    BeamHoverExhaustCruise = NomadsEffectTemplate.AirThrusterLargeCruisingBeam,
    BeamHoverExhaustIdle = NomadsEffectTemplate.AirThrusterLargeIdlingBeam,

    ---@param self XNA0105
    OnCreate = function(self)
        NAirUnit.OnCreate(self)
        self.HoverEmitterEffectTrashBag = TrashBag()
        self.BarrelAnim = CreateAnimator(self):PlayAnim('/units/XNA0105/XNA0105_Retract.sca'):SetRate(0)
        self.BarrelAnim:SetAnimationFraction(1)
        self.Trash:Add(self.BarrelAnim)
    end,

    ---@param self XNA0105
    OnDestroy = function(self)
        self:DestroyHoverEmitterEffects()
        NAirUnit.OnDestroy(self)
    end,

    ---@param self XNA0105
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self, builder, layer)
        NAirUnit.OnStopBeingBuilt(self, builder, layer)
        self.BarrelAnim:SetRate(-0.5)
        self:ForkThread(self.WatchBarrelAnim, 0.65)
    end,

    ---@param self XNA0105
    ---@param new any
    ---@param old any
    OnMotionVertEventChange = function( self, new, old )
        NAirUnit.OnMotionVertEventChange( self, new, old )
        self:UpdateHoverEmitter(new, old)
    end,

    ---@param self XNA0105
    ---@param fraction number
    WatchBarrelAnim = function(self, fraction)
        while self and not self.Dead and self.BarrelAnim do
            local r = self.BarrelAnim:GetRate()
            local f = self.BarrelAnim:GetAnimationFraction()
            if r == 0 then
                return
            elseif (r > 0 and f >= fraction) or (r < 0 and f <= fraction) then
                self.BarrelAnim:SetRate(0)
                return
            else
                WaitTicks(1)
            end
        end
    end,

    ---@param self XNA0105
    ---@param new any
    ---@param old any #Unused
    UpdateHoverEmitter = function(self, new, old)
        if new == 'Down' then
            self:DestroyHoverEmitterEffects()
            self:PlayHoverEmitterEffects(false)
        elseif new == 'Bottom' then
            self:DestroyHoverEmitterEffects()
        elseif new == 'Up' or new == 'Top' then
            self:DestroyHoverEmitterEffects()
            self:PlayHoverEmitterEffects(true)
        end
    end,

    ---@param self XNA0105
    ---@param large any
    PlayHoverEmitterEffects = function(self, large)
        local beam
        if large then
            beam = CreateBeamEmitterOnEntity(self, 'Thrust_Bottom', self.Army, self.BeamHoverExhaustCruise )
        else
            beam = CreateBeamEmitterOnEntity(self, 'Thrust_Bottom', self.Army, self.BeamHoverExhaustIdle )
        end
        self.HoverEmitterEffectTrashBag:Add(beam)
        self.Trash:Add(beam)
    end,

    ---@param self XNA0105
    DestroyHoverEmitterEffects = function(self)
        self.HoverEmitterEffectTrashBag:Destroy()
    end,
}

TypeClass = XNA0105