
local oldModBlueprints = ModBlueprints
function ModBlueprints(all_bps)

    local EXP, LAND, MOBILE, NAVAL, T3, USEBUILDPRESETS
    local PresetUnitBPs = {}
    for _, bp in all_bps.Unit do

        if not bp.Categories then
            continue
        end

        -- check for the correct categories
        EXP = false
        LAND = false
        MOBILE = false
        NAVAL = false
        T3 = false
        USEBUILDPRESETS = false
        for k, cat in bp.Categories do
            if cat == 'EXPERIMENTAL' then
                EXP = true
            elseif cat == 'LAND' then
                LAND = true
            elseif cat == 'MOBILE' then
                MOBILE = true
            elseif cat == 'NAVAL' then
                NAVAL = true
            elseif cat == 'TECH3' then
                T3 = true
            elseif cat == 'USEBUILDPRESETS' then
                USEBUILDPRESETS = true
            end
            if EXP and LAND and MOBILE and NAVAL and T3 and USEBUILDPRESETS then break end
        end


        -- Making sure only experimentals that have the transport item in the blueprint can be transported.
        -- Set an invalid transport class on other land experimentals. This prevents them from being transported.
        if EXP and LAND and (not bp.Transport or not bp.Transport.TransportClass) then

            if not bp.General then bp.General = {} end
            if not bp.General.CommandCaps then bp.General.CommandCaps = {} end
            bp.General.CommandCaps[ 'RULEUCC_CallTransport' ] = false

            if not bp.Transport then bp.Transport = {} end
            bp.Transport[ 'TransportClass' ] = 10
        end

        -- Making ships transportable by the Comet
        if NAVAL and MOBILE and not EXP and (not bp.Transport or not bp.Transport.TransportClass) then
            -- making the unit transportable

            if not bp.General then bp.General = {} end
            if not bp.General.CommandCaps then bp.General.CommandCaps = {} end
            bp.General.CommandCaps[ 'RULEUCC_CallTransport' ] = true

            if not bp.Transport then bp.Transport = {} end
            bp.Transport[ 'CanFireFromTransport' ] = false
            bp.Transport[ 'TransportClass' ] = 4
        end

        BlueprintLoaderUpdateProgress()
    end

    oldModBlueprints(all_bps)
end

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
