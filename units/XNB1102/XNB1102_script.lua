-- hydro power plant

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NEnergyCreationUnit = import('/lua/nomadsunits.lua').NEnergyCreationUnit
local AddRapidRepair = import('/lua/nomadsutils.lua').AddRapidRepair

NEnergyCreationUnit = AddRapidRepair(NEnergyCreationUnit)

XNB1102 = Class(NEnergyCreationUnit) {

    ActiveEffectBone = 'exhaust.001',
    ActiveEffectTemplateName = 'T1HydroPowerPlantSurface1',

    DestructionPartsHighToss = { 'exhaust.001', },
    DestructionPartsLowToss = {'exhaust.001', 'exhaust.002', 'exhaust.003', 'exhaust.004', 'exhaust.005', },
    DestructionPartsChassisToss = { 0 },

    PlayActiveEffects = function(self)
        -- adding additional effects on top of the regular active effects

        local effectTemplate = NomadsEffectTemplate.T1HydroPowerPlantSurface2
        local bones = { 'exhaust.002', 'exhaust.003', 'exhaust.004', 'exhaust.005', }

        -- different effects when we're under water
        if self:GetCurrentLayer() == 'Seabed' then
            self.ActiveEffectTemplateName = 'T1HydroPowerPlantSubmerged1'
            effectTemplate = NomadsEffectTemplate.T1HydroPowerPlantSubmerged2
        end

        -- create the emitters
        local emit
        for k, v in effectTemplate do
            for _, bone in bones do
                emit = CreateAttachedEmitter(self, bone, self.Army, v)
                self.ActiveEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
        end

        return NEnergyCreationUnit.PlayActiveEffects(self)
    end,
}

TypeClass = XNB1102