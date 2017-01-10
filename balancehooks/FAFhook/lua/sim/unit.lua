do

local Factions = import('/lua/factions.lua').Factions

local oldUnit = Unit
Unit = Class(oldUnit) {

-- Code below contains modifications for engy mod in FAF. Fixing the original code so it works with Nomads. Please do not hardcode factions!!!
-- I'm also making it more efficient by storing data in the aibrain object (which is a representation of the player), also making it easier 
-- to read, understand and modify the code.

    OnStopBeingBuilt = function(self, builder, layer)
        -- unit has been constructed. 
        oldUnit.OnStopBeingBuilt(self, builder, layer)

        -- engy mod modifcation
        if EntityCategoryContains(categories.RESEARCH, self) then
            local brain = self:GetAIBrain()
            brain:OnResearchStationConstructed(self)
        end
    end,

    OnCaptured = function(self, captor)
        -- engy mod modifcation
        if EntityCategoryContains(categories.RESEARCH, self) then
            local brain = self:GetAIBrain()
            brain:OnResearchStationDestroyed(self)
        end

        oldUnit.OnCaptured(self, captor)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        -- engy mod modifcation
        if EntityCategoryContains(categories.RESEARCH, self) then
            local brain = self:GetAIBrain()
            brain:OnResearchStationDestroyed(self)
        end

        oldUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnDestroy = function(self)
        -- engy mod modifcation
        if EntityCategoryContains(categories.RESEARCH, self) then
            local brain = self:GetAIBrain()
            brain:OnResearchStationDestroyed(self)
        end

        --LOG('*DEBUG: OnDestroy()')
        oldUnit.OnDestroy(self)
    end,

    updateBuildRestrictions = function(self)  -- For consistency all unit function names should begin with upper case
        return self:UpdateBuildRestrictions()
    end,

    UpdateBuildRestrictions = function(self)
        -- called by many units like engineers and factories to update their build restrictions
        --LOG('*DEBUG: UpdateBuildRestrictions '..repr(self:GetUnitId()))

        local brain = self:GetAIBrain()

        -- code for factories (except quantum gates and SCU factories). Build restrictions are applied as necessary
        if EntityCategoryContains(categories.FACTORY, self) then
            --LOG('*DEBUG: UpdateBuildRestrictions Factory')

            local IsSupportFactory = EntityCategoryContains(categories.SUPPORTFACTORY, self)
            local RL = brain:GetResearchLevelsForUnit(self)

            for type, techlevels in RL do
                --LOG('*DEBUG: type = '..repr(type))

                local catType = ParseEntityCategory( type )

                if techlevels[2] or techlevels[3] then
                    --LOG('*DEBUG: Remove restrictions T2')
                    self:RemoveBuildRestriction(categories.TECH2 * categories.MOBILE * catType)
                    self:RemoveBuildRestriction(categories.TECH2 * categories.MOBILE * categories.CONSTRUCTION)
                    self:RemoveBuildRestriction(categories.TECH2 * categories.FACTORY * categories.SUPPORTFACTORY * catType)
                else
                    --LOG('*DEBUG: Set restrictions T2')
                    if IsSupportFactory then  -- allow queue up higher tier units when the HQ factory is still upgrading
                        self:AddBuildRestriction(categories.TECH2 * categories.MOBILE * catType)
                        -- purposely not adding the CONSTRUCTION category here, else higher tier engineers are not available in support factories
                    end
                    self:AddBuildRestriction(categories.TECH2 * categories.FACTORY * categories.SUPPORTFACTORY * catType)
                end

                if techlevels[3] then
                    --LOG('*DEBUG: Remove restrictions T3')
                    self:RemoveBuildRestriction(categories.TECH3 * categories.MOBILE * catType)
                    self:RemoveBuildRestriction(categories.TECH3 * categories.MOBILE * categories.CONSTRUCTION)
                    self:RemoveBuildRestriction(categories.TECH3 * categories.FACTORY * categories.SUPPORTFACTORY * catType)
                else
                    --LOG('*DEBUG: Set restrictions T3')
                    if IsSupportFactory then  -- allow queue up higher tier units when the HQ factory is still upgrading
                        self:AddBuildRestriction(categories.TECH3 * categories.MOBILE * catType)
                        -- purposely not adding the CONSTRUCTION category here, else higher tier engineers are not available in support factories
                    end
                    self:AddBuildRestriction(categories.TECH3 * categories.FACTORY * categories.SUPPORTFACTORY * catType)
                end
            end
        end

        -- code for engineers. Build restrictions are applied as necessary
        if EntityCategoryContains(categories.ENGINEER, self) then
            --LOG('*DEBUG: UpdateBuildRestrictions Engineer')

            -- Important!! Units that can be enhanced (ACUs, Nomads SCU, ...) should get additional scripting to support this function.

            local RL = brain:GetResearchLevelsForUnit(self)

            for type, techlevels in RL do

                local catType = ParseEntityCategory( type )

                if techlevels[2] or techlevels[3] then
                    self:RemoveBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * catType)
                else
                    self:AddBuildRestriction(categories.TECH2 * categories.SUPPORTFACTORY * catType)
                end

                if techlevels[3] then
                    self:RemoveBuildRestriction(categories.TECH3 * categories.SUPPORTFACTORY * catType)
                else
                    self:AddBuildRestriction(categories.TECH3 * categories.SUPPORTFACTORY * catType)
                end
            end
        end
    end,
}


end