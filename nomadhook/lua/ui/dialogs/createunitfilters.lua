for _,filter in Filters do
    -- Add the nomads faction filters
    if filter.key == 'faction' then
        local nomads = {
                title = 'Nomads',
                key = 'nomads',
                sortFunc = function(unitID)
                    if string.sub(unitID, 2, 2) == 'n' then
                        return true
                    end
                    return false
                end,
            }
        table.insert(filter.choices, 5, nomads) -- after 'seraphim', but before 'operation'
    end

    -- Take into account that nomads land units use 'u' instead of 'l' in their unitID
    if filter.key == 'type' then
        for _,typeChoice in filter.choices do
            if typeChoice.key == 'land' then
                typeChoice.sortFunc = function(unitID)
                        if string.sub(unitID, 3, 3) == 'l' or string.sub(unitID, 3, 3) == 'u' then
                            return true
                        end
                        return false
                    end
            end
        end
    end
end
