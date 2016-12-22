do



local oldINU3001 = INU3001

INU3001 = Class( oldINU3001 ) {

    CreateEnhancement = function(self, enh)
        oldINU3001.CreateEnhancement(self, enh)
        if enh =='AdvancedEngineering' or  enh =='AdvancedEngineeringRemove' or enh =='T3Engineering' or enh =='T3EngineeringRemove' then
            self:UpdateBuildRestrictions()
        end
    end,

    UpdateBuildRestrictions = function(self)
        oldINU3001.UpdateBuildRestrictions(self)

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

TypeClass = INU3001



end