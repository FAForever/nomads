do



local oldinu0301 = inu0301

inu0301 = Class( oldinu0301 ) {

    CreateEnhancement = function(self, enh)
        oldinu0301.CreateEnhancement(self, enh)
        if enh =='AdvancedEngineering' or  enh =='AdvancedEngineeringRemove' or enh =='T3Engineering' or enh =='T3EngineeringRemove' then
            self:UpdateBuildRestrictions()
        end
    end,

    UpdateBuildRestrictions = function(self)
        oldinu0301.UpdateBuildRestrictions(self)

        local HasT2 = self:HasEnhancement('EngineeringRight') or self:HasEnhancement('EngineeringLeft') or false
        local HasT3 = HasT2

        local brain = self:GetAIBrain()
        local RL = brain:GetResearchLevelsForUnit(self)

        for type, techlevels in RL do

            local catType = ParseEntityCategory( type )

            if HasT2 then
                if techlevels[2] or techlevels[3] then
                    self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * catType)
                else
                    self:AddBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * catType)
                end
            end

            if HasT3 then
                if techlevels[3] then
                    self:RemoveBuildRestriction(categories.TECH3 * categories.SUPPORTFACTORY * catType)
                else
                    self:AddBuildRestriction(categories.TECH3 * categories.SUPPORTFACTORY * catType)
                end
            end

        end
    end,
}

TypeClass = inu0301



end