local Entity = import('/lua/sim/Entity.lua').Entity
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

function CreateAmbientShieldEffects(unit, EffectsBag)
    local bp = unit:GetBlueprint()

    -- determining the interval is crucial. We have two shields, the regular one and the stealth shield. Both have a different interval so we
    -- have to detect the shield type.
    local interval = 10
    local efctTempl = 'Shield'
    if bp.Defense.Shield.Mesh == '/effects/Entities/Shield05_stealth/Shield05_stealth_mesh' then
        interval = 3
        efctTempl = 'StealthShield'
    end

    local effectTable = NomadsEffectTemplate[efctTempl] or {}
    local offset = bp.Defense.Shield.ShieldSize - (bp.Defense.Shield.ShieldVerticalOffset or 0)
    while not unit:BeenDestroyed() and not unit.Dead do
        for _, v in effectTable do
            local emit = CreateEmitterAtBone(unit, 0, unit.Army, v):OffsetEmitter(0, offset, 0)
            EffectsBag:Add(emit)
        end
    end
end

function CreateBeamEntities(builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag, ConstructionBeams, ConstructionBeamStartPoint, ConstructionBeamEndPoints)
    -- the beams work like this:
    -- an entity is created on the unit that's being built. A beam emitter is created between the build bone and the entity.
    -- the entity is being instantly moved around on the unit that's being built
    local pos = unitBeingBuilt:GetPosition()
    local endEntityTable = {}

    -- Create build beams
    local beamsPerBone = NomadsEffectTemplate.ConstructionBeamsPerBuildBone
    for i, BuildBone in BuildEffectBones do
        for j = 1, beamsPerBone do
            -- Create the entity that is attached to the unitBeingBuilt
            local BeamEndEntity = Entity()
            BeamEndEntity.counter = 0
            Warp(BeamEndEntity, pos)
            table.insert(endEntityTable, BeamEndEntity)
            BuildEffectsBag:Add(BeamEndEntity)

            -- beam
            for _, v in ConstructionBeams do
                BuildEffectsBag:Add(AttachBeamEntityToEntity(builder, BuildBone, BeamEndEntity, -1, builder.Army, v))
            end

            -- beam endpoint emitters
            for _, ebp in ConstructionBeamEndPoints do
                BuildEffectsBag:Add(CreateEmitterOnEntity(BeamEndEntity, builder.Army, ebp))
            end
        end

        -- beam startpoint emitters
        for _, v in ConstructionBeamStartPoint do
            local starteffect = CreateAttachedEmitter(builder, BuildBone, builder.Army, v)
            BuildEffectsBag:Add(starteffect)
        end
    end
    return endEntityTable
end

function PlaySparkleEffectAtUnitBeingBuilt( builder, unitBeingBuilt, snd )
    local bp = builder:GetBlueprint().Audio
    if bp and bp[snd] then
        unitBeingBuilt:PlaySound( bp[snd] )
        return true
    end
    return false
end

-- beams coming from engineers and ACU when constructing
function CreateNomadsBuildSliceBeams(builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag)
    local endEntityTable = CreateBeamEntities(builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag, NomadsEffectTemplate.ConstructionBeams, NomadsEffectTemplate.ConstructionBeamStartPoint, NomadsEffectTemplate.ConstructionBeamEndPoints)
    local ox, oy, oz = unpack(unitBeingBuilt:GetPosition())

    while not builder:BeenDestroyed() and not unitBeingBuilt:BeenDestroyed() do
        local randWaitTime = Random(10, 30)
        for _, entity in endEntityTable do
            if entity.counter <= 0 then
                local x, y, z = builder.GetRandomOffset(unitBeingBuilt, 1)
                Warp( entity, Vector(ox + x, oy + y, oz + z))
                entity.counter = Random(0, math.min(7, randWaitTime))
                PlaySparkleEffectAtUnitBeingBuilt( builder, unitBeingBuilt, 'ConstructSparkle')
            else
                entity.counter = entity.counter - 20
            end
        end
        WaitSeconds(randWaitTime / 20)
    end
end

function CreateBuildCubeThread(unitBeingBuilt, builder, OnBeingBuiltEffectsBag)
    unitBeingBuilt:ShowBone(0, true)
    unitBeingBuilt:HideLandBones()
    local bp = unitBeingBuilt:GetBlueprint()

    -- Build cube stuff
    local ox = bp.Display.BuildEffect.OffsetX or 0
    local oy = bp.Display.BuildEffect.OffsetY or 0
    local oz = bp.Display.BuildEffect.OffsetZ or 0
    local scale = bp.Display.BuildEffect.Scale or 1
    if bp.CategoriesHash.SIZE4 then
        scale = scale * 0.25
    elseif bp.CategoriesHash.SIZE8 then
        scale = scale * 0.4
    elseif bp.CategoriesHash.SIZE12 then
        scale = scale * 0.8
    elseif bp.CategoriesHash.SIZE16 then
        scale = scale * 1
    elseif bp.CategoriesHash.SIZE20 then
        scale = scale * 1.3
    end

    -- get correct effects template, creates the orange flashing when being constructed
    local EffectTable = NomadsEffectTemplate.ConstructionDefaultBeingBuiltEffect
    if bp.Display.BuildEffect.Emitter then
        if type(bp.Display.BuildEffect.Emitter) == 'table' then
            EffectTable = { bp.Display.BuildEffect.Emitter }
        else
            EffectTable = NomadsEffectTemplate[ 'ConstructionDefaultBeingBuiltEffect' .. bp.Display.BuildEffect.Emitter ]
        end
    end

    -- create emitters
    for _, v in EffectTable do
        local emit = CreateAttachedEmitter(unitBeingBuilt, 0, unitBeingBuilt.Army, v)
        emit:OffsetEmitter(ox, oy, oz)
        emit:ScaleEmitter(scale)
        OnBeingBuiltEffectsBag:Add(emit)
    end
end

function CreateSelfRepairEffects( unit, EffectsBag, numEffects)
    if not numEffects then
        numEffects = unit:GetBlueprint().Display.NumberOfBuildBeams or NomadsEffectTemplate.ConstructionBeamsPerBuildBone or 3
    end

    local emitters = {}
    for i=1, numEffects do
        local emits = {}
        for k, v in NomadsEffectTemplate.RepairSelf do
            local emit = CreateEmitterOnEntity( unit, unit.Army, v )
            EffectsBag:Add( emit )
            table.insert( emits, emit )
        end
        emitters[i] = { emts = emits, counter = 0, x = 0, y = 0, z = 0, }
    end

    while unit and not unit:BeenDestroyed() do
        for k, v in emitters do
            if v.counter <= 0 then
                -- give the emitters an offset. we first have to revert the offset from the previous time or the effects walk away
                local x, y, z = unit:GetRandomOffset(1)
                for _, emit in emitters[k].emts do
                    emit:OffsetEmitter(-v.x, -v.y, -v.z)
                    emit:OffsetEmitter(x, y, z)
                    PlaySparkleEffectAtUnitBeingBuilt(unit, unit, 'ConstructSparkle')
                end
                emitters[k].x = x
                emitters[k].y = y
                emitters[k].z = z
                emitters[k].counter = Random(0, 7)
            else
                emitters[k].counter = emitters[k].counter - 1
            end
        end
        WaitSeconds( 0.1 )
    end
end

function CreateFactoryBuildBeams(builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag)
    -- create a flashing kind of effect at the pad where the unit is being built
    for _, v in NomadsEffectTemplate.ConstructionDefaultBeingBuiltEffectsMobile do
        local emit = CreateAttachedEmitter(unitBeingBuilt, 0, builder.Army, v)
        BuildEffectsBag:Add(emit)
        unitBeingBuilt.Trash:Add(emit)
    end

    -- create the orange build rect used by the factory if it doesn't exist yet
    local builderbp = builder:GetBlueprint()
    if BuildEffectBones ~= nil then
        for _, bone in BuildEffectBones do
            local entity = Entity()
            Warp(entity, builder:GetPosition(bone))
            entity:AttachBoneTo(-1, builder, bone)
            entity:SetMesh('/effects/entities/NomadsBuildEffect/NomadsBuildField_mesh')
            entity:SetScale(builderbp.General.BuildEffectScaleX or 0.01, builderbp.General.BuildEffectScaleY or 0.5, builderbp.General.BuildEffectScaleZ or 0.5)
            entity:SetVizToAllies('Intel')
            entity:SetVizToNeutrals('Intel')
            entity:SetVizToEnemies('Intel')
            BuildEffectsBag:Add(entity)
        end
    end
end

function PlayNomadsReclaimEffects(reclaimer, reclaimed, BuildEffectBones, EffectsBag)
    local rBp = reclaimed:GetBlueprint()
    local sx, sy, sz = (rBp.SizeX or 1)/2, (rBp.SizeY or 1)/2, (rBp.SizeZ or 1)/2

    -- create beam entities
    local endEntityTable = CreateBeamEntities(reclaimer, reclaimed, BuildEffectBones, EffectsBag, NomadsEffectTemplate.ReclaimBeams, NomadsEffectTemplate.ReclaimBeamStartPoint, NomadsEffectTemplate.ReclaimBeamEndPoints)

    -- additional effects
    for k, v in NomadsEffectTemplate.ReclaimObjectAOE do
        EffectsBag:Add(CreateEmitterOnEntity(reclaimed, reclaimer.Army, v))
    end

    local ox, oy, oz = unpack(reclaimed:GetPosition())
    oy = GetTerrainHeight(ox, oz)

    -- start animation, move beam entities around
    while not reclaimer:BeenDestroyed() and not reclaimed:BeenDestroyed() do
        for _, entity in endEntityTable do
            if entity.counter <= 0 then
                local x = ox + RandomFloat(-sx, sx)
                local y = oy + RandomFloat(0, 2*sy)
                local z = oz + RandomFloat(-sz, sz)
                Warp(entity, Vector(x, y, z))
                entity.counter = Random(0, 2)
                PlaySparkleEffectAtUnitBeingBuilt(reclaimer, reclaimed, 'ReclaimSparkle')
            else
                entity.counter = entity.counter - 5
            end
        end
        WaitSeconds(0.5)
    end
end

function PlayNomadsReclaimEndEffects(reclaimer, reclaimed, EffectsBag)
    -- GPG version modified to show Nomads reclaim effects
    local army = -1
    if reclaimer then
        army = reclaimer.Army
    end
    for _, v in NomadsEffectTemplate.ReclaimBeamEndPoints do
        EffectsBag:Add( CreateEmitterAtEntity(reclaimed, army, v))
    end
    CreateLightParticleIntel(reclaimed, -1, army, 4, 6, 'glow_02', 'ramp_flare_02')
end