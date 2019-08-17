
--function LoadBlueprints()
-- TODO: remove this. This is part an investigation in how to make the blueprints load faster
--
--    LOG('Loading blueprints...')
--LOG('-------- 1 --------')
--    InitOriginalBlueprints()
--
--LOG('-------- 2 --------')
--    for i,dir in {'/effects', '/env', '/meshes', '/projectiles', '/props', '/units'} do
--LOG('-------- '..repr(dir)..' --------')
--        for k,file in DiskFindFiles(dir, '*.bp') do
--            BlueprintLoaderUpdateProgress()
--            safecall("loading blueprint "..file, doscript, file)
--        end
--    end
--LOG('-------- 3 --------')
--
--    for i,m in __active_mods do
--        for k,file in DiskFindFiles(m.location, '*.bp') do
--            BlueprintLoaderUpdateProgress()
--            LOG("applying blueprint mod "..file)
--            safecall("loading mod blueprint "..file, doscript, file)
--        end
--    end
--LOG('-------- 4 --------')
--
--    BlueprintLoaderUpdateProgress()
--    LOG('Extracting mesh blueprints.')
--    ExtractAllMeshBlueprints()
--LOG('-------- 5 --------')
--
--    BlueprintLoaderUpdateProgress()
--    LOG('Modding blueprints.')
--    ModBlueprints(original_blueprints)
--LOG('-------- 6 --------')
--
--    BlueprintLoaderUpdateProgress()
--    LOG('Registering blueprints...')
--    RegisterAllBlueprints(original_blueprints)
--    original_blueprints = nil
--LOG('-------- 7 --------')
--
--    LOG('Blueprints loaded')
--end


-- Overwriting the blueprint loader so that new units can be injected. Necessary for FAFhook which adds support factories: new
-- unit only necessary for FAF and undesired in the other balances.
function LoadBlueprints(pattern, directories, mods, skipGameFiles, skipExtraction, skipRegistration)

    -- set default parameters if they are not provided
    if not pattern then pattern = '*.bp' end
    if not directories then
        directories = {'/effects', '/env', '/meshes', '/projectiles', '/props', '/units'}
    end

    LOG('Blueprints Loading... \'' .. tostring(pattern) .. '\' files')

    if not mods then
        mods = __active_mods or import('/lua/mods.lua').GetGameMods()
    end
    InitOriginalBlueprints()

    if not skipGameFiles then
        for i,dir in directories do
            for k,file in DiskFindFiles(dir, pattern) do
                BlueprintLoaderUpdateProgress()
                safecall("Blueprints Loading org file "..file, doscript, file)
            end
        end
    end
    local stats = {}
    stats.UnitsOrg = table.getsize(original_blueprints.Unit)
    stats.ProjsOrg = table.getsize(original_blueprints.Projectile)

    -- added this next  bit and the function GetNewUnitLocations
    local NewUnitPaths = GetNewUnitLocations()
    for i,dir in NewUnitPaths do
        for k,file in DiskFindFiles(dir, pattern) do
            BlueprintLoaderUpdateProgress()
            safecall("loading blueprint new unit "..file, doscript, file)
        end
    end

    for i,mod in mods or {} do
        current_mod = mod -- used in UnitBlueprint()
        for k,file in DiskFindFiles(mod.location, pattern) do
            BlueprintLoaderUpdateProgress()
            safecall("Blueprints Loading mod file "..file, doscript, file)
        end
    end
    stats.UnitsMod = table.getsize(original_blueprints.Unit) - stats.UnitsOrg
    stats.ProjsMod = table.getsize(original_blueprints.Projectile) - stats.ProjsOrg

    if not skipExtraction then
        BlueprintLoaderUpdateProgress()
        LOG('Blueprints Extracting mesh...')
        ExtractAllMeshBlueprints()
    end

    BlueprintLoaderUpdateProgress()
    LOG('Blueprints Modding...')
    PreModBlueprints(original_blueprints)
    ModBlueprints(original_blueprints)
    PostModBlueprints(original_blueprints)

    stats.UnitsTotal = table.getsize(original_blueprints.Unit)
    stats.UnitsPreset = stats.UnitsTotal - stats.UnitsOrg - stats.UnitsMod
    if stats.UnitsTotal > 0 then
        LOG('Blueprints Loading... completed: ' .. stats.UnitsOrg .. ' original, '
                                                .. stats.UnitsMod .. ' modded, and '
                                                .. stats.UnitsPreset .. ' preset units')
    end
    stats.ProjsTotal = table.getsize(original_blueprints.Projectile)
    if stats.ProjsTotal > 0 then
        LOG('Blueprints Loading... completed: ' .. stats.ProjsOrg .. ' original and '
                                                .. stats.ProjsMod .. ' modded projectiles')
    end

    if not skipRegistration then
        BlueprintLoaderUpdateProgress()
        LOG('Blueprints Registering...')
        RegisterAllBlueprints(original_blueprints)
        original_blueprints = nil
    else
        return original_blueprints
    end
end


-- hook this to inject new units into the blueprint loader. Necessary for f.e. FAFhook to add the support factories.
function GetNewUnitLocations()
    local t = {}
    t = table.cat( t, {
        -- adding all Nomads support factories to the game
        '/units/znb9501', -- Land Support Tech2
        '/units/znb9502', -- Air Support Tech2
        '/units/znb9503', -- Sea Support Tech2
        '/units/znb9601', -- Land Support Tech3
        '/units/znb9602', -- Air Support Tech3
        '/units/znb9603', -- Sea Support Tech3
    })
    return t
end


local oldModBlueprints = ModBlueprints
function ModBlueprints(all_bps)

    local EXP, LAND, MOBILE, NAVAL, T3, USEBUILDPRESETS
    local PresetUnitBPs = {}
    for _, bp in all_bps.Unit do

        if not bp.Categories then
            continue
        end

        -- adding or deleting categories on the fly
        if bp.DelCategories then
            for k, v in bp.DelCategories do
                table.removeByValue( bp.Categories, v )
            end
            bp.DelCategories = nil
        end
        if bp.AddCategories then
            for k, v in bp.AddCategories do
                table.insert( bp.Categories, v )
            end
            bp.AddCategories = nil
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

-- Since pretty much all naval units are transportable this is not necessary anymore
--            if not bp.Display then bp.Display = {} end
--            if not bp.Display.Abilities then bp.Display.Abilities = {} end
--            table.insert( bp.Display.Abilities, '<LOC ability_transportable>Transportable' )

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
    HandleUnitWithBuildPresets(PresetUnitBPs, all_bps)
end

function HandleUnitWithBuildPresets(bps, allUnitBlueprints)

    local SortCats = { 'SORTOTHER', 'SORTINTEL', 'SORTSTRATEGIC', 'SORTDEFENSE', 'SORTECONOMY', 'SORTCONSTRUCTION', }
    local tempBp = {}

    for k, bp in bps do
        for name, preset in bp.EnhancementPresets do
            -- start with clean copy of the original unit BP
            tempBp = table.deepcopy(bp)

            -- create BP table for the assigned preset with required info
            tempBp.EnhancementPresetAssigned = {
                Enhancements = table.deepcopy( preset.Enhancements ),
                Name = name,
                BaseBlueprintId = bp.BlueprintId,
            }

            -- change cost of the new unit to match unit base cost + preset enhancement costs. An override is provided for cases where this is not desired.
            local e, m, t = 0, 0, 0
            if not preset.BuildCostEnergyOverride or not preset.BuildCostMassOverride or not preset.BuildTimeOverride then
                for k, enh in preset.Enhancements do
                    if not tempBp.Enhancements[enh] then
                        WARN('*DEBUG: Enhancement '..repr(enh)..' used in preset '..repr(name)..' for unit '..repr(tempBp.BlueprintId)..' does not exist')
                        continue
                    end
                    e = e + (tempBp.Enhancements[enh].BuildCostEnergy or 0)
                    m = m + (tempBp.Enhancements[enh].BuildCostMass or 0)
                    t = t + (tempBp.Enhancements[enh].BuildTime or 0)
                end
            end
            tempBp.Economy.BuildCostEnergy = preset.BuildCostEnergyOverride or (tempBp.Economy.BuildCostEnergy + e)
            tempBp.Economy.BuildCostMass = preset.BuildCostMassOverride or (tempBp.Economy.BuildCostMass + m)
            tempBp.Economy.BuildTime = preset.BuildTimeOverride or (tempBp.Economy.BuildTime + t)

            -- teleport cost adjustments. Teleporting a manually enhanced SCU is cheaper than a prebuild SCU because the latter has its cost
            -- adjusted (up). This code sets bp values used in the code to calculate with different base values than the unit cost.
            if preset.TeleportNoCostAdjustment ~= false then
                -- set teleport cost overrides to cost of base unit
                tempBp.Economy.TeleportEnergyCost = bp.Economy.BuildCostEnergy or 0
                tempBp.Economy.TeleportMassCost = bp.Economy.BuildMassEnergy or 0
            end

            -- Add a sorting category so similar SCUs are grouped together in the build menu
            if preset.SortCategory then
                if table.find(SortCats, preset.SortCategory) or preset.SortCategory == 'None' then
                    for _, v in SortCats do
                        table.removeByValue(tempBp.Categories, v)
                    end
                    if preset.SortCategory ~= 'None' then
                        table.insert(tempBp.Categories, preset.SortCategory)
                    end
                end
            end

            -- UI unit view overrides. Some units get a shield or capacitor from their preset. Tell the UI to show the proper values (when picking the unit in the factory build queue)
            if preset.UIUnitViewOverrides then
                if not tempBp.Display.UIUnitViewOverrides then
                    tempBp.Display.UIUnitViewOverrides = {}
                end

                if preset.UIUnitViewOverrides.CapacitorDuration then
                    tempBp.Display.UIUnitViewOverrides.CapacitorDuration = preset.UIUnitViewOverrides.CapacitorDuration
                end
                if preset.UIUnitViewOverrides.MaxHealth then
                    tempBp.Display.UIUnitViewOverrides.MaxHealth = preset.UIUnitViewOverrides.MaxHealth
                end
                if preset.UIUnitViewOverrides.ShieldMaxHealth then
                    tempBp.Display.UIUnitViewOverrides.ShieldMaxHealth = preset.UIUnitViewOverrides.ShieldMaxHealth
                end

                if preset.UIUnitViewOverrides.MaintenanceConsumptionPerSecondEnergy then
                    tempBp.Display.UIUnitViewOverrides.MaintenanceConsumptionPerSecondEnergy = preset.UIUnitViewOverrides.MaintenanceConsumptionPerSecondEnergy
                end
                if preset.UIUnitViewOverrides.MaintenanceConsumptionPerSecondMass then
                    tempBp.Display.UIUnitViewOverrides.MaintenanceConsumptionPerSecondMass = preset.UIUnitViewOverrides.MaintenanceConsumptionPerSecondMass
                end
                if preset.UIUnitViewOverrides.ProductionPerSecondEnergy then
                    tempBp.Display.UIUnitViewOverrides.ProductionPerSecondEnergy = preset.UIUnitViewOverrides.ProductionPerSecondEnergy
                end
                if preset.UIUnitViewOverrides.ProductionPerSecondMass then
                    tempBp.Display.UIUnitViewOverrides.ProductionPerSecondMass = preset.UIUnitViewOverrides.ProductionPerSecondMass
                end
            end

            -- change other things relevant things aswell
            tempBp.BlueprintId = tempBp.BlueprintId .. '_' .. name
            tempBp.BuildIconSortPriority = preset.BuildIconSortPriority or tempBp.BuildIconSortPriority or 0
            tempBp.General.SelectionPriority = preset.SelectionPriority or tempBp.General.SelectionPriority
            tempBp.General.UnitName = preset.UnitName or tempBp.General.UnitName
            tempBp.Interface.HelpText = preset.HelpText or tempBp.Interface.HelpText
            tempBp.Description = preset.Description or tempBp.Description
            table.insert(tempBp.Categories, 'ISPREENHANCEDUNIT')

            -- clean up some data that's not needed anymore
            table.removeByValue(tempBp.Categories, 'USEBUILDPRESETS')
            tempBp.EnhancementPresets = nil

            table.insert( allUnitBlueprints.Unit, tempBp )
            --LOG('*DEBUG: created preset unit '..repr(tempBp.BlueprintId))

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
