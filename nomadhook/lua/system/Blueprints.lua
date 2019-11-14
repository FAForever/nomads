
local oldModBlueprints = ModBlueprints
function ModBlueprints(all_bps)

    for _, bp in all_bps.Unit do
        -- Set up units to be transported by the T4 transport. All naval units need transporting, as well as selected experimentals.
        if bp.Transport and bp.Transport.TransportClass and not (bp.CategoriesHash.NAVALCARRIER or bp.CategoriesHash.AIRSTAGINGPLATFORM) then continue end--skip units which already have their class set explicitly
        
        local transClassToSet = false
        
        if bp.CategoriesHash.NAVAL and bp.CategoriesHash.MOBILE and not bp.CategoriesHash.EXPERIMENTAL then
            transClassToSet = 4 --fits into AttachSpecial slot
        end
        
        if transClassToSet then
            if not bp.General then bp.General = {} end
            if not bp.General.CommandCaps then bp.General.CommandCaps = {} end
            bp.General.CommandCaps[ 'RULEUCC_CallTransport' ] = (transClassToSet ~= 10) --set to false if we specify class 10

            if not bp.Transport then bp.Transport = {} end
            bp.Transport[ 'CanFireFromTransport' ] = false
            bp.Transport[ 'TransportClass' ] = transClassToSet
        end

        BlueprintLoaderUpdateProgress()
    end

    ExtractColouredBlueprints(all_bps)
    oldModBlueprints(all_bps)
end

ConvertColoursList = function()
    -- Importing files doesnt work inside blueprints.lua, so here is a function to get a properly converted list.
    -- Dont forget to update this whenever the colours get updated!
    local colourslist = import('/lua/GameColors.lua').GameColors.ArmyColors
    local DetermineColourIndex = import('/lua/NomadsUtils.lua').DetermineColourIndex
    local colourIndexList = {}
    
    for _, colour in colourslist do
        table.insert(colourIndexList, DetermineColourIndex(colour))
    end

    WARN(repr(colourIndexList))
    return colourIndexList
end

-- We duplicate beam and trail blueprints so that we are able to switch effect colours to match faction colours ingame.
function ExtractColouredBlueprints(all_bps)
    --first we get a list of the colour indeces, so we know how many blueprints to duplicate
    local colourIndexList = {
        585.71850585938,
        360.95690917969,
        540.25,
        420.98999023438,
        383.75686645508,
        540.25,
        619.61962890625,
        660.46667480469,
        507.66906738281,
        600.81774902344,
        634.99401855469,
        660.80395507813,
        414.98803710938,
        390.8688659668,
        711.86108398438,
        540.40502929688,
        480.66491699219,
        520.59997558594,
        436.99072265625,
    }
    --this list was generated with ConvertColoursList, see above - they are hue values + 360, with saturation stored in the decimal part. yeah. its dumb.

    for _, bp in all_bps.Beam do
        if bp.RecolourByArmyColour then
            --we make one duplicate for each colour, and also leave the original
            for k,ColourIndex in colourIndexList do
                local colouredBp = table.deepcopy(bp)
                colouredBp.RecolourByArmyColour = false
                --to avoid lua side computation we store the index in the name, then we call it with string ops instead of whatever.
                colouredBp.BlueprintId = string.sub(bp.BlueprintId,1,-4) .. math.floor(100*colourIndexList[k])
                colouredBp.UShift = ColourIndex --UShift is the sideways beam movement. pretty much unused, so its fine to overwrite
                StoreBlueprint('Beam', colouredBp)
            end
        end
    end
    
    for _, bp in all_bps.TrailEmitter do
        if bp.RecolourByArmyColour then
            --we make one duplicate for each colour, and also leave the original
            for k,ColourIndex in colourIndexList do
                local colouredBp = table.deepcopy(bp)
                colouredBp.RecolourByArmyColour = false
                --to avoid lua side computation we store the index in the name, then we call it with string ops instead of whatever.
                colouredBp.BlueprintId = string.sub(bp.BlueprintId,1,-4) .. math.floor(100*colourIndexList[k])
                --Size is used all the time, but we will mash all the values together anyway in a fit of madness
                --Hue takes first 3 digits, next 2 are saturation, and then last 1 and decimals are for the size. what could possibly go wrong.
                --example: 36091.15 -> 360 hue, 9 saturation, 1.15 size
                colouredBp.Size = (10*math.floor(10*ColourIndex)) + bp.Size
                StoreBlueprint('TrailEmitter', colouredBp)
            end
        end
    end
end












--TODO:if SACUs are losing their capacitor abilities, we can just remove all this.
--Slightly disgusting that we need to hook the whole function just to change two bits in it. Changes are commented with "Nomads" in them
function HandleUnitWithBuildPresets(bps, all_bps)

    -- hashing sort categories for quick lookup
    local sortCategories = { ['SORTOTHER'] = true, ['SORTINTEL'] = true, ['SORTSTRATEGIC'] = true, ['SORTDEFENSE'] = true, ['SORTECONOMY'] = true, ['SORTCONSTRUCTION'] = true, }

    local tempBp = {}

    for k, bp in bps do

        for name, preset in bp.EnhancementPresets do
            -- start with clean copy of the original unit BP
            tempBp = table.deepcopy(bp)

            -- create BP table for the assigned preset with required info
            tempBp.EnhancementPresetAssigned = {
                Enhancements = table.deepcopy(preset.Enhancements),
                Name = name,
                BaseBlueprintId = bp.BlueprintId,
            }

            -- change cost of the new unit to match unit base cost + preset enhancement costs. An override is provided for cases where this is not desired.
            local e, m, t = 0, 0, 0
            if not preset.BuildCostEnergyOverride or not preset.BuildCostMassOverride or not preset.BuildTimeOverride then
                for k, enh in preset.Enhancements do
                    -- replaced continue by reversing if statement
                    if tempBp.Enhancements[enh] then
                        e = e + (tempBp.Enhancements[enh].BuildCostEnergy or 0)
                        m = m + (tempBp.Enhancements[enh].BuildCostMass or 0)
                        t = t + (tempBp.Enhancements[enh].BuildTime or 0)
                        -- HUSSAR added name of the enhancement so that preset units cannot be built
                        -- if they have restricted enhancement(s)
                        tempBp.CategoriesHash[enh] = true -- hashing without changing case of enhancements
                    else
                        WARN('*DEBUG: Enhancement '..repr(enh)..' used in preset '..repr(name)..' for unit '..repr(tempBp.BlueprintId)..' does not exist')
                    end
                end
            end
            tempBp.Economy.BuildCostEnergy = preset.BuildCostEnergyOverride or (tempBp.Economy.BuildCostEnergy + e)
            tempBp.Economy.BuildCostMass = preset.BuildCostMassOverride or (tempBp.Economy.BuildCostMass + m)
            tempBp.Economy.BuildTime = preset.BuildTimeOverride or (tempBp.Economy.BuildTime + t)

            -- teleport cost adjustments. Manually enhanced SCU with teleport is cheaper than a prebuild SCU because the latter has its cost
            -- adjusted (up). This code sets bp values used in the code to calculate with different base values than the unit cost.
            if preset.TeleportNoCostAdjustment ~= false then
                -- set teleport cost overrides to cost of base unit
                tempBp.Economy.TeleportEnergyCost = bp.Economy.BuildCostEnergy or 0
                tempBp.Economy.TeleportMassCost = bp.Economy.BuildMassEnergy or 0
            end

            -- Add a sorting category so similar SCUs are grouped together in the build menu
            if preset.SortCategory then
                if sortCategories[preset.SortCategory] or preset.SortCategory == 'None' then
                    for k, v in sortCategories do
                        tempBp.CategoriesHash[k] = false
                    end
                    if preset.SortCategory ~= 'None' then
                        tempBp.CategoriesHash[preset.SortCategory] = true
                    end
                end
            end

            -- Added in Nomads: UI unit view overrides. Some units get a shield or capacitor from their preset. Tell the UI to show the proper values (when picking the unit in the factory build queue)
            if preset.UIUnitViewOverrides then
                if not tempBp.Display.UIUnitViewOverrides then
                    tempBp.Display.UIUnitViewOverrides = {}
                end
                
                --create a table with the list of values to check and then loop through it to set the values
                local presetList = {
                'CapacitorDuration',
                'MaxHealth',
                'ShieldMaxHealth',
                'MaintenanceConsumptionPerSecondEnergy',
                'MaintenanceConsumptionPerSecondMass',
                'ProductionPerSecondEnergy',
                'ProductionPerSecondMass',
                }
                
                for _,presetValue in presetList do
                    if preset.UIUnitViewOverrides[presetValue] then
                        tempBp.Display.UIUnitViewOverrides[presetValue] = preset.UIUnitViewOverrides[presetValue]
                    end
                end
            end

            -- change other things relevant things as well
            tempBp.BaseBlueprintId = tempBp.BlueprintId
            tempBp.BlueprintId = tempBp.BlueprintId .. '_' .. name
            tempBp.BuildIconSortPriority = preset.BuildIconSortPriority or tempBp.BuildIconSortPriority or 0
            tempBp.General.SelectionPriority = preset.SelectionPriority or tempBp.General.SelectionPriority --Added in Nomads
            tempBp.General.UnitName = preset.UnitName or tempBp.General.UnitName
            tempBp.Interface.HelpText = preset.HelpText or tempBp.Interface.HelpText
            tempBp.Description = preset.Description or tempBp.Description
            tempBp.CategoriesHash['ISPREENHANCEDUNIT'] = true
            -- clean up some data that's not needed anymore
            tempBp.CategoriesHash['USEBUILDPRESETS'] = false
            tempBp.EnhancementPresets = nil
            -- synchronizing Categories with CategoriesHash for compatibility
            tempBp.Categories = table.unhash(tempBp.CategoriesHash)

            table.insert(all_bps.Unit, tempBp)

            BlueprintLoaderUpdateProgress()
        end
    end
end

local oldExtractAllMeshBlueprints = ExtractAllMeshBlueprints
function ExtractAllMeshBlueprints()
    oldExtractAllMeshBlueprints()

    -- also extracting stunned mesh blueprints
    for id,bp in original_blueprints.Unit do
        ExtractStunnedMeshBlueprint(bp)
    end
end

local oldExtractBuildMeshBlueprint = ExtractBuildMeshBlueprint
function ExtractBuildMeshBlueprint(bp)
    oldExtractBuildMeshBlueprint(bp)

    local FactionName = bp.General.FactionName
    if FactionName == 'Nomads' then
        --assign different build shaders based on whether its a unit or building. possibly set this in the blueprint instead?
        local buildShaderType = 'NomadsBuild'
        for _, cat in bp.Categories do
            if cat == 'MOBILE' then
                buildShaderType = 'NomadsBuildUnit'
                break
            end
        end

        local meshid = bp.Display.MeshBlueprint
        if not meshid then return end
        local meshbp = original_blueprints.Mesh[meshid]
        if not meshbp then return end
        local buildmeshbp = table.deepcopy(meshbp)
        if buildmeshbp.LODs then
            for i, lod in buildmeshbp.LODs do
                lod.ShaderName = buildShaderType
                lod.LookupName = '/textures/effects/NomadsBuildNoiseLookup.dds'  -- Nomads 3D build noise texture
            end
        end
        buildmeshbp.BlueprintId = meshid .. '_build'
        bp.Display.BuildMeshBlueprint = buildmeshbp.BlueprintId
        MeshBlueprint(buildmeshbp)
    end
end

function ExtractStunnedMeshBlueprint(bp)

    if not bp.Display.MeshBlueprintStunned or bp.Display.MeshBlueprintStunned == '' then

        -- duplicating the default unit mesh
        local meshid = bp.Display.MeshBlueprint
        if not meshid then return end
        local meshbp = original_blueprints.Mesh[meshid]
        if not meshbp then return end
        local StunnedMeshBp = table.deepcopy(meshbp)

        -- changing shadernames
        if StunnedMeshBp.LODs then
            for k, lod in StunnedMeshBp.LODs do
                -- only change shadername if there actually is a stunned shader...
                if lod.ShaderName == 'Unit' or lod.ShaderName == 'Aeon' or lod.ShaderName == 'Insect' or lod.ShaderName == 'Seraphim' or lod.ShaderName == 'NomadsUnit' then
                    lod.ShaderName = lod.ShaderName .. 'Stunned'
                end
            end
        end

        -- registering new mesh for future use
        StunnedMeshBp.BlueprintId = meshid .. '_stunned'
        bp.Display.MeshBlueprintStunned = StunnedMeshBp.BlueprintId
        MeshBlueprint(StunnedMeshBp)
    end
end
