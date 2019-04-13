-- T3 pgen

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NEnergyCreationUnit = import('/lua/nomadsunits.lua').NEnergyCreationUnit

XNB1301 = Class(NEnergyCreationUnit) {

    ActiveEffectBone = 'effects',
    ActiveEffectTemplateName = 'T3PGAmbient',

    OnStopBeingBuilt = function(self, builder, layer)
        -- antennae lights
        local army, emit = self:GetArmy()
        for k, v in NomadsEffectTemplate.AntennaeLights1 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.001', army, v) )
        end
        for k, v in NomadsEffectTemplate.AntennaeLights3 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.002', army, v) )
        end
        for k, v in NomadsEffectTemplate.AntennaeLights5 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.003', army, v) )
        end
        for k, v in NomadsEffectTemplate.AntennaeLights7 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.004', army, v) )
        end

        NEnergyCreationUnit.OnStopBeingBuilt( self, builder, layer )
    end,
}

TypeClass = XNB1301