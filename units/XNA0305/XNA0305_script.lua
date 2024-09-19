local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local PlasmaCannon = import('/lua/nomadsweapons.lua').PlasmaCannon
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1

--- Tech 3 Gunship
---@class XNA0305 : NAirUnit
XNA0305 = Class(NAirUnit) {

    Weapons = {
        CannonLeft = Class(PlasmaCannon) {},
        CannonRight = Class(PlasmaCannon) {},
        AAMissile = Class(RocketWeapon1) {},
    },

    BeamHoverExhaustCruise = NomadsEffectTemplate.AirThrusterLargeCruisingBeam,
    BeamHoverExhaustIdle = NomadsEffectTemplate.AirThrusterLargeIdlingBeam,

    ---@param self XNA0305
    OnCreate = function(self)
        NAirUnit.OnCreate(self)
        self.HoverEmitterEffectTrashBag = TrashBag()
        self:HideBone('Radar_Spinny', true)
    end,

    ---@param self XNA0305
    OnDestroy = function(self)
        self:DestroyHoverEmitterEffects()
        NAirUnit.OnDestroy(self)
    end,

    ---@param self XNA0305
    ---@param new any
    ---@param old any
    OnMotionVertEventChange = function( self, new, old )
        NAirUnit.OnMotionVertEventChange( self, new, old )
        self:UpdateHoverEmitter(new, old)

        if new == 'Up' and old == 'Bottom' then
            self:EnableWeapons( 0.5, true, true )
        end

        if new == 'Top' then

        elseif new == 'Down' then

        end
    end,

    ---@param self XNA0305
    ---@param enable boolean
    ---@param delay number
    ---@param groundWeapons boolean
    ---@param airWeapons boolean
    EnableWeapons = function(self, enable, delay, groundWeapons, airWeapons)

        if self.DisableWeaponsThread then
            KillThread( self.DisableWeaponsThread )
            self.DisableWeaponsThread = nil
        end

        local fn = function(self, disable, delay, groundWeapons, airWeapons)
            if delay and delay > 0 then
                WaitSeconds( delay )
            end
            if groundWeapons or true then
                self:SetWeaponEnabledByLabel( 'CannonLeft', enable or true )
                self:SetWeaponEnabledByLabel( 'CannonRight', enable or true )
            end
            if airWeapons or true then
                self:SetWeaponEnabledByLabel( 'AAMissile', enable or true )
            end
            self.DisableWeaponsThread = nil
        end
        self.DisableWeaponsThread = self:ForkThread( (enable == true), delay, groundWeapons, airWeapons )
    end,

    ---@param self XNA0305
    ---@param new any
    ---@param old any # Unused
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

    ---@param self XNA0305
    ---@param large any
    PlayHoverEmitterEffects = function(self, large)
        local beam
        if large then
            beam = CreateBeamEmitterOnEntity(self, 'Hover_Emitter', self.Army, self.BeamHoverExhaustCruise )
        else
            beam = CreateBeamEmitterOnEntity(self, 'Hover_Emitter', self.Army, self.BeamHoverExhaustIdle )
        end
        self.HoverEmitterEffectTrashBag:Add(beam)
        self.Trash:Add(beam)
    end,

    ---@param self XNA0305
    DestroyHoverEmitterEffects = function(self)
        self.HoverEmitterEffectTrashBag:Destroy()
    end,
}
TypeClass = XNA0305