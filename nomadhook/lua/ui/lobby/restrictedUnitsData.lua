do

# TODO: make sure this is up to date

# removing a bug when using the bubbles unit restriction, unit deb4303 doesn't exist. CBFP fix
table.removeByValue(restrictedUnits['BUBBLES'].categories, 'deb4303')

# adding nomad specific restrictions
restrictedUnits['NOMAD'] = {
    categories = {"NOMAD"},
    name = "<LOC restricted_units_Nomads>No Nomads",
    tooltip = "restricted_units_nomads",
}

# injecting nomad unit IDs to unit restriction tables
local function Inject(key, units)
    for k, u in units do
        table.insert( restrictedUnits[key].categories, u )
    end
end
Inject('NUKE', {'inb2305'})
Inject('GAMEENDERS', {'inb2305', 'inb2302'})
Inject('BUBBLES', {'inb4202', 'inb4301', 'inb4205', 'inb4305'})
Inject('INTEL', {'inb3101', 'inb3102', 'inb3201', 'inb3202', 'inb3301', 'inb3302', 'inb4205', 'inb4305'})
Inject('FABS', {'inb1103', 'inb1303'})

local oldSortOrder = sortOrder
sortOrder = {}
for k, v in oldSortOrder do
    table.insert( sortOrder, v )
    if v == 'SERAPHIM' then
        table.insert( sortOrder, 'NOMAD' )
    end
end


#LOG('restrictedUnits = '..repr(restrictedUnits))


end