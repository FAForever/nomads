-- T3 gunship

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local PlasmaCannon = import('/lua/nomadsweapons.lua').PlasmaCannon
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1

XNA0305 = Class(NAirUnit) {

    Weapons = {
        CannonLeft = Class(PlasmaCannon) {},
        CannonRight = Class(PlasmaCannon) {},
        AAMissile = Class(RocketWeapon1) {},
    },

    BeamHoverExhaustCruise = NomadsEffectTemplate.AirThrusterLargeCruisingBeam,
    BeamHoverExhaustIdle = NomadsEffectTemplate.AirThrusterLargeIdlingBeam,

    OnCreate = function(self)
        NAirUnit.OnCreate(self)
        self.HoverEmitterEffectTrashBag = TrashBag()
        self:HideBone('Radar_Spinny', true)
    end,

    OnDestroy = function(self)
        self:DestroyHoverEmitterEffects()
        NAirUnit.OnDestroy(self)
    end,

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

    PlayHoverEmitterEffects = function(self, large)
        local bone, army, beam, beamBP = 'Hover_Emitter', self:GetArmy()
        if large then
            beam = CreateBeamEmitterOnEntity(self, bone, army, self.BeamHoverExhaustCruise )
        else
            beam = CreateBeamEmitterOnEntity(self, bone, army, self.BeamHoverExhaustIdle )
        end
        self.HoverEmitterEffectTrashBag:Add(beam)
        self.Trash:Add(beam)
    end,

    DestroyHoverEmitterEffects = function(self)
        self.HoverEmitterEffectTrashBag:Destroy()
    end,
}

TypeClass = XNA0305