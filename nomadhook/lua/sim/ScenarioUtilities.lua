local oldFactionConvert = FactionConvert

function FactionConvert(template, factionIndex)
    template = oldFactionConvert(template, factionIndex)
    local i = 3
    while i <= table.getn(template) do
        if factionIndex == 5 then
            if template[i][1] == 'uea0305' then
                template[i][1] = 'ina3006'
            elseif template[i][1] == 'uel0106' then
                template[i][1] = 'inu1007'
            elseif template[i][1] == 'uel0105' then
                template[i][1] = 'inu1001'
            elseif template[i][1] == 'uel0208' then
                template[i][1] = 'inu2001'
            elseif template[i][1] == 'uel0101' then
                template[i][1] = 'inu1002'
            else
                template[i][1] = string.gsub(template[i][1], 'ue', 'in')
            end
        end
        i = i + 1
    end
    return template
end

