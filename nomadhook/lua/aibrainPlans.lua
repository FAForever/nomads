do
	-- overwriting the stock AIPlansList variable here to create a default aiarchetype for all factions.
	local Factions = import('/lua/factions.lua').GetFactions(true)
	AIPlansList = {}
	for k, v in Factions do
		table.insert( AIPlansList, {'/lua/AI/aiarchetype-managerloader.lua',})
	end
end