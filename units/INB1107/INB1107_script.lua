-- hydro power plant

local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local NEnergyCreationUnit = import('/lua/nomadunits.lua').NEnergyCreationUnit

INB1107 = Class(NEnergyCreationUnit) {

    ActiveEffectBone = 'exhaust.001',
    ActiveEffectTemplateName = 'T1HydroPowerPlantSurface1',

    DestructionPartsHighToss = { 'exhaust.001', },
    DestructionPartsLowToss = {'exhaust.001', 'exhaust.002', 'exhaust.003', 'exhaust.004', 'exhaust.005', },
    DestructionPartsChassisToss = { 'INB1107' },

    PlayActiveEffects = function(self)
        -- adding additional effects on top of the regular active effects

        local effectTemplate = NomadEffectTemplate.T1HydroPowerPlantSurface2
        local bones = { 'exhaust.002', 'exhaust.003', 'exhaust.004', 'exhaust.005', }

        -- different effects when we're under water
        if self:GetCurrentLayer() == 'Seabed' then
            self.ActiveEffectTemplateName = 'T1HydroPowerPlantSubmerged1'
            effectTemplate = NomadEffectTemplate.T1HydroPowerPlantSubmerged2
        end

        -- create the emitters
        local army, emit = self:GetArmy()
        for k, v in effectTemplate do
            for _, bone in bones do
                emit = CreateAttachedEmitter(self, bone, army, v)
                self.ActiveEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
        end

        return NEnergyCreationUnit.PlayActiveEffects(self)
    end,
}

TypeClass = INB1107