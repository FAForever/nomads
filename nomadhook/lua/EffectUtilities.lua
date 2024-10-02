-- TODO: go through this

---@param unit Unit
---@param adjacentUnit Unit
---@param AdjacencyBeamsBag TrashBag
function CreateAdjacencyBeams( unit, adjacentUnit, AdjacencyBeamsBag )

    local info = {
        Unit = adjacentUnit,
        Trash = TrashBag(),
    }

    table.insert(AdjacencyBeamsBag, info)

    local uBp = unit.Blueprint
    local aBp = adjacentUnit.Blueprint
    local faction = uBp.General.FactionName

    -- Determine which effects we will be using
    local nodeMesh = nil
    local beamEffect = nil
    local emitterNodeEffects = {}
    local numNodes = 2
    local nodeList = {}
    local validAdjacency = true


    local unitPos = unit:GetPosition()
    local adjPos = adjacentUnit:GetPosition()

    -- Create hub start/end and all midpoint nodes
    local unitHub = {
        entity = Entity{},
        pos = unit:GetPosition(),
    }
    local adjacentHub = {
        entity = Entity{},
        pos = adjacentUnit:GetPosition(),
    }

    local spec = {
        Owner = unit,
    }

    if faction == 'Aeon' then
        nodeMesh = '/effects/entities/aeonadjacencynode/aeonadjacencynode_mesh'
        beamEffect = '/effects/emitters/adjacency_aeon_beam_0' .. util.GetRandomInt(1,3) .. '_emit.bp'
        numNodes = 3
    elseif faction == 'Cybran' then
        nodeMesh = '/effects/entities/cybranadjacencynode/cybranadjacencynode_mesh'
        beamEffect = '/effects/emitters/adjacency_cybran_beam_01_emit.bp'
    elseif faction == 'UEF' then
        nodeMesh = '/effects/entities/uefadjacencynode/uefadjacencynode_mesh'
        beamEffect = '/effects/emitters/adjacency_uef_beam_01_emit.bp'


    elseif faction == 'Nomads' then
        nodeMesh = '/effects/Entities/NomadsAdjacencyNode/NmdAdjacencyNode_mesh'
        beamEffect = '/effects/emitters/nomads_adjacency_beam.bp'
    elseif faction == 'Seraphim' then
        nodeMesh = '/effects/entities/seraphimadjacencynode/seraphimadjacencynode_mesh'
        table.insert( emitterNodeEffects, EffectTemplate.SAdjacencyAmbient01 )
        if  util.GetDistanceBetweenTwoVectors( unitHub.pos, adjacentHub.pos ) < 2.5 then
            numNodes = 1
        else
            numNodes = 3
            table.insert( emitterNodeEffects, EffectTemplate.SAdjacencyAmbient02 )
            table.insert( emitterNodeEffects, EffectTemplate.SAdjacencyAmbient03 )
        end
    end

    for i = 1, numNodes do
        local node =
        {
            entity = Entity(spec),
            pos = {0,0,0},
            mesh = nil,
        }
        node.entity:SetVizToNeutrals('Intel')
        node.entity:SetVizToEnemies('Intel')
        table.insert( nodeList, node )
    end

    local verticalOffset = 0.05

    -- Move Unit Pos towards adjacent unit by bounding box size
    local uBpSizeX = uBp.SizeX * 0.5
    local uBpSizeZ = uBp.SizeZ * 0.5
    local aBpSizeX = aBp.SizeX * 0.5
    local aBpSizeZ = aBp.SizeZ * 0.5

    -- To Determine positioning, need to use the bounding box or skirt size
    local uBpSkirtX = uBp.Physics.SkirtSizeX * 0.5
    local uBpSkirtZ = uBp.Physics.SkirtSizeZ * 0.5
    local aBpSkirtX = aBp.Physics.SkirtSizeX * 0.5
    local aBpSkirtZ = aBp.Physics.SkirtSizeZ * 0.5

    -- Get edge corner positions, { TOP, LEFT, BOTTOM, RIGHT }
    local unitSkirtBounds = {
        unitHub.pos[3] - uBpSkirtZ,
        unitHub.pos[1] - uBpSkirtX,
        unitHub.pos[3] + uBpSkirtZ,
        unitHub.pos[1] + uBpSkirtX,
    }
    local adjacentSkirtBounds = {
        adjacentHub.pos[3] - aBpSkirtZ,
        adjacentHub.pos[1] - aBpSkirtX,
        adjacentHub.pos[3] + aBpSkirtZ,
        adjacentHub.pos[1] + aBpSkirtX,
    }

    -- Figure out the best matching ogrid position on units bounding box
    -- depending on it's skirt size

    -- Unit bottom or top skirt is aligned to adjacent unit
    if (unitSkirtBounds[3] == adjacentSkirtBounds[1]) or (unitSkirtBounds[1] == adjacentSkirtBounds[3]) then

        local sharedSkirtLower = unitSkirtBounds[4] - (unitSkirtBounds[4] - adjacentSkirtBounds[2])
        local sharedSkirtUpper = unitSkirtBounds[4] - (unitSkirtBounds[4] - adjacentSkirtBounds[4])
        local sharedSkirtLen = sharedSkirtUpper - sharedSkirtLower

        -- Depending on shared skirt bounds, determine the position of unit hub
        -- Find out how many times the shared skirt fits into the unit hub shared skirt
        local numAdjSkirtsOnUnitSkirt = (uBpSkirtX * 2) / sharedSkirtLen
        local numUnitSkirtsOnAdjSkirt = (aBpSkirtX * 2) / sharedSkirtLen

         -- Z-offset, offset adjacency hub positions the proper direction
        if unitSkirtBounds[3] == adjacentSkirtBounds[1] then
            unitHub.pos[3] = unitHub.pos[3] + uBpSizeZ                                                        
            adjacentHub.pos[3] = adjacentHub.pos[3] - aBpSizeZ
        else -- unitSkirtBounds[1] == adjacentSkirtBounds[3]
            unitHub.pos[3] = unitHub.pos[3] - uBpSizeZ
            adjacentHub.pos[3] = adjacentHub.pos[3] + aBpSizeZ
        end

        -- X-offset, Find the shared adjacent x position range
        -- If we have more than skirt on this section, then we need to adjust the x position of the unit hub
        if numAdjSkirtsOnUnitSkirt > 1 or numUnitSkirtsOnAdjSkirt < 1 then
            local uSkirtLen = (unitSkirtBounds[4] - unitSkirtBounds[2]) * 0.5           -- Unit skirt length
            local uGridUnitSize = (uBpSizeX * 2) / uSkirtLen                            -- Determine one grid of adjacency along that length
            local xoffset = math.abs(unitSkirtBounds[2] - adjacentSkirtBounds[2]) * 0.5 -- Get offset of the unit along the skirt
            unitHub.pos[1] = (unitHub.pos[1] - uBpSizeX) + (xoffset * uGridUnitSize) + (uGridUnitSize * 0.5) -- Now offset the position of adjacent point
        end

        -- If we have more than skirt on this section, then we need to adjust the x position of the adjacent hub
        if numUnitSkirtsOnAdjSkirt > 1  or numAdjSkirtsOnUnitSkirt < 1 then
            local aSkirtLen = (adjacentSkirtBounds[4] - adjacentSkirtBounds[2]) * 0.5   -- Adjacent unit skirt length
            local aGridUnitSize = (aBpSizeX * 2) / aSkirtLen                            -- Determine one grid of adjacency along that length ??
            local xoffset = math.abs(adjacentSkirtBounds[2] - unitSkirtBounds[2]) * 0.5    -- Get offset of the unit along the adjacent unit
            adjacentHub.pos[1] = (adjacentHub.pos[1] - aBpSizeX) + (xoffset * aGridUnitSize) + (aGridUnitSize * 0.5) -- Now offset the position of adjacent point
        end

    -- Unit right or top left is aligned to adjacent unit
    elseif (unitSkirtBounds[4] == adjacentSkirtBounds[2]) or (unitSkirtBounds[2] == adjacentSkirtBounds[4]) then

        local sharedSkirtLower = unitSkirtBounds[3] - (unitSkirtBounds[3] - adjacentSkirtBounds[1])
        local sharedSkirtUpper = unitSkirtBounds[3] - (unitSkirtBounds[3] - adjacentSkirtBounds[3])
        local sharedSkirtLen = sharedSkirtUpper - sharedSkirtLower

        -- Depending on shared skirt bounds, determine the position of unit hub
        -- Find out how many times the shared skirt fits into the unit hub shared skirt
        local numAdjSkirtsOnUnitSkirt = (uBpSkirtX * 2) / sharedSkirtLen
        local numUnitSkirtsOnAdjSkirt = (aBpSkirtX * 2) / sharedSkirtLen
        
        -- X-offset
        if (unitSkirtBounds[4] == adjacentSkirtBounds[2]) then
            unitHub.pos[1] = unitHub.pos[1] + uBpSizeX
            adjacentHub.pos[1] = adjacentHub.pos[1] - aBpSizeX
        else -- unitSkirtBounds[2] == adjacentSkirtBounds[4]
            unitHub.pos[1] = unitHub.pos[1] - uBpSizeX
            adjacentHub.pos[1] = adjacentHub.pos[1] + aBpSizeX
        end

        -- Z-offset, Find the shared adjacent x position range
        -- If we have more than skirt on this section, then we need to adjust the x position of the unit hub
        if numAdjSkirtsOnUnitSkirt > 1 or numUnitSkirtsOnAdjSkirt < 1 then
            local uSkirtLen = (unitSkirtBounds[3] - unitSkirtBounds[1]) * 0.5           -- Unit skirt length
            local uGridUnitSize = (uBpSizeZ * 2) / uSkirtLen                            -- Determine one grid of adjacency along that length
            local zoffset = math.abs(unitSkirtBounds[1] - adjacentSkirtBounds[1]) * 0.5 -- Get offset of the unit along the skirt
            unitHub.pos[3] = (unitHub.pos[3] - uBpSizeZ) + (zoffset * uGridUnitSize) + (uGridUnitSize * 0.5) -- Now offset the position of adjacent point
        end

        -- If we have more than skirt on this section, then we need to adjust the x position of the adjacent hub
        if numUnitSkirtsOnAdjSkirt > 1 or numAdjSkirtsOnUnitSkirt < 1 then
            local aSkirtLen = (adjacentSkirtBounds[3] - adjacentSkirtBounds[1]) * 0.5   -- Adjacent unit skirt length
            local aGridUnitSize = (aBpSizeZ * 2) / aSkirtLen                            -- Determine one grid of adjacency along that length ??
            local zoffset = math.abs(adjacentSkirtBounds[1] - unitSkirtBounds[1]) * 0.5    -- Get offset of the unit along the adjacent unit
            adjacentHub.pos[3] = (adjacentHub.pos[3] - aBpSizeZ) + (zoffset * aGridUnitSize) + (aGridUnitSize * 0.5) -- Now offset the position of adjacent point
        end
    end

    -- Setup our midpoint positions
    if faction == 'Aeon' or faction == 'Seraphim' then
        local DirectionVec = util.GetDifferenceVector( unitHub.pos, adjacentHub.pos )
        local Dist = util.GetDistanceBetweenTwoVectors( unitHub.pos, adjacentHub.pos )
        local PerpVec = util.Cross( DirectionVec, Vector(0,0.35,0) )
        local segmentLen = 1 / (numNodes + 1)
        local halfDist = Dist * 0.5

        if util.GetRandomInt(0,1) == 1 then
            PerpVec[1] = -PerpVec[1]
            PerpVec[2] = -PerpVec[2]
            PerpVec[3] = -PerpVec[3]
        end

        local offsetMul = 0.15

        for i = 1, numNodes do
            local segmentMul = i * segmentLen

            if segmentMul <= 0.5 then
                offsetMul = offsetMul + 0.12
            else
                offsetMul = offsetMul - 0.12
            end

            nodeList[i].pos = {
                unitHub.pos[1] - (DirectionVec[1] * segmentMul) - (PerpVec[1] * offsetMul),
                nil,
                unitHub.pos[3] - (DirectionVec[3] * segmentMul) - (PerpVec[3] * offsetMul),
            }
        end
    elseif faction == 'Cybran' then
        if (unitPos[1] == adjPos[1]) or (unitPos[3] == adjPos[3]) then
            local Dist = util.GetDistanceBetweenTwoVectors( unitHub.pos, adjacentHub.pos )
            local DirectionVec = util.GetScaledDirectionVector( unitHub.pos, adjacentHub.pos, util.GetRandomFloat(0.35, Dist * 0.48) )
            DirectionVec[2] = 0
            local PerpVec = util.Cross( DirectionVec, Vector(0,util.GetRandomFloat(0.2, 0.35),0) )

            if util.GetRandomInt(0,1) == 1 then
                PerpVec[1] = -PerpVec[1]
                PerpVec[2] = -PerpVec[2]
                PerpVec[3] = -PerpVec[3]
            end

            -- Initialize 2 midpoint segments
            nodeList[1].pos = { unitHub.pos[1] - DirectionVec[1], unitHub.pos[2] - DirectionVec[2], unitHub.pos[3] - DirectionVec[3] }
            nodeList[2].pos = { adjacentHub.pos[1] + DirectionVec[1], adjacentHub.pos[2] + DirectionVec[2], adjacentHub.pos[3] + DirectionVec[3] }

            -- Offset beam positions
            nodeList[1].pos[1] = nodeList[1].pos[1] - PerpVec[1]
            nodeList[1].pos[3] = nodeList[1].pos[3] - PerpVec[3]
            nodeList[2].pos[1] = nodeList[2].pos[1] + PerpVec[1]
            nodeList[2].pos[3] = nodeList[2].pos[3] + PerpVec[3]

            unitHub.pos[1] = unitHub.pos[1] - PerpVec[1]
            unitHub.pos[3] = unitHub.pos[3] - PerpVec[3]
            adjacentHub.pos[1] = adjacentHub.pos[1] + PerpVec[1]
            adjacentHub.pos[3] = adjacentHub.pos[3] + PerpVec[3]
        else
            -- Unit bottom skirt is on top skirt of adjacent unit
            if (unitSkirtBounds[3] == adjacentSkirtBounds[1]) then
                nodeList[1].pos[1] = unitHub.pos[1]
                nodeList[2].pos[1] = adjacentHub.pos[1]
                nodeList[1].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) - (util.GetRandomFloat(0, 1))
                nodeList[2].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) + (util.GetRandomFloat(0, 1))
            elseif (unitSkirtBounds[1] == adjacentSkirtBounds[3]) then
                nodeList[1].pos[1] = unitHub.pos[1]
                nodeList[2].pos[1] = adjacentHub.pos[1]
                nodeList[1].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) + (util.GetRandomFloat(0, 1))
                nodeList[2].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) - (util.GetRandomFloat(0, 1))
            elseif (unitSkirtBounds[4] == adjacentSkirtBounds[2]) then
                nodeList[1].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) - (util.GetRandomFloat(0, 1))
                nodeList[2].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) + (util.GetRandomFloat(0, 1))
                nodeList[1].pos[3] = unitHub.pos[3]
                nodeList[2].pos[3] = adjacentHub.pos[3]
            elseif (unitSkirtBounds[2] == adjacentSkirtBounds[4]) then
                nodeList[1].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) + (util.GetRandomFloat(0, 1))
                nodeList[2].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) - (util.GetRandomFloat(0, 1))
                nodeList[1].pos[3] = unitHub.pos[3]
                nodeList[2].pos[3] = adjacentHub.pos[3]
            else
                validAdjacency = false
            end
        end
    elseif faction == 'UEF' or faction == 'Nomads' then
        if (unitPos[1] == adjPos[1]) or (unitPos[3] == adjPos[3]) then
            local DirectionVec = util.GetScaledDirectionVector( unitHub.pos, adjacentHub.pos, 0.35 )
            DirectionVec[2] = 0
            local PerpVec = util.Cross( DirectionVec, Vector(0,0.35,0) )
            if util.GetRandomInt(0,1) == 1 then
                PerpVec[1] = -PerpVec[1]
                PerpVec[2] = -PerpVec[2]
                PerpVec[3] = -PerpVec[3]
            end

            -- Initialize 2 midpoint segments
            for k, v in nodeList do
                v.pos = util.GetMidPoint( unitHub.pos, adjacentHub.pos )
            end

            -- Offset beam positions
            nodeList[1].pos[1] = nodeList[1].pos[1] - PerpVec[1]
            nodeList[1].pos[3] = nodeList[1].pos[3] - PerpVec[3]
            nodeList[2].pos[1] = nodeList[2].pos[1] + PerpVec[1]
            nodeList[2].pos[3] = nodeList[2].pos[3] + PerpVec[3]

            unitHub.pos[1] = unitHub.pos[1] - PerpVec[1]
            unitHub.pos[3] = unitHub.pos[3] - PerpVec[3]
            adjacentHub.pos[1] = adjacentHub.pos[1] + PerpVec[1]
            adjacentHub.pos[3] = adjacentHub.pos[3] + PerpVec[3]
        else
            -- Unit bottom skirt is on top skirt of adjacent unit
            if (unitSkirtBounds[3] == adjacentSkirtBounds[1]) or (unitSkirtBounds[1] == adjacentSkirtBounds[3]) then
                nodeList[1].pos[1] = unitHub.pos[1]
                nodeList[2].pos[1] = adjacentHub.pos[1]
                nodeList[1].pos[3] = (unitHub.pos[3] + adjacentHub.pos[3]) * 0.5
                nodeList[2].pos[3] = (unitHub.pos[3] + adjacentHub.pos[3]) * 0.5

            -- Unit right skirt is on left skirt of adjacent unit
            elseif (unitSkirtBounds[4] == adjacentSkirtBounds[2]) or (unitSkirtBounds[2] == adjacentSkirtBounds[4]) then
                nodeList[1].pos[1] = (unitHub.pos[1] + adjacentHub.pos[1]) * 0.5
                nodeList[2].pos[1] = (unitHub.pos[1] + adjacentHub.pos[1]) * 0.5
                nodeList[1].pos[3] = unitHub.pos[3]
                nodeList[2].pos[3] = adjacentHub.pos[3]
            else
                validAdjacency = false
            end
        end
    end

    if validAdjacency then
        -- Offset beam positions above the ground at current positions terrain height
        for k, v in nodeList do
            v.pos[2] = GetTerrainHeight(v.pos[1], v.pos[3]) + verticalOffset
        end

        unitHub.pos[2] = GetTerrainHeight(unitHub.pos[1], unitHub.pos[3]) + verticalOffset
        adjacentHub.pos[2] = GetTerrainHeight(adjacentHub.pos[1], adjacentHub.pos[3]) + verticalOffset

        -- Set the mesh of the entity and attach any node effects
        for i = 1, numNodes do
            nodeList[i].entity:SetMesh(nodeMesh, false)
            --nodeList[i].entity:SetDrawScale(0.003)
            nodeList[i].mesh = true
            if emitterNodeEffects[i] ~= nil and table.getn(emitterNodeEffects[i]) ~= 0 then
                for k, vEmit in emitterNodeEffects[i] do
                    emit = CreateAttachedEmitter( nodeList[i].entity, 0, unit.Army, vEmit )
                    info.Trash:Add(emit)
                    unit.Trash:Add(emit)
                end
            end
        end

        -- Insert start and end points into our list
        table.insert(nodeList, 1, unitHub )
        table.insert(nodeList, adjacentHub )

        -- Warp everything to its final position
        for i = 1, numNodes + 2 do
            Warp( nodeList[i].entity, nodeList[i].pos )
            info.Trash:Add(nodeList[i].entity)
            unit.Trash:Add(nodeList[i].entity)
        end

        -- Attach beams to the adjacent unit
        for i = 1, numNodes + 1 do
            if nodeList[i].mesh ~= nil then
                local vec = util.GetDirectionVector(Vector(nodeList[i].pos[1], nodeList[i].pos[2], nodeList[i].pos[3]), Vector(nodeList[i+1].pos[1], nodeList[i+1].pos[2], nodeList[i+1].pos[3]))
                nodeList[i].entity:SetOrientation( OrientFromDir( vec ),true)
            end
            if beamEffect then
                local beam = AttachBeamEntityToEntity( nodeList[i].entity, -1, nodeList[i+1].entity, -1, unit.Army, beamEffect  )
                info.Trash:Add(beam)
                unit.Trash:Add(beam)
            end
        end
    end
end