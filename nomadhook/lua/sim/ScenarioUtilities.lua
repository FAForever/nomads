----[                                                                             ]--
----[  File     : ScenarioUtilities.lua                                           ]--
----[  Author(s): Ivan Rumsey                                                     ]--
----[                                                                             ]--
----[  Summary  : Utility functions for use with scenario save file.              ]--
----[             Created from examples provided by Jeff Petkau.                  ]--
----[                                                                             ]--
----[  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.             ]--
local Entity = import('/lua/sim/Entity.lua').Entity
local Factions = import('/lua/factions.lua').GetFactions(true)

-- We replace the original function with this one that supports any faction number, and is also faster, and more robust.

local FactionConversionTable = {
    aeon = {
        uel0203 = 'xal0203',
        uea0305 = 'xaa0305',
    },
    cybran = {
        uea0305 = 'xra0305',
        uel0307 = 'url0306',
    },
    seraphim = {
        uel0106 = 'xsl0201',
    },
    nomads = {
    },
}

function FactionConvert(template, factionIndex)
    local factionKey = Factions[factionIndex].Key
    for i = 3,table.getn(template) do --start from the third item in the list onwards, for whatever reason
        if template[i][1] == FactionConversionTable[factionKey][template[i][1]] then
            template[i][1] = FactionConversionTable[factionKey][template[i][1]]
        else
            --grab first two characters from the faction bp code, we use BuildingIdPrefixes for that.
            local factionKeyString = string.sub((Factions[factionIndex].GAZ_UI_Info.BuildingIdPrefixes[1] or "zzz"),1,2)
            
            --if its a vanilla faction they also contain X and D and other codes in the blueprints so we can convert them too
            if string.sub(factionKeyString,1,1) == "u" then
                --only swap second character
                factionKeyString = "%1"..string.sub(factionKeyString,2,2).."%3"
            else
                --swap first and second characters
                factionKeyString = factionKeyString.."%3"
            end
            
            template[i][1] = string.gsub(template[i][1], "(%w)(%w)(%w%d%d%d%d)", factionKeyString)
        end
        i = i + 1
    end
    return template
end