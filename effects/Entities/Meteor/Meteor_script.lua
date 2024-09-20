local Util = import('/lua/utilities.lua')
local RandomFloat = Util.GetRandomFloat
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local Entity = import('/lua/sim/Entity.lua').Entity

---@class Meteor : NullShell
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

    ---@param self Meteor
    OnCreate = function(self)
        NullShell.OnCreate(self)
        self.TrailFxBag = TrashBag()
    end,

    ---@param self Meteor
    ---@param ImpactPos Vector3
    ---@param Time number
    Start = function(self, ImpactPos, Time)
        self:SetAudio()
        self:SetPosAndVelocity(ImpactPos, Time)
        self:DescentEffects()
        self:MonitorDescent(ImpactPos)
    end,

    --- using a seperate entity for the sound fx cause the functionality seems to not work on projectiles
    ---@param self Meteor
    SetAudio = function(self)
        local bp = self.Blueprint
        local snd = bp.Audio.ExistLoop
        if snd then
            self.SndEntDescent = Entity()
            self.SndEntDescent:AttachTo(self, -2)
            self.SndEntDescent:SetAmbientSound(snd, nil)
        end
    end,

    ---@param self Meteor
    ---@param ImpactPos Vector3
    ---@param Time number
    SetPosAndVelocity = function(self, ImpactPos, Time)
        local dirVector
        local x,y,z
        local army = self.Army

        if GetArmyBrain( army ).ACULaunched then
            dirVector = GetArmyBrain( army ).DirVector
            x,y,z = unpack(GetArmyBrain( army ).startingPositionWithOffset)
            GetArmyBrain( army ).ACULaunched = nil
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

    ---@param self Meteor
    DescentEffects = function(self)
        for _, v in self.TrailFx do
            local emit = CreateAttachedEmitter(self, -1, self.Army, v)
            emit:ScaleEmitter(self.FxScale)
            self.Trash:Add(emit)
            self.TrailFxBag:Add(emit)
        end
    end,

    ---@param self Meteor
    DestroyDescentEffects = function(self)
        self.TrailFxBag:Destroy()
    end,

    ---@param self Meteor
    DescentEffectsUnderWater = function(self)
        for _, v in self.TrailUnderwaterFx do
            local emit = CreateAttachedEmitter(self, -1, self.Army, v)
            emit:ScaleEmitter(self.FxScale)
            self.Trash:Add(emit)
            self.TrailFxBag:Add(emit)
        end
    end,

    ---@param self Meteor
    ---@param ImpactPos Vector3
    MonitorDescent = function(self, ImpactPos)
        -- the OnImpact event is not fired when the meteor enters water so check the flight and fire the event manually
        local fn = function(self, waterY)
            while self do
                local x,y,z = unpack(self:GetPosition())
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

    ---@param self Meteor
    ---@param targetType string
    ---@param targetEntity Unit unused
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

    ---@param self Meteor
    ---@param position Vector3
    ---@param scale number
    ImpactWaterSurfaceEffects = function(self, position, scale)
        self:DestroyDescentEffects()
        self:DescentEffectsUnderWater()

        local army = self.Army
        local bp = self.Blueprint

        position[2] = GetSurfaceHeight(position[1], position[3])

        CreateLightParticleIntel(self, -1, army, (7 * scale), 8, 'glow_03', 'ramp_yellow_02')

        local FxEnt = Entity()
        Warp(FxEnt, position)
        for _, v in self.ImpactWaterFx do
            local emit = CreateEmitterAtEntity(FxEnt, army, v)
            emit:ScaleEmitter(scale)
        end
        FxEnt:Destroy()

        self.SndEntDescent:Destroy()

        local bpAud = bp.Audio
        local snd = bpAud['ImpactWater']
        if snd then
            self:PlaySound(snd)
        elseif bpAud.Impact then
            self:PlaySound(bpAud.Impact)
        end

        self:CreateOuterRingWaveSmokeRing(scale)
    end,

    ---@param self Meteor
    ---@param position Vector3
    ---@param InWater boolean
    ---@param scale number
    ImpactEffects = function(self, position, InWater, scale)
        -- Create ground decals
        local orientation = RandomFloat( 0, 2 * math.pi )
        local army = self.Army
        local bp = self.Blueprint

        if scale == 1 then
            CreateDecal(position, orientation, 'Crater01_albedo', '', 'Albedo', (30 * scale), (30 * scale), self.DecalLifetime, 800, army)
            CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', (30 * scale), (30 * scale), self.DecalLifetime, 800, army)
            CreateDecal(position, orientation, 'nuke_scorch_003_albedo', '', 'Albedo', (30 * scale), (30 * scale), self.DecalLifetime, 800, army)
        else
            CreateDecal(position, orientation, 'Crater01_albedo', '', 'Albedo', (10 * scale), (10 * scale), self.DecalLifetime, 800, army)
            CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', (10 * scale), (10 * scale), self.DecalLifetime, 800, army)
            CreateDecal(position, orientation, 'nuke_scorch_003_albedo', '', 'Albedo', (10 * scale), (10 * scale), self.DecalLifetime, 800, army)
        end
        -- Impact effects
        CreateLightParticleIntel(self, -1, army, (5 * scale), 10, 'glow_03', 'ramp_yellow_02')

        self.SndEntDescent:Destroy()

        local bpAud = bp.Audio
        local snd = bpAud['ImpactTerrain']
        if InWater then
            snd = bpAud['ImpactUnderWater']
        end
        if snd then
            self:PlaySound(snd)
        elseif bpAud.Impact then
            self:PlaySound(bpAud.Impact)
        end

        if not InWater then
            for k, v in self.ImpactLandFx do
                local emit = CreateEmitterAtEntity(self, army, v)
                emit:ScaleEmitter(scale)
                if (k == 2 or k == 4) and scale ~= 1 then
                    emit:ScaleEmitter(scale/3)
                end
            end

            -- Knockdown force rings
            ForkThread(self.ForceDamageThread, self, position)
        else
            for _, v in self.ImpactSeabedFx do
                local emit = CreateEmitterAtEntity(self, army, v)
                emit:ScaleEmitter(scale)
            end
        end
    end,

    ---@param self Meteor
    ---@param position Vector3
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