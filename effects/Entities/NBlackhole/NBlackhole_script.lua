-- Nomad black hole

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')
local Util = import('/lua/utilities.lua')
local RandomFloat = Util.GetRandomFloat
local Entity = import('/lua/sim/Entity.lua').Entity
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

NBlackhole = Class(NullShell) {

    BlackholeCoreFx = NomadEffectTemplate.NukeBlackholeCore,
    BlackholeDissipatingFx = NomadEffectTemplate.NukeBlackholeDissipating,
    DissipatedFx = NomadEffectTemplate.NukeBlackholeDissipated,
    FlashFx = NomadEffectTemplate.NukeBlackholeFlash,
    GenericFx = NomadEffectTemplate.NukeBlackholeGeneric,
    RadiationBeams = NomadEffectTemplate.NukeBlackholeRadiationBeams,
    RadiationBeamLengths = NomadEffectTemplate.NukeBlackholeRadiationBeamLengths,
    RadiationBeamThickness = NomadEffectTemplate.NukeBlackholeRadiationBeamThickness,
    logo = false,

    OnCreate = function(self)
        NullShell.OnCreate(self)
        self.UnitsBeingSuckedIn = {}
        self.PropsBeingSuckedIn = {}
        self.WreckageResources = { e = 0, h = 1, m = 1, t = 1, }
        self.NukeBlackHoleFxScale = 1
        self:SetParent( self:GetLauncher() )

        -- make sure the black hole is above the surface
        local pos = self:GetPosition()
        self.surfaceY = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
        if pos[2] < (self.surfaceY + 4) then
            pos[2] = self.surfaceY + 4
            Warp( self, pos )
        end
    end,

    SetParent = function(self, parent)
        self.parent = parent

        if EntityCategoryContains( categories.COMMAND, parent ) then
            -- adjust effects for the ACU
            self.BlackholeCoreFx = NomadEffectTemplate.ACUDeathBlackholeCore
            self.DissipatedFx = NomadEffectTemplate.ACUDeathBlackholeDissipated
            self.FlashFx = NomadEffectTemplate.ACUDeathBlackholeFlash
            self.GenericFx = NomadEffectTemplate.ACUDeathBlackholeGeneric
            self.IsAcuDeathNuke = true
        end
    end,

    SetLogo = function(self, bool)
        self.logo = (bool == true)
    end,

    PassData = function(self, Data)
        if Data.NukeOuterRingDamage then self.NukeOuterRingDamage = Data.NukeOuterRingDamage end
        if Data.NukeOuterRingRadius then self.NukeOuterRingRadius = Data.NukeOuterRingRadius end
        if Data.NukeOuterRingTicks then self.NukeOuterRingTicks = Data.NukeOuterRingTicks end
        if Data.NukeOuterRingTotalTime then self.NukeOuterRingTotalTime = Data.NukeOuterRingTotalTime end
        if Data.NukeInnerRingDamage then self.NukeInnerRingDamage = Data.NukeInnerRingDamage end
        if Data.NukeInnerRingRadius then self.NukeInnerRingRadius = Data.NukeInnerRingRadius end
        if Data.NukeInnerRingTicks then self.NukeInnerRingTicks = Data.NukeInnerRingTicks end
        if Data.NukeInnerRingTotalTime then self.NukeInnerRingTotalTime = Data.NukeInnerRingTotalTime end
        if Data.NukeBlackHoleMinDuration then self.NukeBlackHoleMinDuration = Data.NukeBlackHoleMinDuration end
        if Data.NukeBlackHoleFxScale then self.NukeBlackHoleFxScale = Data.NukeBlackHoleFxScale end
        if Data.NukeBlackHoleFxLogo then self:SetLogo( Data.NukeBlackHoleFxLogo ) end

        if Data.NukeBlackHoleFireballDamage then self.NukeBlackHoleFireballDamage = Data.NukeBlackHoleFireballDamage end
        if Data.NukeBlackHoleFireballRadius then self.NukeBlackHoleFireballRadius = Data.NukeBlackHoleFireballRadius end
        if Data.NukeBlackHoleFireballDamageType then self.NukeBlackHoleFireballDamageType = Data.NukeBlackHoleFireballDamageType end

        self:CreateNuclearExplosion()
    end,

    CreateNuclearExplosion = function(self)
        local lifetime = math.max( math.max( self.NukeOuterRingTotalTime, self.NukeInnerRingTotalTime ), self.NukeBlackHoleMinDuration )

        -- Create Damage Threads
        self:ForkThread(self.OuterRingDamage)
        self:ForkThread(self.InnerRingDamage)

        -- Create thread that spawns and controls effects. Also eventually destroys this entity
        self:ForkThread(self.EffectThread, lifetime)
    end,

    OuterRingDamage = function(self)
        local myPos = self:GetPosition()
        if self.NukeOuterRingTotalTime == 0 then
            DamageArea( self, myPos, self.NukeOuterRingRadius, self.NukeOuterRingDamage, self.DamageData.DamageType or 'BlackholeDamage', true, false)

        else
            local ringWidth = ( self.NukeOuterRingRadius / self.NukeOuterRingTicks )
            local tickLength = ( self.NukeOuterRingTotalTime / self.NukeOuterRingTicks )
            DamageArea( self, myPos, ringWidth, self.NukeOuterRingDamage, self.DamageData.DamageType or 'BlackholeDamage', true, false )
            WaitSeconds( tickLength )
            for i = 2, self.NukeOuterRingTicks do
                DamageRing( self, myPos, ringWidth * (i - 1), ringWidth * i, self.NukeOuterRingDamage, self.DamageData.DamageType or 'BlackholeDamage', true, false)
                WaitSeconds(tickLength)
            end
        end
    end,

    InnerRingDamage = function(self)
        local myPos = self:GetPosition()
        if self.NukeInnerRingTotalTime == 0 then
            DamageArea( self, myPos, self.NukeInnerRingRadius, self.NukeInnerRingDamage, self.DamageData.DamageType or 'BlackholeDamage', true, false)

        else
            local ringWidth = ( self.NukeInnerRingRadius / self.NukeInnerRingTicks )
            local tickLength = ( self.NukeInnerRingTotalTime / self.NukeInnerRingTicks )
            DamageArea( self, myPos, ringWidth, self.NukeInnerRingDamage, self.DamageData.DamageType or 'BlackholeDamage', true, false )
            WaitSeconds(tickLength)
            for i = 2, self.NukeInnerRingTicks do
                DamageRing( self, myPos, ringWidth * (i - 1), ringWidth * i, self.NukeInnerRingDamage, self.DamageData.DamageType or 'BlackholeDamage', true, false )
                WaitSeconds(tickLength)
            end
        end
    end,

    OnKilledUnit = function(self, unit)
        if self.parent and not self.parent:BeenDestroyed() and IsUnit(self.parent) and not self.parent:IsDead() then
            local kills = self.parent:GetStat('KILLS', 0).Value
            self.parent:SetStat( 'KILLS', kills + 1 )
            self.parent:CheckVeteranLevel()
        end
    end,

    OnUnitBeingSuckedIn = function(self, unit)
        table.insert( self.UnitsBeingSuckedIn, unit )
    end,

    OnPropBeingSuckedIn = function(self, prop)
        table.insert( self.PropsBeingSuckedIn, prop )

        -- remember reclaim values
        local e = math.max(0, prop.EnergyReclaim or 0)
        local m = math.max(0, prop.MassReclaim or 0)
        local t = math.max(e * (prop.ReclaimTimeEnergyMult or 1), m * (prop.ReclaimTimeMassMult or 1))
        self.WreckageResources['e'] = self.WreckageResources['e'] + e
        self.WreckageResources['m'] = self.WreckageResources['m'] + m
        self.WreckageResources['t'] = self.WreckageResources['t'] + t
    end,

    OnUnitSuckedIn = function(self, unit, unitOverkillRatio)
        table.removeByValue( self.UnitsBeingSuckedIn, unit )

        -- some units are so overkilled that there's no reclaim to be added. In case no overkill is specified the assumption is also that
        -- no reclaim was left.
        if unitOverkillRatio and unitOverkillRatio >= 0 and unitOverkillRatio < 1 then
            -- remember reclaim values
            local bp = unit:GetBlueprint()
            local e = bp.Economy.BuildCostEnergy * (bp.Wreckage.EnergyMult or 0) * unit:GetFractionComplete() * (1 - unitOverkillRatio)
            local m = bp.Economy.BuildCostMass * (bp.Wreckage.MassMult or 0) * unit:GetFractionComplete() * (1 - unitOverkillRatio)
            local t = (bp.Wreckage.ReclaimTimeMultiplier or 1) * (unitOverkillRatio or 1)
            self.WreckageResources['e'] = self.WreckageResources['e'] + e
            self.WreckageResources['m'] = self.WreckageResources['m'] + m
            self.WreckageResources['t'] = self.WreckageResources['t'] + t
        end
    end,

    OnDestroy = function(self)
        -- notify units being sucked in that the black hole is gone
        for k, unit in self.UnitsBeingSuckedIn do
            if unit and not unit:BeenDestroyed() then
                unit:OnBlackHoleDissipated()
            end
        end
        for k, prop in self.PropsBeingSuckedIn do
            if prop and not prop:BeenDestroyed() then
                prop:OnBlackHoleDissipated()
            end
        end
        NullShell.OnDestroy(self)
    end,

    CreateWreckage = function(self)
        local wreckBp = '/effects/Entities/NBlackholeLeftover/NBlackholeLeftover_prop.bp'
        local wreckScale = 1

        local pos = self:GetPosition()
        local surface = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
        pos[2] = surface + (wreckScale * 0.4)
        local prop = CreateProp( pos, wreckBp )

        prop:SetScale( wreckScale )
        prop:SetOrientation(self:GetOrientation(), true)
        prop:SetPropCollision('Box', wreckScale, wreckScale, wreckScale, (wreckScale * 0.5), (wreckScale * 0.5), (wreckScale * 0.5))

        self:SetWreckageProperties( prop, self.WreckageResources )

        return prop
    end,

    SetWreckageProperties = function(self, prop, resources)
        prop:SetMaxReclaimValues( 1, 1, resources['m'], resources['e'] )
        prop:SetReclaimValues( 1, 1, resources['m'], resources['e'] )
        prop:AddBoundedProp( resources['m'] )

        prop:SetMaxHealth( resources['h'] )
        prop:SetHealth( self, resources['h'] )
    end,

-- ===========================================================================================================================================================

    EffectThread = function(self, lifetime)
        local army = self:GetArmy()
        local bag = TrashBag()
        local cloudsBag = TrashBag()
        local threads = TrashBag()

        -- BLACK HOLE EFFECTS ===========================================

        -- in case this is the ACU death nuke making sure the effect can be seen by the defeated player
        if self.IsAcuDeathNuke then
            self:Camera( nil, lifetime + 2.5 )
        end

        -- start effect threads
        threads:Add( self:ForkThread( self.CoreEffects, bag, lifetime) )
        threads:Add( self:ForkThread( self.RadiationJetEffects, bag, lifetime) )
        threads:Add( self:ForkThread( self.DisposableCoreEffects, bag, lifetime) )
        threads:Add( self:ForkThread( self.CloudsThread, cloudsBag, lifetime) )
        threads:Add( self:ForkThread( self.CloudsThread2, cloudsBag, lifetime) )
        threads:Add( self:ForkThread( self.LightningThread, bag, lifetime) )
        threads:Add( self:ForkThread( self.PropThread, bag, lifetime) )

        -- Create ground decals
        local pos = self:GetPosition()
        local orientation = RandomFloat( 0, 2 * math.pi )
        CreateDecal(pos, orientation, 'Crater01_albedo', '', 'Albedo', 30, 30, 1200, 0, army)
        CreateDecal(pos, orientation, 'Crater01_normals', '', 'Normals', 30, 30, 1200, 0, army)
        CreateDecal(pos, orientation, 'nuke_scorch_003_albedo', '', 'Albedo', 30, 30, 1200, 0, army)

        -- wait till the lifetime (for the black hole) is over, clean up the effects and move on to the dissipating effects
        WaitSeconds( lifetime )
        bag:Destroy()
        threads:Destroy()

        -- BLACK HOLE DISSIPATING =======================================

        lifetime = 3.5

        threads:Add( self:ForkThread( self.DissipateEffects, bag, lifetime) )

        -- wait till the dissipating is over, clean up the effects and move on to the aftermath effects
        WaitSeconds( lifetime )
        cloudsBag:Destroy()
        bag:Destroy()
        threads:Destroy()

        -- AFTERMATH ====================================================

        lifetime = 20

        -- leave a wreckage to reclaim the sucked in mass (and energy)
        local wreck = self:CreateWreckage()

        -- start effect threads
        threads:Add( self:ForkThread( self.AftermathExplosion, bag, lifetime, wreck ) )
        threads:Add( self:ForkThread( self.AftermathFireBalls, bag, lifetime, wreck ) )
        if self.logo then
            threads:Add( self:ForkThread( self.AftermathFireArmsLogo, bag, lifetime, wreck ) )
        else
            threads:Add( self:ForkThread( self.AftermathFireArmsRandom, bag, lifetime, wreck ) )
        end

        WaitSeconds( lifetime )
        bag:Destroy()
        threads:Destroy()

        self:Destroy()
    end,

    Camera = function(self, bag, lifetime)
        -- creates a camera so the effect is visible through the fog
        local pos = self:GetPosition()
        local spec = {
            X = pos[1],
            Z = pos[3],
            Radius = 20,
            LifeTime = lifetime,
            Omni = false,
            Radar = false,
            Vision = true,
            Army = self:GetArmy(),
        }
        local cam = VizMarker(spec)
        self.Trash:Add( cam )
        if bag then bag:Add( cam ) end
        return cam
    end,

    PlayBlackholeSound = function(self, name)
        local snd = Sound( {
            Bank = 'NomadsDestroy',
            Cue = name,
        })
        self:PlaySound(snd)
        --LOG('PlayBlackholeSound = '..repr(name))
    end,

    PlayBlackholeAmbientSound = function(self, name)
        if not self.AmbientSounds then
            self.AmbientSounds = {}
        end
        if not self.AmbientSounds[name] then
            local sndEnt = Entity {}
            self.AmbientSounds[name] = sndEnt
            self.Trash:Add(sndEnt)
            sndEnt:AttachTo(self,-1)
        end
        local snd = Sound( {
            Bank = 'NomadsDestroy',
            Cue = name,
        })
        self.AmbientSounds[name]:SetAmbientSound( snd, nil )
        --LOG('PlayBlackholeAmbientSound = '..repr(name))
    end,

    StopBlackholeAmbientSound = function(self, name)
        if not self.AmbientSounds[name] then return end
        self.AmbientSounds[name]:SetAmbientSound(nil, nil)
        self.AmbientSounds[name]:Destroy()
        self.AmbientSounds[name] = nil
        --LOG('StopBlackholeAmbientSound = '..repr(name))
    end,

    -- =======================================================================================================================

    CoreEffects = function(self, bag, lifetime)
        local army = self:GetArmy()
        local emit

        -- short flash
        self:ShakeCamera( 55, 2.5, 0, lifetime or 0.5 )
        CreateLightParticleIntel( self, -1, army, (10 * self.NukeBlackHoleFxScale), 2, 'glow_02', 'ramp_white_01')
        for k, v in self.FlashFx do
            emit = CreateEmitterOnEntity(self, army, v ):ScaleEmitter( self.NukeBlackHoleFxScale or 1 )
            self.Trash:Add( emit )
            bag:Add( emit )
        end

        self:PlayBlackholeSound('Blackhole_FirstExplosion')

        -- knock down trees, etc
        DamageRing(self, self:GetPosition(), 0.1, (30 * self.NukeBlackHoleFxScale), 1, 'ForceInwards', true)
        WaitSeconds(0.1)
        DamageRing(self, self:GetPosition(), 0.1, (30 * self.NukeBlackHoleFxScale), 1, 'ForceInwards', true)

        -- start up core black hole Fx
        for k, v in self.BlackholeCoreFx do
            emit = CreateEmitterOnEntity(self, army, v ):ScaleEmitter( self.NukeBlackHoleFxScale or 1 )
            self.Trash:Add( emit )
            bag:Add( emit )
        end

        if lifetime > 3 then
            WaitSeconds( 3 - 0.1 )
            self:PlayBlackholeAmbientSound('Blackhole_Loop')
        end
    end,

    RadiationJetEffects = function(self, bag, lifetime)
        local lt = RandomFloat(0.9, 0.98) * lifetime * 10
        local steps = math.floor(lt / 2)

        local beams = {}
        local army, beam = self:GetArmy()
        for k, v in self.RadiationBeams do
            beam = CreateBeamEmitterOnEntity(self, -1, army, v)
            beam:SetBeamParam( 'LENGTH', self.RadiationBeamLengths[k] )
            beam:SetBeamParam( 'THICKNESS', self.RadiationBeamThickness[k] )
            beam:SetBeamParam( 'LIFETIME', lt)
            beams[k] = beam
            self.Trash:Add( beam )
            bag:Add( beam )
        end

        -- orient blackhole entity so the beam goes up
        self:SetOrientation(OrientFromDir(Vector(RandomFloat(-0.1, 0.1),-1,RandomFloat(-0.1, 0.1))), true)

        -- wait some time, then shrink the beams
        WaitSeconds(lifetime/2)
        local frac
        for i=1, steps do
            frac = 1-(i/steps)
            for k, beam in beams do
                beam:SetBeamParam( 'LENGTH', self.RadiationBeamLengths[k] * frac )
                beam:SetBeamParam( 'THICKNESS', self.RadiationBeamThickness[k] * frac )
            end
            WaitSeconds(0.1)
        end
    end,

    DisposableCoreEffects = function(self, bag, lifetime)
        local army, emit = self:GetArmy()
        for k, v in self.GenericFx do
            emit = CreateEmitterOnEntity(self, army, v ):ScaleEmitter( self.NukeBlackHoleFxScale or 1 )
            self.Trash:Add( emit )
            bag:Add( emit )
        end
    end,

    CloudsThread = function(self, bag, lifetime)
        -- creates the grey clouds moving in the hole

        local projBp = '/effects/entities/NBlackholeEffect01/NBlackholeEffect01_proj.bp'

        local clouds = 2
        local angle = (2*math.pi) / clouds
        local velocity = 20
        local OffsetMod = 40
        local projectiles = {}
        local initialAngle, randomAngle, offset, height = 0, 0, 0, 0
        local pos = self:GetPosition()
        local surface = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])

        while self do
            initialAngle = RandomFloat( 0, angle )
            for i = 0, (clouds-1) do
                randomAngle = 0.25 * RandomFloat( -angle, angle )
                offset = OffsetMod + (RandomFloat( -OffsetMod, OffsetMod) * 0.1)
                height = math.max( RandomFloat( -OffsetMod, OffsetMod ), ((surface - pos[2]) + 1) )
                local X = math.sin( (i * angle) + initialAngle + randomAngle )
                local Z = math.cos( (i * angle) + initialAngle + randomAngle )
                local proj =  self:CreateProjectile( projBp, X * offset, height, Z * offset, -X, -height, -Z)
                proj:SetTrigger( self, 3 )
                proj:SetVelocity( -X * velocity, 0, -Z * velocity )
                proj:SetVelocity(velocity)
                proj:SetAcceleration( 40 )
                self.Trash:Add( proj )
                bag:Add( proj )
            end
            WaitSeconds( 0.1 )
        end
    end, 

    CloudsThread2 = function(self, bag, lifetime)
        -- creates the white clouds moving in the hole

        local projBp = '/effects/entities/NBlackholeEffect02/NBlackholeEffect02_proj.bp'

        local clouds = 1
        local angle = (2*math.pi) / clouds
        local velocity = 30
        local OffsetMod = 25
        local projectiles = {}
        local initialAngle, randomAngle, offset, height = 0, 0, 0, 0
        local pos = self:GetPosition()
        local surface = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])

        while self do
            initialAngle = RandomFloat( 0, angle )
            for i = 0, (clouds-1) do
                randomAngle = 0.25 * RandomFloat( -angle, angle )
                offset = OffsetMod + (RandomFloat( -OffsetMod, OffsetMod) * 0.1)
                height = math.max( RandomFloat( -OffsetMod, OffsetMod ), ((surface - pos[2]) + 1) )
                local X = math.sin( (i * angle) + initialAngle + randomAngle )
                local Z = math.cos( (i * angle) + initialAngle + randomAngle )
                local proj =  self:CreateProjectile( projBp, X * offset, height, Z * offset, -X, -height, -Z)
                proj:SetTrigger( self, 3 )
                proj:SetVelocity( -X * velocity, 0, -Z * velocity )
                proj:SetVelocity(velocity)
                proj:SetAcceleration( 40 )
                self.Trash:Add( proj )
                bag:Add( proj )
            end
            WaitSeconds( 0.1 )
        end
    end, 

    LightningThread = function(self, bag, lifetime)
        -- Creates a random lightning

        local beamBps = { NomadEffectTemplate.NukeBlackholeEnergyBeam1, NomadEffectTemplate.NukeBlackholeEnergyBeam2, NomadEffectTemplate.NukeBlackholeEnergyBeam3, }
        local fxBp = NomadEffectTemplate.NukeBlackholeEnergyBeamEnd

        local num = Random( 4, 8 )
        local chance = 65
        local dur = 2
        local entities = {}
        local pos = self:GetPosition()
        local maxOffset = 15 * (self.NukeBlackHoleFxScale or 1)
        local X, Y, Z, angle = 0,0,0,0,0
        local army = self:GetArmy()

        -- setting up the entities used to attach the end point of the beam on
        for i=1, num do
            local entity = Entity()
            self.Trash:Add( entity )
            bag:Add( entity )
            table.insert( entities, entity )
            Warp( entity, pos )
            entity.counter = 0
            entity.beam = false
            entity.fx = false
        end

        -- keep doing lightning strikes everywhere until thread destroyed
        while self do
            for k, entity in entities do

                if entity.counter <= 0 then  -- if counter is 0 destroy beam and maybe create a new one

                    if entity.beam then
                        entity.fx:Destroy()
                        entity.fx = false
                        entity.beam:Destroy()
                        entity.beam = false
                    end

                    if Random( 1, 100) <= chance then

                        angle = math.pi * 2 * RandomFloat( 0, 1 )
                        X = math.sin( angle ) * (maxOffset * RandomFloat(0.4, 1) )
                        Z = math.cos( angle ) * (maxOffset * RandomFloat(0.4, 1) )

                        angle = math.pi * 2 * RandomFloat( 0, 1 )
                        Y = math.sin( angle ) * (maxOffset * RandomFloat(0.4, 1) )

                        pos = self:GetPosition()
                        pos[1] = pos[1] + X
                        pos[3] = pos[3] + Z
                        pos[2] = math.max( (pos[2] + Y), (GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3]) + 0.1 ) )

                        Warp( entity, pos )
                        entity.beam = CreateBeamEntityToEntity( self, -1, entity, -1, army, beamBps[ Random(1, table.getn(beamBps)) ] )
                        self.Trash:Add( entity.beam )
                        bag:Add( entity.beam )
                        entity.fx = CreateEmitterOnEntity( entity, army, fxBp )
                        self.Trash:Add( entity.fx )
                        bag:Add( entity.fx )
                        CreateLightParticleIntel( entity, -1, army, 3, 5, 'glow_03', 'ramp_white_02')
                        entity.counter = dur - 1
                    end

                else
                    entity.counter = entity.counter - 1
                end
            end
            WaitSeconds( 0.1 )
        end
    end,

    PropThread = function(self, bag, lifetime)
        -- creates effects at props that look like parts of it are sucked in the black hole.
        -- Using entities oriented towards the blackhole. If the emitter emits particles along the Z axis they'll go towards the black hole.
        -- no need to do waits, the emitters remain until destroyed or their lifetime runs out.

        local CreateEffect = function(self, bag, lifetime, pos)
            local vector = VDiff( pos, self:GetPosition() )
            local entity = Entity()
            Warp( entity, pos )
            entity:SetOrientation( OrientFromDir( Vector(-vector.x,-vector.y,-vector.z)), true)
            bag:Add( entity )
            self.Trash:Add( entity )
            for k, v in NomadEffectTemplate.BlackholePropEffects do
                local lt = RandomFloat( 0.2, 1 ) * lifetime * 10
                local emit = CreateEmitterAtBone( entity, -1, -1, v ):SetEmitterParam('LIFETIME', lt)
                bag:Add( emit )
                self.Trash:Add( emit )
            end
        end

        for k, prop in self.PropsBeingSuckedIn do

            local count = prop:GetBoneCount()
            if count > 1 or not prop.GetPosition then
                for i = 0, count do
                    if prop:IsValidBone(i) and Random(1, 10) <= 7 then
                        CreateEffect( self, bag, lifetime, prop:GetPosition(i) )
                    end
                end
            else
                CreateEffect( self, bag, lifetime, prop:GetCachePosition() )
            end
        end
    end,

    -- =======================================================================================================================

    DissipateEffects = function(self, bag, lifetime)
        -- deals with the dissipating

        -- notify units and props being sucked in that the black hole is gone
        for k, unit in self.UnitsBeingSuckedIn do
            if unit and not unit:BeenDestroyed() then
                unit:OnBlackHoleDissipated()
            end
        end
        for k, prop in self.PropsBeingSuckedIn do
            if prop and not prop:BeenDestroyed() then
                prop:OnBlackHoleDissipated()
            end
        end
        self.UnitsBeingSuckedIn = {}
        self.PropsBeingSuckedIn = {}

        local army = self:GetArmy()

        -- create core black hole again but scale it down over 'lifetime'
        local emitters = {}
        for k, v in self.BlackholeCoreFx do
            emit = CreateEmitterOnEntity(self, army, v ):ScaleEmitter( self.NukeBlackHoleFxScale or 1 )
            table.insert( emitters, emit )
            self.Trash:Add( emit )
            bag:Add( emit )
        end

        -- small glow, simulates the black hole getting not black anymore
        CreateLightParticleIntel(self, -1, army, 2 * (self.NukeBlackHoleFxScale or 1), (40 * lifetime), 'glow_03', 'ramp_white_02')

        self:StopBlackholeAmbientSound('Blackhole_Loop')
        self:PlayBlackholeSound('Blackhole_Fadeout')

        -- create core black hole again but scale it down over 'lifetime'
        local dissipEmts = {}
        for k, v in self.BlackholeDissipatingFx do
            emit = CreateEmitterOnEntity(self, army, v ):ScaleEmitter( self.NukeBlackHoleFxScale or 1 )
            table.insert( dissipEmts, emit )
            self.Trash:Add( emit )
            bag:Add( emit )
        end

        -- each 0.1 seconds scale the effect down
        local declScale = self.NukeBlackHoleFxScale or 1
        local declStep = declScale / (lifetime / 0.18)  -- by diving by more than 0.1 the effect will appear gone completely for a moment
        local lifetimeGrowFx = (lifetime / 0.1) - (lifetime / 0.15)
        local growScale = 0
        local growStep = (self.NukeBlackHoleFxScale or 1) / lifetimeGrowFx
        while self and lifetime >= 0 do
            declScale = math.max( 0, declScale - declStep)
            for k, v in emitters do
                v:ScaleEmitter( declScale )
            end
            if lifetime <= lifetimeGrowFx then
                growScale = growScale + growStep
                for k, v in dissipEmts do
                    v:ScaleEmitter( growScale )
                end
            end
            WaitSeconds( 0.1 )
            lifetime = lifetime - 0.1
        end
    end,

    -- =======================================================================================================================

    AftermathExplosion = function(self, bag, lifetime, wreck)
        -- creates a flash and shockwave

        local army = self:GetArmy()

        -- warp to surface position for the aftermath
        local pos = self:GetPosition()
        pos[2] = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3]) + 1
        Warp( self, pos )

        self:PlayBlackholeSound('Blackhole_SecondExplosion')

        self:ShakeCamera( 55, 10, 0, 3 )
        CreateLightParticleIntel (self, -1, army, (10 * self.NukeBlackHoleFxScale), 10, 'glow_03', 'ramp_white_01')

        local emitters = EffectUtilities.CreateEffects( self, army, self.DissipatedFx )
        for k, emit in emitters do
            emit:ScaleEmitter( self.NukeBlackHoleFxScale or 1 )
            self.Trash:Add( emit )
            bag:Add( emit )
        end
    end,

    AftermathFireBalls = function(self, bag, lifetime, wreck)
-- TODO: add more particles, this can be much more dramatic
        -- creates fireballs in the air flying outwards in a nice arc

        local fireballs = Random( 6, 10)
        if fireballs < 1 then
            return
        end

        local projBp = '/effects/entities/NBlackholeEffect03/NBlackholeEffect03_proj.bp'

        local angle = (2*math.pi) / fireballs
        local velocity = 8
        local OffsetMod = 10
        local projectiles = {}
        local initialAngle, randomAngle, offset, height = 0, 0, 0, 0

        local DamageData = {
            Damage = self.NukeBlackHoleFireballDamage or 0,
            Radius = self.NukeBlackHoleFireballRadius or 0,
            DamageType = self.NukeBlackHoleFireballDamageType or 'Normal',
        }

        initialAngle = RandomFloat( 0, angle )
        for i = 0, (fireballs-1) do
            randomAngle = 1.2 * RandomFloat( -angle, angle )
            offset = OffsetMod + (RandomFloat( -OffsetMod, OffsetMod) * 0.1)
            local X = math.sin( (i * angle) + initialAngle + randomAngle )
            local Z = math.cos( (i * angle) + initialAngle + randomAngle )
            local Y = RandomFloat( 1, 3)
            local proj =  self:CreateProjectile( projBp, 0, 0, 0, X, Y, Z)
            proj:SetVelocity( X * velocity, Y * velocity, Z * velocity )
            proj:SetVelocity( velocity * RandomFloat(0.75, 1.25) )
            proj:SetBallisticAcceleration( -2 )
            self.Trash:Add( proj )
            bag:Add( proj )

            if DamageData.Damage > 0 then
                proj:PassDamageData( DamageData )
            end
        end
    end,

    AftermathFireArmsRandom = function(self, bag, lifetime, wreck)
        -- creates several fires in a line outward from the black hole area

        wreck:SetCanTakeDamage(false)

        -- fire effect blueprints. The first is the close to the center so this should be a large effect. The last one is far away and should be smallish
        local FireArmTempl = { NomadEffectTemplate.NukeBlackholeFireArmSegment1, NomadEffectTemplate.NukeBlackholeFireArmSegment2, 
                               NomadEffectTemplate.NukeBlackholeFireArmSegment3, NomadEffectTemplate.NukeBlackholeFireArmSegment4, 
                               NomadEffectTemplate.NukeBlackholeFireArmSegment5, }
        local FireCntrTempl =  NomadEffectTemplate.NukeBlackholeFireArmCenter1

        -- Length is the length of the fire 'arms'. The effect emitters don't grow so if changed don't forget to update the emitters aswell
        local maxLength = 16
        local arms = Random( 5, 8)

        local angle = (2*math.pi) / arms
        local initialAngle = RandomFloat( 0, angle )
        local randomAngle, offset, height, curAngle, X, Z, offset, pos, entity, emit = 0, 0, 0, 0, 0, 0, 0
        local army = self:GetArmy()

        -- creating center fire
        for k, v in FireCntrTempl do
            emit = CreateEmitterAtEntity( self, army, v )
            self.Trash:Add( emit )
            bag:Add( emit )
            DamageArea(self, self:GetPosition(), (12 * self.NukeBlackHoleFxScale), 1, 'BigFire', true)
        end

        -- creating fire arms
        for i = 0, (arms-1) do

            randomAngle = 0.3 * RandomFloat( -angle, angle )
            curAngle = (i * angle) + initialAngle + randomAngle
            X = math.sin( curAngle )
            Z = math.cos( curAngle )

            for seg = 0, 4 do

                offset = 2 + (((maxLength - 2) / 4 * seg) * RandomFloat( 0.8, 1.2 ))
                pos = self:GetPosition()
                pos[1] = pos[1] + (X * offset)
                pos[3] = pos[3] + (Z * offset)
                pos[2] = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
                entity = Entity()
                self.Trash:Add( entity )
                bag:Add( entity )
                Warp( entity, pos )
                entity:SetOrientation( OrientFromDir( Util.Cross( Vector(X,0,Z), Vector(0,1,0))), true )

                for k, v in FireArmTempl[ seg+1 ] do
                    emit = CreateEmitterAtBone( entity, -1, army, v ):SetEmitterParam('LIFETIME', (lifetime * (10 - seg) * RandomFloat(0.7, 1)) ):ScaleEmitter( RandomFloat( 0.75, 1.25))
                    self.Trash:Add( emit )
                    bag:Add( emit )
                end

                DamageArea(self, pos, (3 * self.NukeBlackHoleFxScale), 1, 'BigFire', true)

                entity:Destroy()
            end
        end

        wreck:SetCanTakeDamage(true)
    end,

    AftermathFireArmsLogo = function(self, bag, lifetime, wreck)
        -- creates the nomad logo in fire

        wreck:SetCanTakeDamage(false)

        local FireArmTempl = { NomadEffectTemplate.NukeBlackholeFireArmSegment4, NomadEffectTemplate.NukeBlackholeFireArmSegment4,
                               NomadEffectTemplate.NukeBlackholeFireArmSegment4, NomadEffectTemplate.NukeBlackholeFireArmSegment4,
                               NomadEffectTemplate.NukeBlackholeFireArmCenter2, }
        local maxLength = 13
        local arms = 6

        local angle = (2*math.pi) / arms
        local initialAngle = 0
        local offset, height, curAngle, X, Z, offset, pos, entity, emit = 0, 0, 0, 0, 0, 0
        local army = self:GetArmy()

        for i = 0, (arms-1) do

            curAngle = (i * angle) + initialAngle
            X = math.sin( curAngle )
            Z = math.cos( curAngle )

            for seg = 0, 4 do
                if math.mod( i, 2 ) == 1 or seg == 4 then
                    offset = 2 + ((maxLength - 2) / 4 * seg)
                    pos = self:GetPosition()
                    pos[1] = pos[1] + (X * offset)
                    pos[3] = pos[3] + (Z * offset)
                    pos[2] = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
                    entity = Entity()
                    self.Trash:Add( entity )
                    bag:Add( entity )
                    Warp( entity, pos )
                    entity:SetOrientation( OrientFromDir( Util.Cross( Vector(X,0,Z), Vector(0,1,0))), true )

                    for k, v in FireArmTempl[ seg+1 ] do
                        emit = CreateEmitterAtBone( entity, -1, army, v ):SetEmitterParam('LIFETIME', (lifetime * (10 - seg) * RandomFloat(0.7, 1)) ):ScaleEmitter( RandomFloat( 0.75, 1.25))
                        self.Trash:Add( emit )
                        bag:Add( emit )
                    end

                    DamageArea(self, pos, (3 * self.NukeBlackHoleFxScale), 1, 'BigFire', true)

                    entity:Destroy()
                end
            end
        end

        wreck:SetCanTakeDamage(false)
    end,
}

TypeClass = NBlackhole
