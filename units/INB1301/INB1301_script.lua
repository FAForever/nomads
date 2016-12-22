# T3 pgen

local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local NEnergyCreationUnit = import('/lua/nomadunits.lua').NEnergyCreationUnit

INB1301 = Class(NEnergyCreationUnit) {

    ActiveEffectBone = 'effects',
    ActiveEffectTemplateName = 'T3PGAmbient',

    OnStopBeingBuilt = function(self, builder, layer)
        # antennae lights
        local army, emit = self:GetArmy()
        for k, v in NomadEffectTemplate.AntennaeLights1 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.001', army, v) )
        end
        for k, v in NomadEffectTemplate.AntennaeLights3 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.002', army, v) )
        end
        for k, v in NomadEffectTemplate.AntennaeLights5 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.003', army, v) )
        end
        for k, v in NomadEffectTemplate.AntennaeLights7 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.004', army, v) )
        end

        NEnergyCreationUnit.OnStopBeingBuilt( self, builder, layer )
    end,
}

TypeClass = INB1301