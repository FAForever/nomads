function GetUnitsInSphere(position, radius)
    # New function
    local x1 = position.x - radius
    local y1 = position.y - radius
    local z1 = position.z - radius
    local x2 = position.x + radius
    local y2 = position.y + radius
    local z2 = position.z + radius
    local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )

    local RadEntities = {}

    if UnitsinRec then
        for k, v in UnitsinRec do
            local dist = VDist3(position, v:GetPosition())
            if dist <= radius then
                table.insert(RadEntities, v)
            end
        end
    end

    return RadEntities
end
