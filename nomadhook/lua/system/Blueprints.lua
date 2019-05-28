
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
        '/units/xnb0211',
        '/units/xnb0212',
        '/units/xnb0213',
        '/units/xnb0311',
        '/units/xnb0312',
        '/units/xnb0313',
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

    DEBUG_UNIT_BP_CHECK(all_bps.Unit)


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

        local meshid = bp.Display.MeshBlueprint
        if not meshid then return end
        local meshbp = original_blueprints.Mesh[meshid]
        if not meshbp then return end

        local buildmeshbp = table.deepcopy(meshbp)
        if buildmeshbp.LODs then
            for i, lod in buildmeshbp.LODs do
                lod.ShaderName = 'NomadsBuild'
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- UNIT BLUEPRINT DEBUGGING TOOLS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local DEBUGFACTION = 'Nomads'  -- as found in unit blueprint, in General.FactionName
local DEBUGTEXTS = true  -- whether to check the description variables
local DEBUG = false

function DEBUG_UNIT_BP_CHECK(bps)
    -- Used only for debugging purpuses, to find strange and possibly incorrect BP settings. Should remove for FAF and beta.
    if not DEBUG then
        return
    end

-- TODO: check for sound

    WARN('-------- blueprint analyser starting --------')

    local MOBILE, LAND, NAVAL, AIR, TECH1, TECH2, TECH3, EXP, HOVER, ARTILLERY, ENGINEER = false, false, false, false, false, false, false, false, false, false, false
    local FACTORY, MEX, ENERGYPRODUCTION, HYDROCARBON, MASSEXTRACTION, MASSPRODUCTION, MASSFABRICATION, DEFENSE = false, false, false, false, false, false, false, false
    local INTELLIGENCE, ANTIMISSILE, SHIELD, SUBCOMMANDER, COMMAND, SUBMERSIBLE, STRUCTURE, SONAR, RADAR = false, false, false, false, false, false, false, false, false
    local OMNI, COUNTERINTELLIGENCE, OVERLAYCOUNTERINTEL, OVERLAYSONAR, OVERLAYRADAR, OVERLAYOMNI, VISIBLETORECON = false, false, false, false, false, false, false
    local ANTIAIR, OVERLAYANTIAIR, RECLAIMABLE, DIRECTFIRE, OVERLAYDIRECTFIRE, SCOUT, INDIRECTFIRE, OVERLAYINDIRECTFIRE = false, false, false, false, false, false, false, false
    local ARTILLERYSUPPORT, CARRIER, UNSTUNABLE, PRODUCTSC1, TRANSPORTATION, ANTINAVY, OVERLAYANTINAVY, OVERLAYDEFENSE = false, false, false, false, false, false, false, false
    local CANNOTUSEAIRSTAGING, DRAGBUILD, NEEDMOBILEBUILD, CIVILIAN = false, false, false, false

    local abilHov, abilEng, abilStealth, abilaa, abilradar, abilas, abilamph, abilart, abilcar = false, false, false, false, false, false, false, false, false
    local abilsub, abilunstun, abiltransportable, abiltmd, abiltransp, abilflares, abilaqua, abilupgr = false, false, false, false, false, false, false, false
    local abilvolatile, abilradarboost, abilsonarboost, abilshieldome = false, false, false, false

    local HasDeathWep, HasDeathImpWep, HasIntelOverchargeDeathWep = false, false, false

    local TransportClass = 1

    for _, bp in bps do

        -- filtering out irrelevant units
        if DEBUGFACTION ~= '' and bp.General.FactionName ~= DEBUGFACTION then
            continue
        end

        MOBILE, LAND, NAVAL, AIR, TECH1, TECH2, TECH3, EXP, HOVER, ARTILLERY, ENGINEER = false, false, false, false, false, false, false, false, false, false, false
        FACTORY, MEX, ENERGYPRODUCTION, HYDROCARBON, MASSEXTRACTION, MASSPRODUCTION, MASSFABRICATION, DEFENSE = false, false, false, false, false, false, false, false
        INTELLIGENCE, ANTIMISSILE, SHIELD, SUBCOMMANDER, COMMAND, SUBMERSIBLE, STRUCTURE, SONAR, RADAR = false, false, false, false, false, false, false, false, false
        OMNI, COUNTERINTELLIGENCE, OVERLAYCOUNTERINTEL, OVERLAYSONAR, OVERLAYRADAR, OVERLAYOMNI, VISIBLETORECON = false, false, false, false, false, false, false
        ANTIAIR, OVERLAYANTIAIR, RECLAIMABLE, DIRECTFIRE, OVERLAYDIRECTFIRE, SCOUT, INDIRECTFIRE, OVERLAYINDIRECTFIRE = false, false, false, false, false, false, false, false
        ARTILLERYSUPPORT, CARRIER, UNSTUNABLE, PRODUCTSC1, TRANSPORTATION, ANTINAVY, OVERLAYANTINAVY, OVERLAYDEFENSE = false, false, false, false, false, false, false, false
        CANNOTUSEAIRSTAGING, DRAGBUILD, NEEDMOBILEBUILD, CIVILIAN = false, false, false, false

        TransportClass = 1

        -- setting short hand variables
        if bp.Transport and bp.Transport.TransportClass then
            TransportClass = bp.Transport.TransportClass
        end

        -- finding categories
        for k, cat in bp.Categories do
                if cat == 'TECH1' then TECH1 = true
            elseif cat == 'TECH2' then TECH2 = true
            elseif cat == 'TECH3' then TECH3 = true
            elseif cat == 'EXPERIMENTAL' then EXP = true
            elseif cat == 'MOBILE' then MOBILE = true
            elseif cat == 'LAND' then LAND = true
            elseif cat == 'NAVAL' then NAVAL = true
            elseif cat == 'AIR' then AIR = true
            elseif cat == 'NOMADS' then NOMADS = true
            elseif cat == 'HOVER' then HOVER = true
            elseif cat == 'ENGINEER' then ENGINEER = true
            elseif cat == 'FACTORY' then FACTORY = true
            elseif cat == 'ENERGYPRODUCTION' then ENERGYPRODUCTION = true
            elseif cat == 'HYDROCARBON' then HYDROCARBON = true
            elseif cat == 'MASSEXTRACTION' then MASSEXTRACTION = true
            elseif cat == 'MASSPRODUCTION' then MASSPRODUCTION = true
            elseif cat == 'MASSFABRICATION' then MASSFABRICATION = true
            elseif cat == 'DEFENSE' then DEFENSE = true
            elseif cat == 'INTELLIGENCE' then INTELLIGENCE = true
            elseif cat == 'ANTIMISSILE' then ANTIMISSILE = true
            elseif cat == 'SHIELD' then SHIELD = true
            elseif cat == 'SUBCOMMANDER' then SUBCOMMANDER = true
            elseif cat == 'COMMAND' then COMMAND = true
            elseif cat == 'SUBMERSIBLE' then SUBMERSIBLE = true
            elseif cat == 'STRUCTURE' then STRUCTURE = true
            elseif cat == 'COUNTERINTELLIGENCE' then COUNTERINTELLIGENCE = true
            elseif cat == 'RADAR' then RADAR = true
            elseif cat == 'SONAR' then SONAR = true
            elseif cat == 'OMNI' then OMNI = true
            elseif cat == 'OVERLAYCOUNTERINTEL' then OVERLAYCOUNTERINTEL = true
            elseif cat == 'OVERLAYSONAR' then OVERLAYSONAR = true
            elseif cat == 'OVERLAYRADAR' then OVERLAYRADAR = true
            elseif cat == 'OVERLAYOMNI' then OVERLAYOMNI = true
            elseif cat == 'VISIBLETORECON' then VISIBLETORECON = true
            elseif cat == 'ANTIAIR' then ANTIAIR = true
            elseif cat == 'OVERLAYANTIAIR' then OVERLAYANTIAIR = true
            elseif cat == 'RECLAIMABLE' then RECLAIMABLE = true
            elseif cat == 'DIRECTFIRE' then DIRECTFIRE = true
            elseif cat == 'OVERLAYDIRECTFIRE' then OVERLAYDIRECTFIRE = true
            elseif cat == 'SCOUT' then SCOUT = true
            elseif cat == 'INDIRECTFIRE' then INDIRECTFIRE = true
            elseif cat == 'OVERLAYINDIRECTFIRE' then OVERLAYINDIRECTFIRE = true
            elseif cat == 'ARTILLERYSUPPORT' then ARTILLERYSUPPORT = true
            elseif cat == 'CARRIER' then CARRIER = true
            elseif cat == 'UNSTUNABLE' then UNSTUNABLE = true
            elseif cat == 'PRODUCTSC1' then PRODUCTSC1 = true
            elseif cat == 'TRANSPORTATION' then TRANSPORTATION = true
            elseif cat == 'ANTINAVY' then ANTINAVY = true
            elseif cat == 'OVERLAYANTINAVY' then OVERLAYANTINAVY = true
            elseif cat == 'OVERLAYDEFENSE' then OVERLAYDEFENSE = true
            elseif cat == 'CANNOTUSEAIRSTAGING' then CANNOTUSEAIRSTAGING = true
            elseif cat == 'DRAGBUILD' then DRAGBUILD = true
            elseif cat == 'NEEDMOBILEBUILD' then NEEDMOBILEBUILD = true
            elseif cat == 'CIVILIAN' then CIVILIAN = true

            end
        end

        -- ---------------------------------------------------------------------------------------------------------------

        if DEBUGTEXTS then
            if not bp.Description or string.len(bp.Description) < 19 or string.sub(bp.Description, 1, 18) ~= '<LOC '..bp.BlueprintId..'_desc>' then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' missing, invalid or incomplete Description')
            end
            if not bp.Interface.HelpText or string.len(bp.Interface.HelpText) < 19 or string.sub(bp.Interface.HelpText, 1, 18) ~= '<LOC '..bp.BlueprintId..'_help>' then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' missing, invalid or incomplete Interface.HelpText')
            end
            if bp.General.UnitName and (string.len(bp.General.UnitName) < 19 or string.sub(bp.General.UnitName, 1, 18) ~= '<LOC '..bp.BlueprintId..'_name>') then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' invalid or incomplete General.UnitName')
            end
        end

        if HOVER then
            if not bp.Physics then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' no physics defined')
            elseif not bp.Physics.Elevation or bp.Physics.Elevation < 0.2 or bp.Physics.Elevation > 2 then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' the elevation level seems inappropriate ('..(bp.Physics.Elevation or 'nul')..')')
            else
                local elev = -1 * math.max( bp.Physics.Elevation-0.08, bp.Physics.Elevation/2 )
                for k, v in bp.Display do
                    if k == 'IdleEffects' or k == 'MovementEffects' then
                        for _, val in v do
                            if val.Effects then

                                for __, effect in val.Effects do

                                    if effect.Offset and effect.Offset[2] ~= elev then
                                        WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' bad hover effect Y offset. It should be '..repr(elev)..' and not '..repr(effect.Offset[2]))
                                    end

                                end

                            end
                        end
                    end
                end
            end
            if bp.SelectionCenterOffsetY ~= -0.1 then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' SelectionCenterOffsetY should be -0.1')
            end
        end

        if (TECH1 and bp.General.TechLevel ~= 'RULEUTL_Basic') or (TECH2 and bp.General.TechLevel ~= 'RULEUTL_Advanced') or ((TECH3 or EXP) and bp.General.TechLevel ~= 'RULEUTL_Secret') then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' incorrect General.TechLevel')
        end

        if MOBILE and (LAND or AIR) and not CANNOTUSEAIRSTAGING and ((TECH1 and TransportClass ~= 1) or (TECH2 and TransportClass ~= 2) or (TECH3 and TransportClass ~= 3)) then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' incorrect transport class')
        end

        if MOBILE and AIR and not CANNOTUSEAIRSTAGING and not EXP and not bp.Transport.AirClass then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' Transport.AirClass not set')
        end

        if (ENGINEER and not SUBCOMMANDER and not COMMAND and bp.General.Classification ~= 'RULEUC_Engineer') or
           (LAND and not ENGINEER and not SUBCOMMANDER and not COMMAND and bp.General.Classification ~= 'RULEUC_MilitaryVehicle') or
           (AIR and bp.General.Classification ~= 'RULEUC_MilitaryAircraft') or (FACTORY and STRUCTURE and bp.General.Classification ~= 'RULEUC_Factory') or
           (ENERGYPRODUCTION and STRUCTURE and bp.General.Classification ~= 'RULEUC_Resource') or (MASSPRODUCTION and STRUCTURE and bp.General.Classification ~= 'RULEUC_Resource') or
           (DEFENSE and STRUCTURE and bp.General.Classification ~= 'RULEUC_Weapon') or (INTELLIGENCE and STRUCTURE and not DEFENSE and bp.General.Classification ~= 'RULEUC_Sensor') or
           (ANTIMISSILE and STRUCTURE and bp.General.Classification ~= 'RULEUC_CounterMeasure') or (SHIELD and bp.General.Classification ~= 'RULEUC_CounterMeasure') or
           ((COMMAND or SUBCOMMANDER) and bp.General.Classification ~= 'RULEUC_Commander') or
           (NAVAL and not STRUCTURE and not SUBMERSIBLE and bp.General.Classification ~= 'RULEUC_MilitaryShip') or (SUBMERSIBLE and bp.General.Classification ~= 'RULEUC_MilitarySub')
        then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' incorrect classification')
        end

--RULEUMT_Amphibious
--'RULEUC_MiscSupport'

        if (HOVER and bp.Physics.MotionType ~= 'RULEUMT_Hover') or (AIR and not STRUCTURE and bp.Physics.MotionType ~= 'RULEUMT_Air') or (STRUCTURE and bp.Physics.MotionType ~= 'RULEUMT_None') or
           (LAND and not HOVER and not STRUCTURE and (bp.Physics.MotionType ~= 'RULEUMT_Land' and bp.Physics.MotionType ~= 'RULEUMT_Amphibious' and bp.Physics.MotionType ~= 'RULEUMT_AmphibiousFloating')) or
           (SUBMERSIBLE and bp.Physics.MotionType ~= 'RULEUMT_SurfacingSub') or (NAVAL and not SUBMERSIBLE and not STRUCTURE and bp.Physics.MotionType ~= 'RULEUMT_Water')
        then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' Physics.MotionType is incorrect')
        end

        if not MOBILE then
            local spd = bp.Physics.MaxSpeed
            if bp.Physics.MaxAcceleration ~= spd or bp.Physics.MaxBrake ~= spd then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' Physics.MaxAcceleration or Physics.MaxBrake not equal to MaxSpeed')
            end
        end

        if MOBILE and AIR and not TRANSPORTATION and not bp.SizeSphere then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' no SizeSphere defined')
        elseif MOBILE and AIR and not TRANSPORTATION and not bp.Physics.GroundCollisionOffset then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' no Physics.GroundCollisionOffset defined')
        elseif MOBILE and AIR and not TRANSPORTATION and bp.SizeSphere ~= bp.Physics.GroundCollisionOffset then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' Physics.GroundCollisionOffset not equal to SizeSphere ('..repr(bp.SizeSphere)..')')
        end

        if HOVER and not ENGINEER and bp.General.FactionName == 'Nomads' and bp.Physics.OnWaterSpeedMultiplier and math.ceil(bp.Physics.OnWaterSpeedMultiplier * 100) ~= 75 then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' Physics.OnWaterSpeedMultiplier is not 0.75, it is '..repr(bp.Physics.OnWaterSpeedMultiplier))
        end

        if (NAVAL or bp.Physics.BuildOnLayerCaps.LAYER_Water) and (not bp.CollisionOffsetY or bp.CollisionOffsetY >= -0.1) then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' units that (can) float on the water surface should have a CollisionOffsetY >= -0.1 so torpedoes can hit it')
        end

        if PRODUCTSC1 and bp.General.FactionName ~= 'UEF' and bp.General.FactionName ~= 'Aeon' and bp.General.FactionName ~= 'Cybran' and string.sub(bp.BlueprintId, 1, 1) ~= 'u' and string.sub(bp.BlueprintId, 1, 1) ~= 'd' then
            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' shouldnt have category PRODUCTSC1')
        end

        if STRUCTURE and (not NAVAL or bp.Economy.RebuildBonusIds) and bp.Wreckage then
            local ok = false
            if bp.Economy.RebuildBonusIds then
                for k, v in bp.Economy.RebuildBonusIds do
                    if v == bp.BlueprintId then
                        ok = true
                        break
                    end
                end
            end
            if not ok then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' no or invalid Economy.RebuildBonusIds')
            end
        end

        if (OMNI or (not OMNI and COMMAND)) ~= (bp.Intel.OmniRadius ~= nil and bp.Intel.OmniRadius > 0) then               WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' omni intel and OMNI category mismatch') end
        if RADAR ~= (bp.Intel.RadarRadius ~= nil and bp.Intel.RadarRadius > 0) then                                        WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' radar intel and RADAR category mismatch') end
        if SONAR ~= (bp.Intel.SonarRadius ~= nil and bp.Intel.SonarRadius > 0) then                                        WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' sonar intel and SONAR category mismatch') end
        if COUNTERINTELLIGENCE ~= (bp.Intel.SonarStealthFieldRadius ~= nil and bp.Intel.SonarStealthFieldRadius > 0) then  WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' sonarstealth intel and COUNTERINTELLIGENCE category mismatch') end
        if COUNTERINTELLIGENCE ~= (bp.Intel.RadarStealthFieldRadius ~= nil and bp.Intel.RadarStealthFieldRadius > 0) then  WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' radarstealth intel and COUNTERINTELLIGENCE category mismatch') end
        if COUNTERINTELLIGENCE ~= (bp.Intel.CloakFieldRadius ~= nil and bp.Intel.CloakFieldRadius > 0) then                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' cloakfield intel and COUNTERINTELLIGENCE category mismatch') end
        if COUNTERINTELLIGENCE ~= (bp.Intel.JamRadius ~= nil and bp.Intel.JamRadius > 0) then                              WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' radar jammer intel and COUNTERINTELLIGENCE category mismatch') end

        if INTELLIGENCE ~= (RADAR or SONAR or OMNI or SCOUT) then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category INTELLIGENCE, missing SCOUT, RADAR, SONAR or OMNI') end
        if RADAR ~= OVERLAYRADAR then                             WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category OVERLAYRADAR') end
        if OMNI ~= OVERLAYOMNI then                               WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category OVERLAYOMNI') end
        if SONAR ~= OVERLAYSONAR then                             WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category OVERLAYSONAR') end
        if COUNTERINTELLIGENCE ~= OVERLAYCOUNTERINTEL then        WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category OVERLAYCOUNTERINTEL') end
        if DIRECTFIRE ~= OVERLAYDIRECTFIRE then                   WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category OVERLAYDIRECTFIRE') end
        if (INDIRECTFIRE or bp.Enhancements) ~= OVERLAYINDIRECTFIRE then               WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category OVERLAYINDIRECTFIRE') end
        if ANTIAIR ~= OVERLAYANTIAIR then                         WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category OVERLAYANTIAIR') end
        if ANTINAVY ~= OVERLAYANTINAVY then                       WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category OVERLAYANTINAVY') end
        if (ANTIMISSILE or DEFENSE) ~= (OVERLAYDEFENSE or OVERLAYANTINAVY) then        WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category OVERLAYDEFENSE') end
        if not MASSEXTRACTION and not CIVILIAN and (STRUCTURE or NEEDMOBILEBUILD) ~= DRAGBUILD then       WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category DRAGBUILD') end

        if RECLAIMABLE ~= (not COMMAND and not SUBCOMMANDER) then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ambiguous category RECLAIMABLE (dont use on commanders)') end

        if not VISIBLETORECON then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' missing category VISIBLETORECON') end
        if ARTILLERY and not INDIRECTFIRE then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' missing category INDIRECTFIRE') end

        if ARTILLERYSUPPORT and not bp.ArtillerySupport then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' no artillery support section') end

        if bp.Veteran then
            if not bp.Veteran.Level1 or not bp.Veteran.Level2 or not bp.Veteran.Level3 or not bp.Veteran.Level4 or not bp.Veteran.Level5 then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' missing a veteran level')
            elseif (bp.Veteran.Level1 * 2) ~= bp.Veteran.Level2 or (bp.Veteran.Level1 * 3) ~= bp.Veteran.Level3 or (bp.Veteran.Level1 * 4) ~= bp.Veteran.Level4 or (bp.Veteran.Level1 * 5) ~= bp.Veteran.Level5 then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' bad veteran level steps, each step should be a multiple of Veteran.Level1')
            elseif not bp.Buffs or not bp.Buffs.Regen or not bp.Buffs.Regen.Level1 or not bp.Buffs.Regen.Level2 or not bp.Buffs.Regen.Level3 or not bp.Buffs.Regen.Level4 or not bp.Buffs.Regen.Level5 then
                WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' missing regeneration buffs for veteran levels')
            end
        end

        -- --------------

        abilHov, abilEng, abilStealth, abilaa, abilradar, abilas, abilamph, abilart, abilcar = false, false, false, false, false, false, false, false, false
        abilsub, abilunstun, abiltransportable, abiltmd, abiltransp, abilflares, abilaqua, abilupgr = false, false, false, false, false, false, false, false
        abilvolatile, abilradarboost, abilsonarboost = false, false, false

        if bp.Display.Abilities then
            for k, v in bp.Display.Abilities do
                    if v == '<LOC ability_hover>Hover' then abilHov = true
                elseif v == '<LOC ability_engineeringsuite>Engineering Suite' then abilEng = true
                elseif v == '<LOC ability_personalstealth>Personal Stealth' then abilStealth = true
                elseif v == '<LOC ability_aa>Anti-Air' then abilaa = true
                elseif v == '<LOC ability_radar>Radar' then abilradar = true
                elseif v == '<LOC ability_artillerysupport>Artillery Support' then abilas = true
                elseif v == '<LOC ability_amphibious>Amphibious' then abilamph = true
                elseif v == '<LOC ability_artillery>Artillery' then abilart = true
                elseif v == '<LOC ability_carrier>Carrier' then abilcar = true
                elseif v == '<LOC ability_submersible>Submersible' then abilsub = true
                elseif v == '<LOC ability_unstunable>Immune to EMP' then abilunstun = true
                elseif v == '<LOC ability_transportable>Transportable' then abiltransportable = true
                elseif v == '<LOC ability_tacmissiledef>Tactical Missile Defense' then abiltmd = true
                elseif v == '<LOC ability_transport>Transport' then abiltransp = true
                elseif v == '<LOC ability_flares>Flares' then abilflares = true
                elseif v == '<LOC ability_aquatic>Aquatic' then abilaqua = true
                elseif v == '<LOC ability_upgradable>Upgradeable' then abilupgr = true
                elseif v == '<LOC ability_deathaoe>Volatile' then abilvolatile = true
                elseif v == '<LOC ability_radarboost>Radar Boost' then abilradarboost = true
                elseif v == '<LOC ability_sonarboost>Sonar Boost' then abilsonarboost = true
                elseif v == '<LOC ability_shielddome>Shield Dome' then abilshieldome = true

                end
            end
        end

        if HOVER ~= abilHov then             WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' hover ability (not) displayed') end
        if ENGINEER ~= abilEng then          WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' engineering suite ability (not) displayed') end
        if ANTIAIR ~= abilaa then            WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' anti-air ability (not) displayed') end
        if RADAR ~= abilradar then           WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' radar ability (not) displayed') end
        if ARTILLERY ~= abilart then         WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' artillery ability (not) displayed') end
        if ARTILLERYSUPPORT ~= abilas then   WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' artillery support ability (not) displayed') end
        if CARRIER ~= abilcar then           WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' carrier ability (not) displayed') end
        if SUBMERSIBLE ~= abilsub then       WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' submersible ability (not) displayed') end
        if UNSTUNABLE ~= abilunstun then     WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' unstunable ability (not) displayed') end
        if ANTIMISSILE ~= abiltmd then       WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' tactical missile defense ability (not) displayed') end
        if TRANSPORTATION ~= abiltransp then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' transport ability (not) displayed') end

        if (SHIELD and bp.Defense.Shield.Mesh ~= nil) ~= abilshieldome then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' shield dome ability (not) displayed') end
        if (STRUCTURE and bp.Physics.BuildOnLayerCaps.LAYER_Water and bp.Physics.BuildOnLayerCaps.LAYER_Land) ~= abilaqua then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' aquatic ability (not) displayed') end
        if bp.Intel and bp.Intel.RadarStealth and bp.Intel.RadarStealth ~= abilStealth then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' personal stealth ability (not) displayed') end
        if bp.Physics.MotionType and (bp.Physics.MotionType == 'RULEUMT_Amphibious') ~= abilamph then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' ampibious ability (not) displayed') end
        if (TransportClass == 4 and MOBILE and LAND and EXP) ~= abiltransportable then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' transportable ability (not) displayed') end
        if bp.Defense.AntiMissileFlares and not abilflares then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' anti air flares ability (not) displayed') end
        if (STRUCTURE and bp.General.UpgradesTo ~= nil) ~= abilupgr then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' upgradeable ability (not) displayed') end
        if bp.Intel.OverchargeType ~= nil and (bp.Intel.OverchargeType == 'Radar') ~= abilradarboost then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' radar boost ability (not) displayed') end
        if bp.Intel.OverchargeType ~= nil and (bp.Intel.OverchargeType == 'Sonar') ~= abilsonarboost then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' sonar boost ability (not) displayed') end

        -- --------------

        if bp.Enhancements then

            local IsRemovingEnh = false
            for enh, data in bp.Enhancements do

                if enh == 'Slots' then continue end

                IsRemovingEnh = string.find(string.lower(enh), 'remove')

                if not IsRemovingEnh then
-- prerequisites are tables, not single items
--                    if data.Prerequisite and not bp.Enhancements[data.Prerequisite] then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' enhancement '..enh..' has unknown prerequisite') end
                    if data.BuildCostEnergy < 100 or data.BuildCostMass < 10 or data.BuildTime < 10 then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' enhancement '..enh..' has low costs.') end
                    if not data.Slot or not bp.Enhancements.Slots[data.Slot] then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' enhancement '..enh..' has no or uses unknown slot.') end
                    if not data.Icon then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' enhancement '..enh..' has no icon.') end
                else
                    local RealEnh = string.sub(enh, 1, -7)
                    if not bp.Enhancements[RealEnh] then
                        WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' no enhancement exists to remove with '..enh..' (expected '..RealEnh..')')
                    else
--                        if not data.Prerequisite or data.Prerequisite ~= RealEnh then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' no or invalid prerequisite for '..enh) end
                        if data.BuildCostEnergy ~= 1 or data.BuildCostMass ~= 1 or data.BuildTime ~= 0.1 then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' enhancement '..enh..' has bad costs. E and M should be 1, T should be 0.1') end
                        if not data.Slot or data.Slot ~= bp.Enhancements[RealEnh].Slot then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' enhancement '..enh..' uses wrong slot, should be equal to that of enhancement '..RealEnh) end
                        if not data.Icon or data.Icon ~= bp.Enhancements[RealEnh].Icon then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' enhancement '..enh..' uses wrong icon, should be equal to that of enhancement '..RealEnh) end
                    end
                end
            end
        end

        -- --------------

        HasDeathWep, HasDeathImpWep, HasIntelOverchargeDeathWep = false, false, false

-- number of projectiles, muzzle salvo sizes, rack fire together, etc

        if bp.Weapon then

            local labels = {}
            for k, wep in bp.Weapon do

                if table.find(labels, wep.Label) then
                    WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' has two or more weapons with the same label '..repr(wep.Label))
                end
                table.insert(labels, wep.Label)


                    if wep.Label == 'DeathWeapon' then                   HasDeathWep = true
                elseif wep.Label == 'DeathImpact' then                   HasDeathImpWep = true
                elseif wep.Label == 'IntelOverchargeDeathWeapon' then    HasIntelOverchargeDeathWep = true

                end
            end
        end

        if HasDeathWep ~= abilvolatile then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' volatile ability (not) displayed') end
        if (MOBILE and AIR) ~= HasDeathImpWep then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' has (no) air crash weapon') end
        if bp.Intel.OverchargeEnablesDeathWeapon ~= nil and bp.Intel.OverchargeEnablesDeathWeapon ~= HasIntelOverchargeDeathWep then WARN('*DEBUG: BP analyse: '..bp.BlueprintId..' has (no) intel overcharge deathweapon') end


    end

    WARN('-------- blueprint analyser done --------')
end
