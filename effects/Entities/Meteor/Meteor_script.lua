local Util = import('/lua/utilities.lua')
local RandomFloat = Util.GetRandomFloat
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')
local Entity = import('/lua/sim/Entity.lua').Entity


Meteor = Class(NullShell) {

    Damage = 10000,
    DamageFriendly = true,
    DamageRadius = 10,
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

    DecalLifetime = 60,

    OnCreate = function(self)
        NullShell.OnCreate(self)
        self.TrailFxBag = TrashBag()
    end,

    Start = function(self, ImpactPos, Time)
        self:SetVisuals()
        self:SetAudio()
        self:SetPosAndVelocity(ImpactPos, Time)
        self:DescentEffects()
        self:MonitorDescent(ImpactPos)
    end,

    SetVisuals = function(self)
        if Random(0,5) == 0 then
            self:SetMesh('/effects/Entities/Meteor/Meteor6_mesh.bp')
            self:SetDrawScale(0.03 * self.FxScale)
        elseif Random(0,4) == 0 then
            self:SetMesh('/effects/Entities/Meteor/Meteor5_mesh.bp')
            self:SetDrawScale(0.05 * self.FxScale)
        elseif Random(0,3) == 0 then
            self:SetMesh('/effects/Entities/Meteor/Meteor4_mesh.bp')
            self:SetDrawScale(0.05 * self.FxScale)
        elseif Random(0,2) == 0 then
            self:SetMesh('/effects/Entities/Meteor/Meteor3_mesh.bp')
            self:SetDrawScale(0.05 * self.FxScale)
        elseif Random(0,1) == 0 then
            self:SetMesh('/effects/Entities/Meteor/Meteor2_mesh.bp')
            self:SetDrawScale(0.025 * self.FxScale)
        else
            self:SetMesh('/effects/Entities/Meteor/Meteor1_mesh.bp')
            self:SetDrawScale(0.05 * self.FxScale)
        end
    end,

    SetAudio = function(self)
        -- using a seperate entity for the sound fx cause the functionality seems to not work on projectiles
        local bp = self:GetBlueprint()
        local snd = bp.Audio.ExistLoop
        if snd then
            self.SndEntDescent = Entity()
            self.SndEntDescent:AttachTo(self, 0)
            self.SndEntDescent:SetAmbientSound(snd, nil)
        end
    end,

    SetPosAndVelocity = function(self, ImpactPos, Time)
        local maxOffsetXZ = 0.25

        local offsetX = maxOffsetXZ * RandomFloat(-1, 1)
        local offsetZ = maxOffsetXZ * RandomFloat(-1, 1)
        local DirVect = Vector( -offsetX, -1, -offsetZ )

        local x, y, z = unpack( ImpactPos )
        y = GetTerrainHeight(x,z) + self.InitialHeight
        x = x + (offsetX * self.InitialHeight)
        z = z + (offsetZ * self.InitialHeight)

        local speed = self.InitialHeight / Time

        self:SetPosition( Vector(x,y,z), true)
        self:SetOrientation( OrientFromDir(Util.GetDirectionVector(ImpactPos, DirVect)), true)
        self:SetVelocity(unpack(DirVect))
        self:SetVelocity(speed)
    end,

    DescentEffects = function(self)
        local army = self:GetArmy()
        local emitters = {}
        local emit
        for k, v in self.TrailFx do
            emit = CreateAttachedEmitter(self, -1, army, v)
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
        local army = self:GetArmy()
        local emitters = {}
        local emit
        for k, v in self.TrailUnderwaterFx do
            emit = CreateAttachedEmitter(self, -1, army, v)
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
            self:DoDamage()
            self:ImpactEffects(self:GetPosition(), ImpactSeabed, self.FxScale)
            self:Destroy()
        end
    end,

    DoDamage = function(self)
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageRadius, self.Damage, 'Normal', self.DamageFriendly, false)
    end,

    ImpactWaterSurfaceEffects = function(self, position, scale)

        self:DestroyDescentEffects()
        self:DescentEffectsUnderWater()

        local army = self:GetArmy()
        local emitters = {}
        local emit

        position[2] = GetSurfaceHeight(position[1], position[3])

        CreateLightParticleIntel(self, -1, army, (7 * scale), 8, 'glow_03', 'ramp_yellow_02')

        local FxEnt = Entity()
        Warp(FxEnt, position)
        for k, v in self.ImpactWaterFx do
            emit = CreateEmitterAtEntity(FxEnt, army, v)
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

        -- Knockdown force rings
        DamageRing(self, position, 0.1, (12 * scale), 1, 'Force', true)
        DamageRing(self, position, 0.1, (12 * scale), 1, 'Force', true)

        self:CreateOuterRingWaveSmokeRing(scale)
    end,

    ImpactEffects = function(self, position, InWater, scale)

        local army = self:GetArmy()
        local emitters = {}
        local emit

        -- Create ground decals
        local orientation = RandomFloat( 0, 2 * math.pi )
        CreateDecal(position, orientation, 'Crater01_albedo', '', 'Albedo', (30 * scale), (30 * scale), self.DecalLifetime, 0, army)
        CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', (30 * scale), (30 * scale), self.DecalLifetime, 0, army)
        CreateDecal(position, orientation, 'nuke_scorch_003_albedo', '', 'Albedo', (30 * scale), (30 * scale), self.DecalLifetime, 0, army)

        -- Impact effects
        CreateLightParticleIntel(self, -1, army, (20 * scale), 10, 'glow_03', 'ramp_yellow_02')

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
                emit = CreateEmitterAtEntity(self, army, v)
                table.insert(emitters, emit)
                emit:ScaleEmitter(scale)
            end

            -- Knockdown force rings
            DamageRing(self, position, 0.1, (19 * scale), 1, 'Fire', true)
            DamageRing(self, position, 0.1, (15 * scale), 1, 'Force', true)
            DamageRing(self, position, 0.1, (15 * scale), 1, 'Force', true)

            -- Additional effects
            self:CreateOuterRingWaveSmokeRing(scale)
            self:ResidualSmokeEffects(self:GetPosition(), scale)

        else

            local bpAud = self:GetBlueprint().Audio
            local snd = bpAud['ImpactUnderWater']
            if snd then
                self:PlaySound(snd)
            elseif bpAud.Impact then
                self:PlaySound(bpAud.Impact)
            end

            for k, v in self.ImpactSeabedFx do
                emit = CreateEmitterAtEntity(self, army, v)
                table.insert(emitters, emit)
                emit:ScaleEmitter(scale)
            end

        end
    end,

    CreateOuterRingWaveSmokeRing = function(self, scale)

        local sides = 24
        local velocity = 8
        local offset = 8 * scale
        local angle = (2*math.pi) / sides

        local projectiles = {}
        local x, z, proj

        for i = 1, sides do
            x = math.sin(i*angle)
            z = math.cos(i*angle)
            proj = self:CreateProjectile('/effects/entities/MeteorDustCloud/MeteorDustCloud_proj.bp', x * offset , 2.5, z * offset, x, 0, z)
            proj:SetVelocity(velocity)
            table.insert( projectiles, proj )
        end  

        local fn = function(self, projectiles)
            WaitSeconds( 1 )
            for k, v in projectiles do
                v:SetAcceleration(-0.4)
            end
            WaitSeconds(11)
            for k, v in projectiles do
                v:Destroy()
            end
        end
        ForkThread(fn, self, projectiles)
    end,

    ResidualSmokeEffects = function(self, centerPos, scale)
        local x, y, z, a, t, e, o, ent
        local n = Random(0,4)
        local emitters = {}
        local army = self:GetArmy()
        local maxOffset = 18 * scale

        for i=1, n do

            o = maxOffset * RandomFloat(0.2, 1)
            a = RandomFloat( 0, 2 * math.pi )
            x = centerPos[1] + (math.sin(a) * o)
            z = centerPos[3] + (math.cos(a) * o)
            y = GetSurfaceHeight(x,z)

            if Random(0,2) == 0 then
                t = self.ResidualSmoke1
            elseif Random(0,1) == 0 then
                t = self.ResidualSmoke2
            else
                t = self.ResidualSmoke3
            end

            for k, v in t do
                ent = Entity()
                ent:SetPosition( Vector(x,y,z), true)
                e = CreateEmitterAtEntity(ent, army, v)
                table.insert(emitters, e)
                ent:Destroy()
            end

        end
    end,
}

TypeClass = Meteor
