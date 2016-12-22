do

local Factions = import('/lua/factions.lua').Factions

local oldAIBrain = AIBrain

AIBrain = Class(oldAIBrain) {

    CreateBrainShared = function(self, planName)
        oldAIBrain.CreateBrainShared(self, planName)

        # set tech 2 and 3 not available for for all tech levels and all factions (remember that Cybran players can command Aeon units by capturing them).
        # wish the game would allow me to simply declare the table i'm making below. Instead it forces me to use several for loops. Sorry for
        # the ugly sollution to that problem. Civilians get all tech for free by the way, that's what defaultVal and the civilian army check is for.
        self.ResearchLevels = {}  # [faction][type][techlevel] => available
        local defaultVal = ArmyIsCivilian(self:GetArmyIndex())

        for k, fact in Factions do
            self.ResearchLevels[ fact.Category ] = {}
            for _, type in { 'LAND', 'AIR', 'NAVAL', 'ENGINEERSTATION', 'GATE', 'SCUFACTORY', } do
                self.ResearchLevels[ fact.Category ][ type ] = {}
                for tl = 1, 4 do
                    self.ResearchLevels[ fact.Category ][ type ][ tl ] = defaultVal
                end
            end
        end
        #LOG('*DEBUG: self.ResearchLevels = '..repr(self.ResearchLevels))
    end,

    GetResearchLevelsForUnit = function(self, unit)
        local faction, type, techlevel = self:GetUnitFactionAndTypeAndTechlevel(unit)
        #LOG('*DEBUG: GetResearchLevelsForUnit '..repr(self.ResearchLevels[ faction ]))
        return self.ResearchLevels[ faction ] or {}
    end,

    OnResearchStationConstructed = function(self, unit)
        # called when a research station unit has been constructed
        #LOG('*DEBUG: OnResearchStationConstructed()')
        if EntityCategoryContains( categories.RESEARCH, unit ) then
            local faction, type, techlevel = self:GetUnitFactionAndTypeAndTechlevel(unit)
            if faction and type and techlevel then
                local unlocked = false   # to see if we need to fire the unlocked event
                for tl = 2, techlevel do
                    unlocked = unlocked or not self.ResearchLevels[ faction ][ type ][ tl ]
                    self.ResearchLevels[ faction ][ type ][ tl ] = true
                    #LOG('*DEBUG: UNlocking tech level '..repr(tl)..' in '..repr(type)..' of faction '..repr(faction))
                end
                if unlocked then
                    self:OnResearchLevelUnlocked(faction, type, techlevel)
                end
                return true
            end
        else
            WARN('*DEBUG: unit does not have RESEARCH category: '..repr(unit:GetUnitId()))
        end
        return false
    end,

    OnResearchStationDestroyed = function(self, unit)
        # called when a research station unit has been destroyed
        #LOG('*DEBUG: OnResearchStationDestroyed()')
        if EntityCategoryContains( categories.RESEARCH, unit ) then
            local faction, type, techlevel = self:GetUnitFactionAndTypeAndTechlevel(unit)
            if faction and type and techlevel then
                # find out our new tech level. If T3 research is destroyed and there's no T2 research we fall back to T1
                while techlevel >= 2 do
                    if not self:HasResearchStation( faction, type, techlevel ) then
                        self.ResearchLevels[ faction ][ type ][ techlevel ] = false
                        self:OnResearchLevelLocked(faction, type, techlevel)
                        #LOG('*DEBUG: locking tech level '..repr(tl)..' in '..repr(type)..' of faction '..repr(faction))
                    else
                        break
                    end
                    techlevel = techlevel - 1
                end
                return true
            end
        else
            WARN('*DEBUG: unit does not have RESEARCH category: '..repr(unit:GetUnitId()))
        end
        return false
    end,

    OnResearchLevelUnlocked = function(self, faction, type, techlevel)
        #LOG('*DEBUG: OnResearchLevelUnlocked f='..repr(faction)..' t='..repr(type)..' tl='..repr(techlevel))
        local catFact = ParseEntityCategory( faction )
        local catList = { categories.FACTORY * catFact, categories.ENGINEER * catFact, }
        for i, cat in catList do
            units = self:GetListOfUnits( cat, false, true)
            for _, unit in units do
                unit:UpdateBuildRestrictions()
            end
        end
    end,

    OnResearchLevelLocked = function(self, faction, type, techlevel)
        #LOG('*DEBUG: OnResearchLevelLocked f='..repr(faction)..' t='..repr(type)..' tl='..repr(techlevel))
        local catFact = ParseEntityCategory( faction )
        local catList = {   categories.FACTORY * catFact, categories.ENGINEER * catFact,   }
        for i, cat in catList do
            units = self:GetListOfUnits( cat, false, true)
            for _, unit in units do
                unit:UpdateBuildRestrictions()
            end
        end
    end,

    GetUnitFactionAndTypeAndTechlevel = function(self, unit)
        local faction, type, techlevel = nil, nil, nil

        # determine faction
        for k, fact in Factions do
            if EntityCategoryContains( ParseEntityCategory( fact.Category ), unit ) then
                faction = fact.Category
                break
            end
        end

        # determine type (land, air, naval)
        if EntityCategoryContains( categories.LAND, unit ) then
            type = 'LAND'
        elseif EntityCategoryContains( categories.AIR, unit ) then
            type = 'AIR'
        elseif EntityCategoryContains( categories.NAVAL, unit ) then
            type = 'NAVAL'
        elseif EntityCategoryContains( categories.ENGINEERSTATION, unit ) then
            type = 'ENGINEERSTATION'
        elseif EntityCategoryContains( categories.GATE, unit ) then
            type = 'GATE'
        elseif EntityCategoryContains( categories.SCUFACTORY, unit ) then
            type = 'SCUFACTORY'
        end

        # determine tech level
        if EntityCategoryContains( categories.TECH1, unit ) then
            techlevel = 1
        elseif EntityCategoryContains( categories.TECH2, unit ) then
            techlevel = 2
        elseif EntityCategoryContains( categories.TECH3, unit ) or EntityCategoryContains( categories.COMMAND, unit ) or EntityCategoryContains( categories.SUBCOMMANDER, unit ) then
            techlevel = 3
        elseif EntityCategoryContains( categories.EXPERIMENTAL, unit ) then
            techlevel = 4
        end

        #LOG('*DEBUG: GetUnitFactionAndTypeAndTechlevel('..repr(unit:GetUnitId())..') faction = '..repr(faction)..' type = '..repr(type)..' techlevel = '..repr(techlevel))

        if not faction or not type or not techlevel then
            #LOG('*DEBUG: couldnt determine faction or techlevel of unit '..repr(unit:GetUnitId())..' , f='..repr(faction)..' t='..repr(type)..' tl='..repr(techlevel))
        end

        return faction, type, techlevel
    end,

    HasResearchStation = function(self, faction, type, techlevel, dontCheckHigherTL)
        # returns true if there's at least 1 research station for the given specs, false otherwise. The parameter dontCheckHigherTL is a bool
        # used to indicate that higher level research is ok too. Say you have a T3 station but no T2 station, then use this to still return
        # true when testing for a T2 station. (This is default behaviour)
        #LOG('*DEBUG: HasResearchStation()')

        local catFact = ParseEntityCategory( faction )
        local catType = ParseEntityCategory( type )
        local units = {}

        if techlevel == 2 then
            units = self:GetListOfUnits( categories.RESEARCH * categories.TECH2 * catFact * catType, false, true)
        elseif techlevel == 3 then
            units = self:GetListOfUnits( categories.RESEARCH * categories.TECH3 * catFact * catType, false, true)
        elseif techlevel == 4 then
            units = self:GetListOfUnits( categories.RESEARCH * categories.EXPERIMENTAL * catFact * catType, false, true)
        end

        if units then
            for _, unit in units do
                if unit and not unit:BeenDestroyed() and not unit:IsDead() and not unit:IsBeingBuilt() then
                    #LOG('*DEBUG: Available! Requested: tech level '..repr(techlevel)..' in '..repr(type)..' of faction '..repr(faction))
                    return true
                end
            end
        end

        # recursively checking for higher techlevels, if parameter was set
        if techlevel>= 1 and techlevel < 4 and not dontCheckHigherTL then
            return self:HasResearchStation(faction, type, techlevel + 1, false)
        end

        #LOG('*DEBUG: NOT available! Requested: tech level '..repr(techlevel)..' in '..repr(type)..' of faction '..repr(faction))
        return false
    end,
}

end