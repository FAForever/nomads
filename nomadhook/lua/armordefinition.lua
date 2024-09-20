-- Adding some Nomads specific armor definitions here. This is done on the fly to make it mod friendly.

-- Helper function
---@param ArmorType string
---@param DamageType DamageType
---@param DmgMulti number
local function InjectDamageMod( ArmorType, DamageType, DmgMulti )
    local armLen = string.len( ArmorType )

    for k, definition in armordefinition do
        if definition[1] == ArmorType then
            table.insert( armordefinition[k], string.format('%s %s', DamageType, DmgMulti) )
        end
    end
end

InjectDamageMod('Experimental', 'EMPMissile', '0.5')

-- ---------------------------
-- Injecting the blackhole damage type to do just as much damage as the deathnuke. This goes through all armor definitions
-- and finds "Deathnuke". When it does a new damage modification is inserted for "BlackholeDeathNuke" with the same modifier
-- as Deathnuke has.

local len = 0
for k, definition in armordefinition do
    for _, w in definition do
        len = string.len( w )
        if len >= 11 then
            if string.sub(w, 1, 9) == 'Deathnuke' then
                table.insert( armordefinition[k], 'BlackholeDeathNuke '..string.sub( w, 11, len ) )
            end
        end
    end
end
len = nil


--LOG('armordefinition = '..repr(armordefinition))