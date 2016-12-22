do


local function Inject(key, units)
    for k, u in units do
        table.insert( restrictedUnits[key].categories, u )
    end
end

Inject('NUKE', {'inb4302'})

#LOG('restrictedUnits = '..repr(restrictedUnits))


end