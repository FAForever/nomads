do



local oldURL0001 = URL0001

URL0001 = Class( oldURL0001 ) {

    CreateEnhancement = function(self, enh)
        oldURL0001.CreateEnhancement(self, enh)
        if enh =='AdvancedEngineering' or  enh =='AdvancedEngineeringRemove' or enh =='T3Engineering' or enh =='T3EngineeringRemove' then
            self:UpdateBuildRestrictions()
        end
    end,

    UpdateBuildRestrictions = function(self)

        local HasT2 = self:HasEnhancement('AdvancedEngineering') or false
        local HasT3 = self:HasEnhancement('T3Engineering') or false

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

TypeClass = URL0001



end