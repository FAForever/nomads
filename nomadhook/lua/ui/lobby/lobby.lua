
for k, v in FactionData.Factions do
    if not table.find( FACTION_NAMES, v.Key ) then
        table.insert( FACTION_NAMES, table.getn(FACTION_NAMES), v.Key )
    end
end