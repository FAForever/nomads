local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NEnergyCreationUnit = import('/lua/nomadsunits.lua').NEnergyCreationUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NEnergyCreationUnit = AddRapidRepair(NEnergyCreationUnit)

--- Tech 1 Hydrocarbon Power Plant
---@class XNB1102 : NEnergyCreationUnit
XNB1102 = Class(NEnergyCreationUnit) {

    ActiveEffectBone = 'exhaust.001',
    ActiveEffectTemplateName = 'T1HydroPowerPlantSurface1',

    DestructionPartsHighToss = { 'exhaust.001', },
    DestructionPartsLowToss = {'exhaust.001', 'exhaust.002', 'exhaust.003', 'exhaust.004', 'exhaust.005', },
    DestructionPartsChassisToss = { 0 },

    ---@param self XNB1102
    PlayActiveEffects = function(self)
        -- emitter
        if self.ActiveEffectTemplateName and self.ActiveEffectBone then
            for k, v in NomadsEffectTemplate[ self.ActiveEffectTemplateName ] do
                local emit = CreateAttachedEmitter(self, self.ActiveEffectBone, self.Army, v)
                self.ActiveEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
        end

        -- Sound
        local bp = self.Blueprint
        if bp and bp.Audio and bp.Audio.Activate then
            self:PlaySound( bp.Activate )
        end
    end,
}
TypeClass = XNB1102