----[                                                                             ]--
----[  File     : ScenarioUtilities.lua                                           ]--
----[  Author(s): Ivan Rumsey                                                     ]--
----[                                                                             ]--
----[  Summary  : Utility functions for use with scenario save file.              ]--
----[             Created from examples provided by Jeff Petkau.                  ]--
----[                                                                             ]--
----[  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.             ]--
local Entity = import('/lua/sim/Entity.lua').Entity


-- TODO: This really ought to be hooked.... this file needs to be made game agnostic as it's in mohodata

--Rather Scary IfElse trains here, would be great to make it compatible with whatever number of factions.
function FactionConvert(template, factionIndex)
    local i = 3
    while i <= table.getn(template) do
        if factionIndex == 2 then
            if template[i][1] == 'uel0203' then
                template[i][1] = 'xal0203'
            elseif template[i][1] == 'xes0204' then
                template[i][1] = 'xas0204'
            elseif template[i][1] == 'uea0305' then
                template[i][1] = 'xaa0305'
            elseif template[i][1] == 'xel0305' then
                template[i][1] = 'xal0305'
            else
                template[i][1] = string.gsub(template[i][1], 'ue', 'ua')
            end
        elseif factionIndex == 3 then
            if template[i][1] == 'uea0305' then
                template[i][1] = 'xra0305'
            elseif template[i][1] == 'xes0204' then
                template[i][1] = 'xrs0204'
            elseif template[i][1] == 'xes0205' then
                template[i][1] = 'xrs0205'
            elseif template[i][1] == 'xel0305' then
                template[i][1] = 'xrl0305'
            elseif template[i][1] == 'uel0307' then
                template[i][1] = 'url0306'
            elseif template[i][1] == 'del0204' then
                template[i][1] = 'drl0204'
            else
                template[i][1] = string.gsub(template[i][1], 'ue', 'ur')
            end
        elseif factionIndex == 4 then
            if template[i][1] == 'uel0106' then
                template[i][1] = 'xsl0201'
            elseif template[i][1] == 'xel0305' then
                template[i][1] = 'xsl0305'
            else
                template[i][1] = string.gsub(template[i][1], 'ue', 'xs')
            end
        end
        i = i + 1
    end
    return template
end
