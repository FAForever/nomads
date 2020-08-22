-- overwrite title = 'other faction'
Filters[2].choices[5] = {
    title = 'Nomads',
    key = '3rdParty',
    sortFunc = function(unitID)
        return __blueprints[unitID].CategoriesHash.NOMADS
    end,
}
