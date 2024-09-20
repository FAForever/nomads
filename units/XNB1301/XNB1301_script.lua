local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NEnergyCreationUnit = import('/lua/nomadsunits.lua').NEnergyCreationUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NEnergyCreationUnit = AddRapidRepair(NEnergyCreationUnit)

--- Tech 3 Power Generator
---@class XNB1301 : NEnergyCreationUnit
XNB1301 = Class(NEnergyCreationUnit) {

    ActiveEffectBone = 'effects',
    ActiveEffectTemplateName = 'T3PGAmbient',

    ---@param self XNB1301
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self, builder, layer)
        -- antennae lights
        for k, v in NomadsEffectTemplate.AntennaeLights1 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.001', self.Army, v) )
        end
        for k, v in NomadsEffectTemplate.AntennaeLights3 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.002', self.Army, v) )
        end
        for k, v in NomadsEffectTemplate.AntennaeLights5 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.003', self.Army, v) )
        end
        for k, v in NomadsEffectTemplate.AntennaeLights7 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.004', self.Army, v) )
        end

        NEnergyCreationUnit.OnStopBeingBuilt( self, builder, layer )
    end,
}
TypeClass = XNB1301