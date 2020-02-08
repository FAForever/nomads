local Util = import('/lua/utilities.lua')
local RandomFloat = Util.GetRandomFloat
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')
local Entity = import('/lua/sim/Entity.lua').Entity


Meteor = Class(NullShell) {
    InitialHeight = 300,

    FxScale = 1,
    ImpactLandFx = NomadsEffectTemplate.MeteorLandImpact,
    ImpactSeabedFx = NomadsEffectTemplate.MeteorSeabedImpact,
    ImpactWaterFx = NomadsEffectTemplate.MeteorWaterImpact,
    ResidualSmoke1 = NomadsEffectTemplate.MeteorResidualSmoke01,
    ResidualSmoke2 = NomadsEffectTemplate.MeteorResidualSmoke02,
    ResidualSmoke3 = NomadsEffectTemplate.MeteorResidualSmoke03,
    TrailFx = NomadsEffectTemplate.MeteorTrail,
    TrailUnderwaterFx = NomadsEffectTemplate.MeteorUnderWaterTrail,

    DecalLifetime = 240,

    OnCreate = function(self)
        NullShell.OnCreate(self)
        self.TrailFxBag = TrashBag()
    end,

    Start = function(self, ImpactPos, Time)
        self:SetAudio()
        self:SetPosAndVelocity(ImpactPos, Time)
        self:DescentEffects()
        self:MonitorDescent(ImpactPos)
    end,

    SetAudio = function(self)
        -- using a seperate entity for the sound fx cause the functionality seems to not work on projectiles
        local bp = self:GetBlueprint()
        local snd = bp.Audio.ExistLoop
        if snd then
            self.SndEntDescent = Entity()
            self.SndEntDescent:AttachTo(self, -2)
            self.SndEntDescent:SetAmbientSound(snd, nil)
        end
    end,

    SetPosAndVelocity = function(self, ImpactPos, Time)

        local dirVector
        local x,y,z

        if GetArmyBrain( self.Army ).ACULaunched then
            dirVector = GetArmyBrain( self.Army ).DirVector
            x,y,z = unpack(GetArmyBrain( self.Army ).startingPositionWithOffset)
            GetArmyBrain( self.Army ).ACULaunched = nil
        else
            local maxOffsetXZ = 0.25
            local offsetX = maxOffsetXZ * RandomFloat(-1, 1)
            local offsetZ = maxOffsetXZ * RandomFloat(-1, 1)
            dirVector = Vector( -offsetX, -1, -offsetZ )

            x, y, z = unpack( ImpactPos )
            y = GetTerrainHeight(x,z) + self.InitialHeight
            x = x + (offsetX * self.InitialHeight)
            z = z + (offsetZ * self.InitialHeight)
        end

        local speed = ( y - GetTerrainHeight(x,z) ) / Time
        self:SetPosition( Vector(x,y,z), true)
        self:SetOrientation( OrientFromDir(Util.GetDirectionVector(ImpactPos, dirVector)), true)
        self:SetVelocity(unpack(dirVector))
        self:SetVelocity(speed)
    end,

    DescentEffects = function(self)
        local emitters = {}
        local emit
        for k, v in self.TrailFx do
            emit = CreateAttachedEmitter(self, -1, self.Army, v)
            emit:ScaleEmitter(self.FxScale)
            self.Trash:Add(emit)
            self.TrailFxBag:Add(emit)
            table.insert(emitters, emit)
        end
    end,

    DestroyDescentEffects = function(self)
        self.TrailFxBag:Destroy()
    end,

    DescentEffectsUnderWater = function(self)
        local emitters = {}
        local emit
        for k, v in self.TrailUnderwaterFx do
            emit = CreateAttachedEmitter(self, -1, self.Army, v)
            emit:ScaleEmitter(self.FxScale)
            self.Trash:Add(emit)
            self.TrailFxBag:Add(emit)
            table.insert(emitters, emit)
        end
    end,

    MonitorDescent = function(self, ImpactPos)
        -- the OnImpact event is not fired when the meteor enters water so check the flight and fire the event manually
        local fn = function(self, waterY)
            local x,y,z
            while self do
                x,y,z = unpack(self:GetPosition())
                if (y - waterY) <= 2.5 then  -- trying to trigger this before hitting seabed. On shallow water the Onimpact events for water and seabed play at some tick.
                    self:OnImpact('Water', nil)
                    return true
                end
                WaitTicks(1)
            end
            return false
        end

        local x,y,z = unpack(ImpactPos)
        if GetTerrainHeight(x, z) < GetSurfaceHeight(x, z) then  -- check that there's water at impact pos
            self.MonitorDescentThreadHandle = self:ForkThread(fn, GetSurfaceHeight(x, z) )
        end
    end,

    -- -------------------------------------------------------------------------------------------------------------------

    OnImpact = function(self, targetType, targetEntity)
        if targetType == 'Water' then
            self:ImpactWaterSurfaceEffects(self:GetPosition(), self.FxScale)
        elseif targetType == 'Terrain' or targetType == 'UnderWater' then
            local x,y,z = unpack(self:GetPosition())
            local ImpactSeabed = GetTerrainHeight(x, z) < GetSurfaceHeight(x, z)
            self:ImpactEffects(self:GetPosition(), ImpactSeabed, self.FxScale)
            self:Destroy()
        end
    end,

    ImpactWaterSurfaceEffects = function(self, position, scale)

        self:DestroyDescentEffects()
        self:DescentEffectsUnderWater()

        local emitters = {}
        local emit

        position[2] = GetSurfaceHeight(position[1], position[3])

        CreateLightParticleIntel(self, -1, self.Army, (7 * scale), 8, 'glow_03', 'ramp_yellow_02')

        local FxEnt = Entity()
        Warp(FxEnt, position)
        for k, v in self.ImpactWaterFx do
            emit = CreateEmitterAtEntity(FxEnt, self.Army, v)
            table.insert(emitters, emit)
            emit:ScaleEmitter(scale)
        end
        FxEnt:Destroy()

        self.SndEntDescent:Destroy()

        local bpAud = self:GetBlueprint().Audio
        local snd = bpAud['ImpactWater']
        if snd then
            self:PlaySound(snd)
        elseif bpAud.Impact then
            self:PlaySound(bpAud.Impact)
        end

        self:CreateOuterRingWaveSmokeRing(scale)
    end,

    ImpactEffects = function(self, position, InWater, scale)
        local emitters = {}
        local emit

        -- Create ground decals
        local orientation = RandomFloat( 0, 2 * math.pi )
        if scale == 1 then
            CreateDecal(position, orientation, 'Crater01_albedo', '', 'Albedo', (30 * scale), (30 * scale), self.DecalLifetime, 800, self.Army)
            CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', (30 * scale), (30 * scale), self.DecalLifetime, 800, self.Army)
            CreateDecal(position, orientation, 'nuke_scorch_003_albedo', '', 'Albedo', (30 * scale), (30 * scale), self.DecalLifetime, 800, self.Army)
        else
            CreateDecal(position, orientation, 'Crater01_albedo', '', 'Albedo', (10 * scale), (10 * scale), self.DecalLifetime, 800, self.Army)
            CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', (10 * scale), (10 * scale), self.DecalLifetime, 800, self.Army)
            CreateDecal(position, orientation, 'nuke_scorch_003_albedo', '', 'Albedo', (10 * scale), (10 * scale), self.DecalLifetime, 800, self.Army)
        end
        -- Impact effects
        CreateLightParticleIntel(self, -1, self.Army, (5 * scale), 10, 'glow_03', 'ramp_yellow_02')

        self.SndEntDescent:Destroy()

        if not InWater then
            local bpAud = self:GetBlueprint().Audio
            local snd = bpAud['ImpactTerrain']
            if snd then
                self:PlaySound(snd)
            elseif bpAud.Impact then
                self:PlaySound(bpAud.Impact)
            end

            for k, v in self.ImpactLandFx do
                emit = CreateEmitterAtEntity(self, self.Army, v)
                table.insert(emitters, emit)
                emit:ScaleEmitter(scale)
                if (k == 2 or k == 4) and scale ~= 1 then
                    emit:ScaleEmitter(scale/3)
                end
            end

            -- Knockdown force rings
            ForkThread(self.ForceDamageThread, self, position)
        else

            local bpAud = self:GetBlueprint().Audio
            local snd = bpAud['ImpactUnderWater']
            if snd then
                self:PlaySound(snd)
            elseif bpAud.Impact then
                self:PlaySound(bpAud.Impact)
            end

            for k, v in self.ImpactSeabedFx do
                emit = CreateEmitterAtEntity(self, self.Army, v)
                table.insert(emitters, emit)
                emit:ScaleEmitter(scale)
            end

        end
    end,
    
    ForceDamageThread = function(self, position)
        --This complicated procedure is identical to the other factions, and ensures that trees are knocked down properly at the starting area.
        --The two rounds of force are there to first break tree groups, and then to knock over the broken trees. yeah.
        position[2] = position[2] + 2 --Raise the AOE effect above the collision boxes of the trees to prevent collisions not being checked
        DamageRing(self, position, .1, 11, 100, 'Force', false, false)
        WaitSeconds(.1)
        DamageRing(self, position, .1, 11, 100, 'Force', false, false)

        -- Knockdown force rings
        WaitSeconds(0.39)
        DamageRing(self, position, 11, 20, 1, 'Force', false, false)
        WaitSeconds(.1)
        DamageRing(self, position, 11, 20, 1, 'Force', false, false)
        WaitSeconds(0.5)

        -- Scorch decal and light some trees on fire
        WaitSeconds(0.3)
        DamageRing(self, position, 20, 27, 1, 'Fire', false, false)
    end,
}

TypeClass = Meteor
