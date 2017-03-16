function GetBuildingTemplates(name, OrgTemplate)
    local Factions = import('/lua/factions.lua').GetFactions()
    local r = {}
    local n = 1
    for index, faction in Factions do
        if faction.Key == 'uef' then r[n] = OrgTemplate[1]
        elseif faction.Key == 'aeon' then r[n] = OrgTemplate[2]
        elseif faction.Key == 'cybran' then r[n] = OrgTemplate[3]
        elseif faction.Key == 'seraphim' then r[n] = OrgTemplate[4]
        elseif faction.BaseTemplatesFile then r[n] = import(faction.BuildingTemplatesFile)[name]
        else
            WARN('No BuildingTemplatesFile defined in info for faction '..faction.Key)
            r[n] = OrgTemplate[1]
        end
        n = n + 1
    end
    return r
end

BuildingTemplates = GetBuildingTemplates( 'BuildingTemplates', BuildingTemplates )
RebuildStructuresTemplate = GetBuildingTemplates( 'RebuildStructuresTemplate', RebuildStructuresTemplate )