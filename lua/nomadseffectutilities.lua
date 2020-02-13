-- TODO: go over this again
local Entity = import('/lua/sim/Entity.lua').Entity
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

function CreateAmbientShieldEffects( unit, EffectsBag )
    local shield, bp = unit.MyShield, unit:GetBlueprint()

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
    while unit and not unit:BeenDestroyed() and not unit.Dead do
        for k, v in effectTable do
            local emit = CreateEmitterAtBone( unit, 0, unit.Army, v ):OffsetEmitter(0, offset, 0)
            EffectsBag:Add( emit )
        end
    end
end

function CreateBeamEntities( builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag, ConstructionBeams, ConstructionBeamStartPoint, ConstructionBeamEndPoints )
    -- the beams work like this:
    -- an entity is created on the unit that's being built. A beam emitter is created between the build bone and the entity.
    -- the entity is being instantly moved around on the unit that's being built
    local ox, oy, oz = unpack(unitBeingBuilt:GetPosition())
    local endEntityTable = {}

    if builder.BuildBones then
        BuildEffectBones = builder.BuildBones
    end

    -- Create build beams
    local beamsPerBone = builder:GetBlueprint().Display.NumberOfBuildBeams or NomadsEffectTemplate.ConstructionBeamsPerBuildBone or 1
    local beamEffect = nil
    for i, BuildBone in BuildEffectBones do

        for j=1, beamsPerBone do

            local BeamEndEntity = Entity()
            BeamEndEntity.counter = 0
            Warp( BeamEndEntity, Vector(ox, oy, oz))
            table.insert(endEntityTable, BeamEndEntity)
            BuildEffectsBag:Add( BeamEndEntity )

            -- beam
            for k, v in ConstructionBeams do
                local beamEffect = AttachBeamEntityToEntity(builder, BuildBone, BeamEndEntity, -1, builder.Army, v)
                BuildEffectsBag:Add( beamEffect)
            end

            -- beam endpoint emitters
            for _, ebp in ConstructionBeamEndPoints do
                local sparks = CreateEmitterOnEntity( BeamEndEntity, builder.Army, ebp )
                BuildEffectsBag:Add( sparks )
            end
        end
    end

    -- beam startpoint emitters
    for index, bone in BuildEffectBones do
        for k, v in ConstructionBeamStartPoint do
            local starteffect = CreateAttachedEmitter(builder, bone , builder.Army, v)
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

function CreateBuildCubeThread( unitBeingBuilt, builder, OnBeingBuiltEffectsBag )
    unitBeingBuilt:ShowBone(0, true)
    unitBeingBuilt:HideLandBones()
    unitBeingBuilt.BeingBuiltShowBoneTriggered = true
    if unitBeingBuilt:GetFractionComplete() >= 1 then
        return
    end

    local bp = unitBeingBuilt:GetBlueprint()

    -- Build cube stuff
    local ox = bp.Display.BuildEffect.OffsetX or 0
    local oy = bp.Display.BuildEffect.OffsetY or 0
    local oz = bp.Display.BuildEffect.OffsetZ or 0
    local scale = bp.Display.BuildEffect.Scale or 1
    if table.find( bp.Categories, 'SIZE4') then
        scale = scale * 0.25
    elseif table.find( bp.Categories, 'SIZE8') then
        scale = scale * 0.4
    elseif table.find( bp.Categories, 'SIZE12') then
        scale = scale * 0.8
    elseif table.find( bp.Categories, 'SIZE16') then
        scale = scale * 1
    elseif table.find( bp.Categories, 'SIZE20') then
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
    for k, v in EffectTable do
        local emit = CreateAttachedEmitter(unitBeingBuilt, 0, unitBeingBuilt.Army, v)
        emit:OffsetEmitter(ox, oy, oz)
        emit:ScaleEmitter(scale)
        OnBeingBuiltEffectsBag:Add( emit )
    end

    -- Create a quick glow effect at location where unit is goig to be built
    local mul = 1.15
    local x = bp.Physics.MeshExtentsX or (bp.Footprint.SizeX * mul)
    local z = bp.Physics.MeshExtentsZ or (bp.Footprint.SizeZ * mul)
    local y = bp.Physics.MeshExtentsY or (0.5 + (x + z) * 0.1)

    WaitSeconds(0.1)

    if unitBeingBuilt.Dead then
        return
    end

    if unitBeingBuilt:GetFractionComplete() >= 1 then
        unitBeingBuilt:HideLandBones()
        unitBeingBuilt.BeingBuiltShowBoneTriggered = true
        return
    end

    -- not sure why we're waiting here...
    WaitSeconds( 0.8 )

    unitBeingBuilt:HideLandBones()
    unitBeingBuilt.BeingBuiltShowBoneTriggered = true
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

CreateFactoryBuildBeams = function(builder, unitBeingBuilt, BuildEffectBones, BuildEffectsBag )
    -- create a flashing kind of effect at the pad where the unit is being built
    for k, v in NomadsEffectTemplate.ConstructionDefaultBeingBuiltEffectsMobile do
        local emit = CreateAttachedEmitter( unitBeingBuilt, 0, builder.Army, v )
        BuildEffectsBag:Add( emit )
        unitBeingBuilt.Trash:Add(emit)
    end

    -- create the orange build rect used by the factory if it doesn't exist yet
    local builderbp = builder:GetBlueprint()
    if BuildEffectBones ~= nil then
        for k, bone in BuildEffectBones do
            local entity = import('/lua/sim/Entity.lua').Entity()
            Warp( entity, builder:GetPosition(bone))
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

function PlayNomadsReclaimEffects( reclaimer, reclaimed, BuildEffectBones, EffectsBag )
    WaitSeconds(0.3)
    if not reclaimer or not reclaimed then return end

    local rBp = reclaimed:GetBlueprint()

    if not rBp then
        return
    end

    local sx, sy, sz = (rBp.SizeX or 1)/2, (rBp.SizeY or 1)/2, (rBp.SizeZ or 1)/2

    -- create beam entities
    local endEntityTable = CreateBeamEntities( reclaimer, reclaimed, BuildEffectBones, EffectsBag, NomadsEffectTemplate.ReclaimBeams, NomadsEffectTemplate.ReclaimBeamStartPoint, NomadsEffectTemplate.ReclaimBeamEndPoints )

    -- additional effects
    for k, v in NomadsEffectTemplate.ReclaimObjectAOE do
        EffectsBag:Add( CreateEmitterOnEntity( reclaimed, reclaimer.Army, v ) )
    end

    -- start animation, move beam entities around
    local pos = reclaimed:GetPosition()
    pos[2] = GetSurfaceHeight(pos[1], pos[3])

    local ox, oy, oz = unpack(pos)
    local ok = true  -- this threaded function keeps running even if the trashbag it's in is destroyed. This boolean is used to prevent this.

    while not reclaimer:BeenDestroyed() and not reclaimer.Dead and not reclaimed:BeenDestroyed() and ok do
        for k, v in endEntityTable do
            if not v:BeenDestroyed() then
                if endEntityTable[k].counter <= 0 then
                    local x = ox + RandomFloat(-sx, sx)
                    local y = oy + RandomFloat(0, 2*sy)
                    local z = oz + RandomFloat(-sz, sz)
                    Warp( v, Vector(x, y, z))
                    endEntityTable[k].counter = Random(0, 2)
                    PlaySparkleEffectAtUnitBeingBuilt( reclaimer, reclaimed, 'ReclaimSparkle' )
                else
                    endEntityTable[k].counter = endEntityTable[k].counter - 5
                end
            else
                ok = false
                break
            end
        end
        WaitSeconds( 0.5 )
    end
end

function PlayNomadsReclaimEndEffects( reclaimer, reclaimed, EffectsBag )
    -- GPG version modified to show Nomads reclaim effects
    local army = -1
    if reclaimer then
        army = reclaimer.Army
    end
    for k, v in NomadsEffectTemplate.ReclaimBeamEndPoints do
        EffectsBag:Add( CreateEmitterAtEntity( reclaimed, army, v ) )
    end
    CreateLightParticleIntel( reclaimed, -1, army, 4, 6, 'glow_02', 'ramp_flare_02' )
end