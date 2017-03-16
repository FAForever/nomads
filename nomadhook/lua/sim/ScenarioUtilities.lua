local conversionTable = {
    uea0305 = 'ina3006',
    uea0101 = 'ina1001',
    uea0302 = 'ina3001',
    uel0106 = 'inu1007',
    uel0105 = 'inu1001',
    uel0101 = 'inu1002',
    uel0208 = 'inu1005',
    uel0201 = 'inu1004',
    uel0309 = 'inu2001',
    uel0001 = 'inu0001',
    uel0301 = 'inu0301',
}

local oldFactionConvert = FactionConvert

function FactionConvert(template, factionIndex)
    template = oldFactionConvert(template, factionIndex)
    local i = 3
    while i <= table.getn(template) do
        if factionIndex == 5 then
            if conversionTable[template[i][1]] then
                template[i][1] = conversionTable[template[i][1]]
            else
                local old = template[i][1]
                template[i][1] = string.gsub(template[i][1], 'ue', 'in')
                template[i][1] = string.gsub(template[i][1], 'inl', 'inu')
                WARN('Coulndt find a conversion so we tried : ' .. old .. ' => ' .. template[i][1])
            end
        end
        i = i + 1
    end
    return template
end

