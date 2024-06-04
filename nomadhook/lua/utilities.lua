--just like GetEnemyUnitInSphere but also includes your own army
---@param position number
---@param radius number
---@param unitCats string
---@return table
function GetAllUnitsInSphere(position, radius, unitCats)
    -- New function
    local x1 = position.x - radius
    local y1 = position.y - radius
    local z1 = position.z - radius
    local x2 = position.x + radius
    local y2 = position.y + radius
    local z2 = position.z + radius
    local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )

    local RadEntities = {}

    local cats = unitCats or categories.ALLUNITS
    if UnitsinRec then
        for k, v in UnitsinRec do
            local dist = VDist3(position, v:GetPosition())
            if dist <= radius and EntityCategoryContains(cats, v) then
                table.insert(RadEntities, v)
            end
        end
    end

    return RadEntities
end

---@param position number
---@param radius number
---@param army Army
---@param unitCats string
---@return table
function GetOwnUnitsInSphere(position, radius, army, unitCats)
    if not army then return end
    -- New function
    local x1 = position.x - radius
    local y1 = position.y - radius
    local z1 = position.z - radius
    local x2 = position.x + radius
    local y2 = position.y + radius
    local z2 = position.z + radius
    local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )

    local RadEntities = {}
    
    local cats = unitCats or categories.ALLUNITS
    if UnitsinRec then
        for k, v in UnitsinRec do
            local dist = VDist3(position, v:GetPosition())
            if dist <= radius and army == v.Army and EntityCategoryContains(cats, v) then
                table.insert(RadEntities, v)
            end
        end
    end

    return RadEntities
end

-- Made by [e]Exotic_Retard for Equilibrium balance mod
-- Quite similar in use to get GetTrueEnemyUnitsInSphere, but is more suitable for range finding applications due to terrain heights
---@param unit Unit
---@param position vector
---@param radius number
---@param height number
---@param unitCats string
---@return nil|table
function GetTrueEnemyUnitsInCylinder(unit, position, radius, height, unitCats)
    local x1 = position.x - radius
    local y1 = position.y - radius
    local z1 = position.z - radius
    local x2 = position.x + radius
    local y2 = position.y + radius
    local z2 = position.z + radius
    local UnitsinRec = GetUnitsInRect(Rect(x1, z1, x2, z2))
    local cylHeight = (height or 2*radius)/2
    --actually this is half of the height - the centre of the cyl is at the unit position
    --the stupid looking maths is so you dont perform arithmetic on a nil value

    -- Check for empty rectangle
    if not UnitsinRec then
        return UnitsinRec
    end

    local RadEntities = {}
    local cats = unitCats or categories.ALLUNITS
    for _, v in UnitsinRec do
        local vpos = v:GetPosition()
        local dist = VDist2(position[1], position[3], vpos[1], vpos[3])
        if dist <= radius then --its less cpu time like this or something
            local vdist = math.abs(position[2] - vpos[2])
            local vArmy = v:GetArmy()
            if vdist <= cylHeight and unit.Army ~= vArmy and not IsAlly(unit.Army, vArmy) and EntityCategoryContains(cats, v) then
                table.insert(RadEntities, v)
            end
        end
    end

    return RadEntities
end

---@param entity1 number
---@param entity2 number
---@return nil
function Get2DDistanceBetweenTwoEntities(entity1, entity2)
    local pos1 = entity1:GetPosition()
    local pos2 = entity2:GetPosition()
    return VDist2(pos1[1], pos1[3], pos2[1], pos2[3])
end

--for use in projectile scripts
---@param self any
---@param spread number
---@return vector
RandomOffsetTrackingTarget = function(self, spread)
    local pos = self:GetCurrentTargetPosition()
    pos[1] = pos[1] + GetRandomFloat(-spread,spread)
    pos[3] = pos[3] + GetRandomFloat(-spread,spread)
    pos[2] = GetSurfaceHeight(pos[1], pos[3])
    return pos
end