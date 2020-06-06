local DefaultUnitsFile = import('defaultunits.lua')
local AirFactoryUnit = DefaultUnitsFile.AirFactoryUnit
local AirStagingPlatformUnit = DefaultUnitsFile.AirStagingPlatformUnit
local AirUnit = DefaultUnitsFile.AirUnit
local AirTransport = DefaultUnitsFile.AirTransport
local ConstructionUnit = DefaultUnitsFile.ConstructionUnit
local EnergyCreationUnit = DefaultUnitsFile.EnergyCreationUnit
local EnergyStorageUnit = DefaultUnitsFile.EnergyStorageUnit
local LandFactoryUnit = DefaultUnitsFile.LandFactoryUnit
local LandUnit = DefaultUnitsFile.LandUnit
local MassCollectionUnit = DefaultUnitsFile.MassCollectionUnit
local MassFabricationUnit = DefaultUnitsFile.MassFabricationUnit
local MassStorageUnit = DefaultUnitsFile.MassStorageUnit
local RadarUnit = DefaultUnitsFile.RadarUnit
local SeaFactoryUnit = DefaultUnitsFile.SeaFactoryUnit
local SeaUnit = DefaultUnitsFile.SeaUnit
local ShieldStructureUnit = DefaultUnitsFile.ShieldStructureUnit
local SonarUnit = DefaultUnitsFile.SonarUnit
local StructureUnit = DefaultUnitsFile.StructureUnit
local SubUnit = DefaultUnitsFile.SubUnit
local WalkingLandUnit = DefaultUnitsFile.WalkingLandUnit
local WallStructureUnit = DefaultUnitsFile.WallStructureUnit
local RadarJammerUnit = DefaultUnitsFile.RadarJammerUnit
local HoverLandUnit = DefaultUnitsFile.HoverLandUnit

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local NomadsEffectUtil = import('/lua/nomadseffectutilities.lua')
local CreateBuildCubeThread = NomadsEffectUtil.CreateBuildCubeThread
local CreateNomadsBuildSliceBeams = NomadsEffectUtil.CreateNomadsBuildSliceBeams

-- added later
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local Unit = import('/lua/sim/Unit.lua').Unit


function AddNomadsBeingBuiltEffects( SuperClass )
    return Class(SuperClass) {
        StartBeingBuiltEffects = function(self, builder, layer)
            -- starts the build effect thread, which creates the build cube and the flashing. The flashing is avoided if the unit is upgrading.
            local bp = self:GetBlueprint()
            local IsUpgrade = (bp.General.UpgradesFrom == builder.UnitId)
            self.OnBeingBuiltEffectsBag:Add( self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag))
            if not IsUpgrade then
                self:SetMesh(bp.Display.BuildMeshBlueprint, true)
            else
                self:HideBone(0, true)
            end
        end,
    }
end

function NomadsSharedFactory( SuperClass )
    return Class(SuperClass) {
        -- Nomads factory build unit effects. Assumes unit collision boxes are pretty accurately sized but can be tweaked using unit blueprint values
        -- Display.BuildEffect.ExtendsFront and ExtendsRear.
        -- The factory may need tweaking too; Display.BuildFieldOffset to offset the build field ranges, and Display.BuildFieldReversed to
        -- reverse the direction that the arms are moving. Needed on some factories.
        SliderBone = 'slider',

        OnCreate = function(self)
            SuperClass.OnCreate(self)

            -- TODO: Remove once related change gets released in the game patch
            self.BuildEffectBones = self:GetBlueprint().General.BuildBones.BuildEffectBones

            self.ArmSlider1 = CreateSlider(self, self.SliderBone, 0,0,0,0, true)
            self.ArmSlider1:SetWorldUnits(true)
            self.Trash:Add(self.ArmSlider1)
        end,

        StopBuildingEffects = function(self, unitBeingBuilt)
            self:StopArmsMoving()
            SuperClass.StopBuildingEffects(self, unitBeingBuilt)
        end,

        CreateDestructionEffects = function( self, overKillRatio )
            -- when we're dead there's a chance to begin moving the arms as an added effect
            if self.ArmSlider1 and Random( 1, 2 ) == 1 then
                local dir = 1
                if self:GetBlueprint().Display.BuildEffect.Factory.BuildFieldReversed then dir = -1 end
                self.ArmSlider1:SetGoal( 0,0, RandomFloat(0, 1.5) * dir ):SetSpeed( Random(1,5) )
            end
            SuperClass.CreateDestructionEffects( self, overKillRatio )
        end,

        CreateBuildEffects = function( self, unitBeingBuilt, order )
            if self.BuildEffectBones then
                local bp = self:GetBlueprint()
                local emitrate = math.ceil((bp.Economy.BuildRate or 1) / 2)

                -- creates the orange build fields
                self.BuildEffectsBag:Add( self:ForkThread(NomadsEffectUtil.CreateFactoryBuildBeams, unitBeingBuilt, self.BuildEffectBones, self.BuildEffectsBag) )

                -- add effects to the build field
                for k, bone in self.BuildEffectBones do
                    local offset, unitHeight = self:GetEffectOffsetRange(bone)
                    for _, v in NomadsEffectTemplate.FactoryConstructionField do
                        local emit = CreateAttachedEmitter( self, bone, self.Army, v)
                        emit:OffsetEmitter(0,offset,0)
                        emit:SetEmitterCurveParam('Y_POSITION_CURVE', unitHeight/2, unitHeight)
                        emit:SetEmitterCurveParam('EMITRATE_CURVE', emitrate, 0)
                        self.BuildEffectsBag:Add( emit )
                        self.Trash:Add( emit )
                    end
                end

                self:StartArmsMoving(self)
            end
        end,

        StartArmsMoving = function(self, unitBeingBuilt)
            -- this is the yellow plane moving back and forth while building a unit, only start moving arms if they aren't already
            if not self.ArmsThread then
                self.ArmsThread = self:ForkThread( self.MovingArmsThread )
            end
        end,

        StopArmsMoving = function(self)
            -- stops the arm movement
            if self.ArmsThread then
                KillThread( self.ArmsThread )
                self.ArmsThread = nil
            end
            if self.ArmSlider1 then
                self.ArmSlider1:SetGoal( 0,0,0 ):SetSpeed( 10 )
            end
        end,

        MovingArmsThread = function(self)
            -- moves the arm  back and forth as long as a unit is being constructed
            if not self.UnitBeingBuilt or self.UnitBeingBuilt:BeenDestroyed() then
                --WARN('NLandFactoryUnit -> MovingArmsThread: no unit being built '..repr(self.UnitId))
                return
            elseif not self.ArmSlider1 then
                --wARN('NLandFactoryUnit -> MovingArmsThread: No arm slider '..repr(self.UnitId))
                return
            end

            local r = 0.9 -- while the construction progress is below this move to 'max'. When over this, go back to 'min'
            local mul, dir = 0, 1
            local InitialDist, Length = self:GetInitialAndLength()
            if self:GetBlueprint().Display.BuildEffect.Factory.BuildFieldReversed then dir = -1 end  -- some factories have backwards bones, here's a correction
            self.ArmSlider1:SetSpeed( 1000 ):SetWorldUnits(true)

            while not self:BeenDestroyed() and not self.UnitBeingBuilt:BeenDestroyed() and self.UnitBeingBuilt:GetFractionComplete() < 1 and not self.Dead do

                if self.UnitBeingBuilt:GetFractionComplete() <= r then
                    mul = self.UnitBeingBuilt:GetFractionComplete() / r
                else
                    mul = 1 - ((self.UnitBeingBuilt:GetFractionComplete() - r) * (1 / (1 - r)))
                end

                local z = (InitialDist + (Length * mul)) * dir
                self.ArmSlider1:SetGoal( 0,0,z )
                WaitTicks(1)
            end

            self:StopArmsMoving()
        end,

        GetEffectOffsetRange = function(self, effectBone)
            local bp = self:GetBlueprint()
            local BuildAttachBone = bp.Display.BuildAttachBone or 0
            local UnitSize, MeshExtends1, MeshExtends2, UnitOffset, Diff
            local ubbBp = self.UnitBeingBuilt:GetBlueprint()

            -- some factories like the naval ones have the build field emitted from above, not from the left or right
            if bp.Display.BuildEffect.Factory.VerticalEffect then
                UnitSize = (ubbBp.SizeX or 1)
                MeshExtends1 = ubbBp.Display.BuildEffect.ExtendsLeft or 0
                MeshExtends2 = ubbBp.Display.BuildEffect.ExtendsRight or 0
                UnitOffset = ubbBp.CollisionOffsetX or 0
                Diff = self:GetPosition(BuildAttachBone)[1] - self:GetPosition(effectBone)[1]
            else
                UnitSize = (ubbBp.SizeY or 1)
                MeshExtends1 = ubbBp.Display.BuildEffect.ExtendsBottom or 0
                MeshExtends2 = ubbBp.Display.BuildEffect.ExtendsTop or 0
                UnitOffset = ubbBp.CollisionOffsetY or 0
                Diff = self:GetPosition(BuildAttachBone)[2] - self:GetPosition(effectBone)[2]
            end

            return (Diff + UnitOffset - MeshExtends1), (MeshExtends1 + UnitSize + MeshExtends2)
        end,

        GetInitialAndLength = function(self)
            -- this is not 'just' a version of GetEffectUnitSizes(), there's a correction for factory differences aswell
            local bp = self:GetBlueprint()
            local BuildAttachBone = bp.Display.BuildAttachBone or 0
            local ubbBp = self.UnitBeingBuilt:GetBlueprint()
            local UnitSizeZ = (ubbBp.SizeZ or 1)
            local MeshExtendsFront = ubbBp.Display.BuildEffect.ExtendsFront or 0
            local MeshExtendsRear = ubbBp.Display.BuildEffect.ExtendsRear or 0
            local UnitOffsetZ = ubbBp.CollisionOffsetZ or 0
            local diffZ = self:GetPosition(self.SliderBone)[3] - self:GetPosition(BuildAttachBone)[3]
            local correction = bp.Display.BuildEffect.Factory.BuildFieldOffset or 0
            return (diffZ - (UnitSizeZ/2) - MeshExtendsFront - UnitOffsetZ - correction), (MeshExtendsFront + UnitSizeZ + MeshExtendsRear)
        end,
    }
end

---------------------------------------------------------------
--  AIR UNITS
---------------------------------------------------------------
NAirUnit = Class(AirUnit) {
    BeamExhaustCruise = NomadsEffectTemplate.AirThrusterCruisingBeam,
    BeamExhaustIdle = NomadsEffectTemplate.AirThrusterIdlingBeam,
}

NAirTransportUnit = Class(AirTransport) {
    BeamExhaustCruise = NomadsEffectTemplate.AirThrusterCruisingBeam,
    BeamExhaustIdle = NomadsEffectTemplate.AirThrusterIdlingBeam,

}

NExperimentalAirTransportUnit = Class(NAirTransportUnit) {
    -- placehold

  
}

---------------------------------------------------------------
--  LAND UNITS
---------------------------------------------------------------
NLandUnit = Class(LandUnit) {

}

---------------------------------------------------------------
--  AMPHIBIOUS UNITS
---------------------------------------------------------------
NAmphibiousUnit = Class(NLandUnit) {
    -- on water speed multiplier moved to unit.lua per build 41
}

---------------------------------------------------------------
--  HOVER LAND UNITS
---------------------------------------------------------------
NHoverLandUnit = Class(HoverLandUnit) {
    -- The code below for speed reduction and weapon disabling in water should be the same as the amphibious unit class, above
    OnStartBeingBuilt = function(self, builder, layer)
        HoverLandUnit.OnStartBeingBuilt(self, builder, layer)

        -- if not built yet then dont play sounds
        -- TODO: Perhaps this should be generic behavior and placed in the unit.lua file?
        self:StopUnitAmbientSound( 'AmbientMove' )
        self:StopUnitAmbientSound( 'AmbientMoveWater' )
        self:StopUnitAmbientSound( 'AmbientMoveSub' )
        self:StopUnitAmbientSound( 'AmbientMoveLand' )
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        HoverLandUnit.OnKilled(self, instigator, type, overkillRatio)
        self:DestroyMovementEffects()  -- remove green hover effect
    end,

    OnMotionHorzEventChange = function( self, new, old )
        HoverLandUnit.OnMotionHorzEventChange( self, new, old )

        if not self.Dead then
            local layer = self:GetCurrentLayer()
            if new == 'Stopped' or new == 'Stopping' then   -- when stopping play the idle sound, on water play a different one
                local bp = self:GetBlueprint().Audio
                if layer == 'Water' and bp and bp.AmbientMoveWater then
                    self:PlayUnitAmbientSound( 'AmbientMoveWater' )
                else
                    self:PlayUnitAmbientSound( 'AmbientIdle' )
                end
            else
                self:StopUnitAmbientSound( 'AmbientIdle' )
            end
        end
    end,
}

NExperimentalHoverLandUnit = Class(NHoverLandUnit) {
    OnStopBeingBuilt = function(self, builder, layer)
        NHoverLandUnit.OnStopBeingBuilt(self, builder, layer)
        self.DoCrushing = false
    end,

    OnMotionHorzEventChange = function( self, new, old )
        self.DoCrushing = (new ~= 'Stopped')
        if self.DoCrushing then
            if not self.MoveCrushThread then
                self.MoveCrushThread = self:ForkThread( self.CrushingThread )
            end
        elseif self.MoveCrushThread then
            KillThread( self.MoveCrushThread )
            self.MoveCrushThread = nil
        end
        return NHoverLandUnit.OnMotionHorzEventChange(self, new, old)
    end,

    OnTransportAttach = function(self, attachBone, unit)
        NHoverLandUnit.OnTransportAttach(self, attachBone, unit)
        self.DoCrushing = false
    end,

    OnTransportDetach = function(self, attachBone, unit)
        NHoverLandUnit.OnTransportDetach(self, attachBone, unit)
        self.DoCrushing = false
    end,

    CrushingThread = function(self)
        -- damages the area every X interval
        local bp = self:GetBlueprint().Display.MovementEffects.Crush
        if bp and bp.Damage then
            while not self.Dead and self.DoCrushing do
                for k, BoneInfo in bp.Bones do
                    local pos = self:GetPosition( BoneInfo.BoneName )
                    local ox = BoneInfo.Offset[1] or 0
                    local oy = BoneInfo.Offset[2] or 0
                    local oz = BoneInfo.Offset[3] or 0
                    local heading = self:GetHeading()
                    pos[1] = pos[1] + ((math.cos(heading) * ox) - (math.sin(heading) * oz))
                    pos[2] = pos[2] + oy
                    pos[3] = pos[3] + ((math.sin(heading) * ox) - (math.cos(heading) * oz))

                    self:DoCrushDamage( pos, bp.Damage)
                end
                WaitSeconds( bp.Damage.Interval or 1)
            end
        end
    end,

    DoCrushDamage = function(self, pos, bpDamage)
        -- To determine the offset in the units blueprint you can use this line:
        -- CreateUnitHPR('xnl0101', self.Army, pos[1], pos[2], pos[3], 0,0,0)
        DamageArea(self, pos, bpDamage.Radius, bpDamage.Amount, bpDamage.Type, bpDamage.DamageFriendly )
    end,
}
---------------------------------------------------------------
--  SEA UNITS
---------------------------------------------------------------
NSeaUnit = Class(SeaUnit) {
    PlayAnimationThread = function(self, anim, rate)
        -- someone made ship sink animations that run to fast. The original nomads team decided to add this line that
        -- can be used to alter the animation speed through the blueprint.
        --        rate = rate or animBlock.Rate or 1
        -- the rest of the stuff comes from the unit.lua file.
        local bp = self:GetBlueprint().Display[anim]
        if bp then
            local animBlock = self:ChooseAnimBlock( bp )
            if animBlock.Mesh then
                self:SetMesh(animBlock.Mesh)
            end

            if animBlock.Animation then
                local sinkAnim = CreateAnimator(self)
                self:StopRocking()
                self.DeathAnimManip = sinkAnim
                sinkAnim:PlayAnim(animBlock.Animation)

                rate = rate or animBlock.Rate or 1

                if animBlock.AnimationRateMax and animBlock.AnimationRateMin then
                    rate = Random(animBlock.AnimationRateMin * 10, animBlock.AnimationRateMax * 10) / 10
                end

                sinkAnim:SetRate(rate)
                self.Trash:Add(sinkAnim)
                WaitFor(sinkAnim)
            end
        end
    end,
}

---------------------------------------------------------------
--  WALKING LAND UNITS
---------------------------------------------------------------
NWalkingLandUnit = Class(WalkingLandUnit) {
    WalkingAnimRate = 1,
    IdleAnimRate = 1,
    DisabledBones = {},
}

---------------------------------------------------------------
--  SUBMARINE UNITS
---------------------------------------------------------------
NSubUnit = Class(SubUnit) {}

---------------------------------------------------------------
--  Construction Units
---------------------------------------------------------------
NConstructionUnit = Class(ConstructionUnit) {
    -- TODO: Remove once related change gets released in the game patch
    OnCreate = function(self)
        ConstructionUnit.OnCreate(self)
        self.BuildEffectBones = self:GetBlueprint().General.BuildBones.BuildEffectBones
    end,

    CreateBuildEffects = function(self, unitBeingBuilt, order)
        CreateNomadsBuildSliceBeams(self, unitBeingBuilt, self.BuildEffectBones, self.BuildEffectsBag)
    end,

    OnStopBuild = function(self, unitBuilding)
        ConstructionUnit.OnStopBuild(self, unitBuilding)
        if self.BuildRotator then
            self.BuildRotator:SetGoal(0)
        end
        if self.BuildArmManipulator then
            self.BuildArmManipulator:SetAimingArc(-180, 180, 360, -180, 180, 360)
        end
    end,

    CreateReclaimEffects = function(self, target)
        NomadsEffectUtil.PlayNomadsReclaimEffects(self, target, self.BuildEffectBones, self.ReclaimEffectsBag)
    end,

    CreateReclaimEndEffects = function(self, target)
        NomadsEffectUtil.PlayNomadsReclaimEndEffects(self, target, self.ReclaimEffectsBag)
    end,

    -- The code below for speed reduction and weapon disabling in water should be the same as the amphibious unit class, above
    OnKilled = function(self, instigator, type, overkillRatio)
        ConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
        self:DestroyMovementEffects()  -- remove green hover effect
        self:StopBuildingEffects()  -- remove building beams
    end,

    OnMotionHorzEventChange = function( self, new, old )
        ConstructionUnit.OnMotionHorzEventChange( self, new, old )

        if not self.Dead then
            local layer = self:GetCurrentLayer()
            if new == 'Stopped' or new == 'Stopping' then   -- when stopping play the idle sound, on water play a different one
                local bp = self:GetBlueprint()
                if layer == 'Water' and bp.Audio and bp.Audio.AmbientMoveWater then
                    self:PlayUnitAmbientSound( 'AmbientMoveWater' )
                else
                    self:PlayUnitAmbientSound( 'AmbientIdle' )
                end
            else
                self:StopUnitAmbientSound( 'AmbientIdle' )
            end
        end
    end,
}

---------------------------------------------------------------
-- FACTORY UNITS
---------------------------------------------------------------
LandFactoryUnit = AddNomadsBeingBuiltEffects(NomadsSharedFactory(LandFactoryUnit))
NLandFactoryUnit = Class(LandFactoryUnit) {

}

AirFactoryUnit = AddNomadsBeingBuiltEffects(NomadsSharedFactory(AirFactoryUnit))
NAirFactoryUnit = Class(AirFactoryUnit) {

}

SeaFactoryUnit = AddNomadsBeingBuiltEffects(NomadsSharedFactory(SeaFactoryUnit))
NSeaFactoryUnit = Class(SeaFactoryUnit) {

}

NSCUFactoryUnit = Class(LandFactoryUnit) {

}

---------------------------------------------------------------
--  UNITS IN PLANET ORBIT
---------------------------------------------------------------
NOrbitUnit = Class(Unit) {
    BeamExhaustCruise = NomadsEffectTemplate.AirThrusterCruisingBeam,
    BeamExhaustIdle = NomadsEffectTemplate.AirThrusterIdlingBeam,

    OnCreate = function(self)
        Unit.OnCreate(self)
        self:WarpIntoOrbit()

        -- give us a name
        local name = self:GetBlueprint().General.UnitName
        if name then
            self:SetCustomName(name)
        end
    end,

    WarpIntoOrbit = function(self)
        -- warp into orbit
        local pos = self:GetPosition()
        local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
        local bp = self:GetBlueprint()
        local orbit = bp.Physics.Elevation or 75
        pos[2] = surface + orbit
        Warp( self, pos, self:GetOrientation() )

        -- in orbit we have a slight rotation
        if bp.Physics.RotateOnSpot ~= false then
            self.RotatorManip = CreateRotator( self, 0, 'y', nil, 2 )
        end
    end,
}

--orbital command frigate, adds effects only. use with parents.
NCommandFrigateUnit = Class() {
    -- Rotators
    SetupRotators = function(self)
        local bp = self:GetBlueprint().Rotators
        if not self.RotatorOuter then
            self.RotatorOuter = CreateRotator( self, 'Deflector Edge', 'z' )
            self.Trash:Add( self.RotatorOuter )
        end
        if not self.RotatorInner then
            self.RotatorInner = CreateRotator( self, 'Deflector Centre', 'z' )
            self.Trash:Add( self.RotatorInner )
        end
        
        self.RotatorOuter:SetAccel( bp.OuterAcceleration )
        self.RotatorOuter:SetTargetSpeed( bp.OuterSpeed )
        self.RotatorOuter:SetSpeed( bp.OuterSpeed )
        
        self.RotatorInner:SetAccel( bp.InnerAcceleration )
        self.RotatorInner:SetTargetSpeed( bp.InnerSpeed )
        self.RotatorInner:SetSpeed( bp.InnerSpeed )
    end,

    StopRotators = function(self)
        if self.RotatorOuter then
            self.RotatorOuter:SetTargetSpeed( 0 )
        end
        if self.RotatorInner then
            self.RotatorInner:SetTargetSpeed( 0 )
        end      
    end,
    
    StartRotators = function(self)
        local bp = self:GetBlueprint().Rotators
        if self.RotatorOuter then
            self.RotatorOuter:SetTargetSpeed( bp.OuterSpeed )
        end
        if self.RotatorInner then
            self.RotatorInner:SetTargetSpeed( bp.InnerSpeed )
        end
    end,
    
    -- engines
    EngineExhaustBones = {'Engine Exhaust01', 'Engine Exhaust02', 'Engine Exhaust03', 'Engine Exhaust04', 'Engine Exhaust05', },
    ThrusterExhaustBones = { 'ThrusterPort01', 'ThrusterPort02', 'ThrusterPort03', 'ThrusterPort04', 'ThrusterPort05', 'ThrusterPort06', },
    EngineFireEffects = { --for when the engine is on full power
        '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',--smoke
        '/effects/emitters/nomads_orbital_frigate_thruster05_emit.bp',--smoke
        '/effects/emitters/nomads_orbital_frigate_thruster01_emit.bp',--fire
        '/effects/emitters/nomads_orbital_frigate_thruster02_emit.bp',--fire
    },
    EnginePartialEffects = { --hot air effects only
        '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',
    },
    ThrusterEffects = { --hot air effects only
        '/effects/emitters/aeon_t1eng_groundfx01_emit.bp',
    },

    StopEngines = function(self)
        self.EngineEffectsBag:Destroy()
        self:AddEffects(self.EnginePartialEffects, self.EngineExhaustBones, self.EngineEffectsBag)
        WaitSeconds(4.5)
        self.EngineEffectsBag:Destroy()
    end,
    
    Landing = function(self, EnableThrusters)
        self:HideBone(0, true)
        --start rotators
        self:SetupRotators()
        self:StopRotators() --start slowing them down
        
        self:AddEffects(self.EngineFireEffects, self.EngineExhaustBones, self.EngineEffectsBag)
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/xno0001/XNO0001_WarpEntry01.sca')
        self.LaunchAnim:SetRate(0.1)
        self.Trash:Add(self.LaunchAnim)
        
        self:ForkThread(self.LandingThread, EnableThrusters)
    end,
    
    LandingThread = function(self, EnableThrusters)
        WaitSeconds(0.1)
        self:ShowBone(0, true)
        WaitSeconds(4.5)
        self:StopEngines()
        if EnableThrusters then
            self:AddEffects(self.ThrusterEffects, self.ThrusterExhaustBones, self.ThrusterEffectsBag)
        end
        WaitFor(self.LaunchAnim)
        self.LaunchAnim:Destroy()
    end,

    TakeOff = function(self)
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/xno0001/XNO0001_TakeOff01.sca')
        self.LaunchAnim:SetAnimationFraction(0)
        self.LaunchAnim:SetRate(0.1)
        self.Trash:Add(self.LaunchAnim)
        self:StartRotators()
        
        self:ForkThread(self.TakeOffThread)
    end,
    
    TakeOffThread = function(self)
        WaitSeconds(0.2)
        self.ThrusterEffectsBag:Destroy()
        WaitSeconds(0.1)
        self:AddEffects(self.EngineFireEffects, self.EngineExhaustBones, self.EngineEffectsBag, 0.3)
    end,

    AddEffects = function(self, effects, bones, bag, delay)
        for _, effect in effects do
            for _, bone in bones do
                local emit = CreateAttachedEmitter(self, bone, self.Army, effect)
                bag:Add(emit)
                self.Trash:Add(emit)
                if delay then --you need to fork the thread for that!
                    WaitSeconds(delay)
                end
            end
        end
    end,
}

---------------------------------------------------------------
--  AIR STAGING STRUCTURES
---------------------------------------------------------------
AirStagingPlatformUnit = AddNomadsBeingBuiltEffects(AirStagingPlatformUnit)
NAirStagingPlatformUnit = Class(AirStagingPlatformUnit) {

}

---------------------------------------------------------------
-- ENERGY CREATION STRUCTURES
---------------------------------------------------------------
EnergyCreationUnit = AddNomadsBeingBuiltEffects(EnergyCreationUnit)
NEnergyCreationUnit = Class(EnergyCreationUnit) {
    ActiveEffectBone = false,
    ActiveEffectTemplateName = false,

    OnCreate = function(self)
        EnergyCreationUnit.OnCreate(self)
        self.ActiveEffectsBag = TrashBag()
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        EnergyCreationUnit.OnStopBeingBuilt(self, builder, layer)
        self:PlayActiveEffects()
    end,

    OnDestroy = function(self)
        self:DestroyActiveEffects()
        EnergyCreationUnit.OnDestroy(self)
    end,

    PlayActiveEffects = function(self)
        -- emitters
        if self.ActiveEffectTemplateName and self.ActiveEffectBone then
            for k, v in NomadsEffectTemplate[ self.ActiveEffectTemplateName ] do
                local emit = CreateAttachedEmitter(self, self.ActiveEffectBone, self.Army, v)
                self.ActiveEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
        end

        -- sound
        local bp = self:GetBlueprint()
        if bp and bp.Audio and bp.Audio.Activate then
            self:PlaySound( bp.Activate )
        end
    end,

    DestroyActiveEffects = function(self)
        self.ActiveEffectsBag:Destroy()
    end,
}

---------------------------------------------------------------
--  MASS COLLECTION UNITS
---------------------------------------------------------------
MassCollectionUnit = AddNomadsBeingBuiltEffects(MassCollectionUnit)
NMassCollectionUnit = Class(MassCollectionUnit) {

}

---------------------------------------------------------------
-- MASS FABRICATION STRUCTURES
---------------------------------------------------------------
MassFabricationUnit = AddNomadsBeingBuiltEffects(MassFabricationUnit)
NMassFabricationUnit = Class(MassFabricationUnit) {

}

---------------------------------------------------------------
-- ENERGY STORAGE STRUCTURES
---------------------------------------------------------------
EnergyStorageUnit = AddNomadsBeingBuiltEffects(EnergyStorageUnit)
NEnergyStorageUnit = Class(EnergyStorageUnit) {

}

---------------------------------------------------------------
-- MASS STORAGE STRUCTURES
---------------------------------------------------------------
MassStorageUnit = AddNomadsBeingBuiltEffects(MassStorageUnit)
NMassStorageUnit = Class(MassStorageUnit) {

}

---------------------------------------------------------------
--  COUNTER INTEL STRUCTURES
---------------------------------------------------------------
RadarJammerUnit = AddNomadsBeingBuiltEffects(RadarJammerUnit)
NRadarJammerUnit = Class(RadarJammerUnit) {

}

---------------------------------------------------------------
--  INTEL STRUCTURES
---------------------------------------------------------------
RadarUnit = AddNomadsBeingBuiltEffects(RadarUnit)
NRadarUnit = Class(RadarUnit) {

    IntelBoostFxBone = 0, -- bone used for overcharge and overcharge recovery effects. Also for charging effects if that bone isn't set (see next line)
    OverchargeExplosionFxBone = 0, -- bone for the explosion effect played when the unit is destroyed while boosting radar
    IntelType = 'Radar',--the type of intel to toggle

    IntelBoostFx = NomadsEffectTemplate.T1RadarOvercharge,
    OverchargeExplosionFx = NomadsEffectTemplate.T1RadarOverchargeExplosion,
    IntelBoostFxScale = 1,
    OverchargeExplosionFxScale = 1,

    OnCreate = function(self)
        RadarUnit.OnCreate(self)
        self.IntelBoostEffects = TrashBag()
        self.IntelBoostExplosionEffects = TrashBag()
        
        local bp = self:GetBlueprint()
        self.IntelRadiusBoosted = bp.Intel[self.IntelType..'RadiusBoosted']
        self.IntelRadiusDefault = bp.Intel[self.IntelType..'Radius']
        self.EnergyDrainDefault = bp.Economy.MaintenanceConsumptionPerSecondEnergy
        self.EnergyDrainBoosted = bp.Economy.MaintenanceConsumptionPerSecondEnergyBoosted or self.EnergyDrainDefault * 2
        
        self:SetScriptBit('RULEUTC_WeaponToggle', true) --this makes the toggle button look off by default
    end,

    OnScriptBitClear = function(self, bit)
        RadarUnit.OnScriptBitClear(self, bit)
        if bit == 1 then
            self:SetIntelRadius(self.IntelType, self.IntelRadiusBoosted or 170)
            self.EnergyMaintenanceConsumptionOverride = self.EnergyDrainBoosted
            self:UpdateConsumptionValues()
            self.IntelBoostStartThreadHandle = self:ForkThread( self.IntelBoostStartThread )
        end
    end,
    
    OnScriptBitSet = function(self, bit)
        RadarUnit.OnScriptBitSet(self, bit)
        if bit == 1 then
            self:SetIntelRadius(self.IntelType, self.IntelRadiusDefault or 115)
            self.EnergyMaintenanceConsumptionOverride = self.EnergyDrainDefault
            self:UpdateConsumptionValues()
            self.IntelBoostEndThreadHandle = self:ForkThread( self.IntelBoostEndThread )
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self.IntelBoostEffects:Destroy()
        RadarUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnDestroy = function(self)
        self.IntelBoostEffects:Destroy()
        self.IntelBoostExplosionEffects:Destroy()
        RadarUnit.OnDestroy(self)
    end,

    --self.IntelBoostStartThreadHandle = self:ForkThread( self.IntelBoostStartThread )
    IntelBoostStartThread = function(self) --the intel is boosted immediately, this is purely visual stuff
        self.IsIntelOvercharging = true
        if self.IntelBoostEndThreadHandle then KillThread( self.IntelBoostEndThreadHandle ) end
        self:DestroyIdleEffects()  -- remove the radar effect, the lines coming from the antennae
        
        if self.IntelBoostManipulator then --handle any animations here
            self:PlayUnitSound('IntelOverchargeChargingStart')
            self:PlayUnitAmbientSound('IntelOverchargeChargingLoop')
            self.IntelBoostManipulator:SetRate(1)
            WaitFor(self.IntelBoostManipulator)
            self:StopUnitAmbientSound('IntelOverchargeChargingLoop')
            self:PlayUnitSound('IntelOverchargeChargingStop')
        end
        
        self:PlayUnitSound('IntelOverchargeActivated')
        self:PlayUnitAmbientSound('IntelOverchargeActiveLoop')
        
        self:PlayIntelBoostEffects()
    end,
    
    --self.IntelBoostEndThreadHandle = self:ForkThread( self.IntelBoostEndThread )
    IntelBoostEndThread = function(self)
        self.IsIntelOvercharging = false
        if self.IntelBoostStartThreadHandle then KillThread( self.IntelBoostStartThreadHandle ) end
        self.IntelBoostEffects:Destroy()
        self:StopUnitAmbientSound('IntelOverchargeActiveLoop')
        self:PlayUnitSound('IntelOverchargeStopped')
        
        if self.IntelBoostManipulator then --handle any animations here
            self.IntelBoostManipulator:SetRate(-1)
            WaitFor(self.IntelBoostManipulator)
        end
        
        self:CreateIdleEffects()
    end,

    PlayIntelBoostEffects = function(self)
        for k, v in self.IntelBoostFx do
            local emit = CreateAttachedEmitter( self, self.IntelBoostFxBone, self.Army, v )
            emit:ScaleEmitter( self.IntelBoostFxScale or 1 )
            self.IntelBoostEffects:Add( emit )
            self.Trash:Add( emit )
        end
    end,

    PlayIntelBoostExplosionEffects = function(self)
        for k, v in self.OverchargeExplosionFx do
            local emit = CreateEmitterAtBone( self, self.OverchargeExplosionFxBone or self.IntelBoostFxBone, self.Army, v )
            emit:ScaleEmitter( self.OverchargeExplosionFxScale or 1 )
            self.IntelBoostExplosionEffects:Add( emit )
        end
    end,
}

NSonarUnit = Class(NRadarUnit) {
    IntelType = 'Sonar',
}

---------------------------------------------------------------
--  SHIELD STRUCTURES
---------------------------------------------------------------
ShieldStructureUnit = AddNomadsBeingBuiltEffects(ShieldStructureUnit)
NShieldStructureUnit = Class(ShieldStructureUnit) {
    RotationSpeed = 10,

    OnStopBeingBuilt = function(self, builder, layer)
        ShieldStructureUnit.OnStopBeingBuilt(self,builder,layer)
        local bone = self:GetBlueprint().Display.ShieldOnRotatingBone
        if bone then
            self.RotatorManip = CreateRotator(self, bone, 'y', nil, nil, 2, self.RotationSpeed)
            self.Trash:Add(self.RotatorManip)
        end
        if self.RotatorManip and builder and EntityCategoryContains(categories.SHIELD, builder) then
            self.RotatorManip:SetSpeed(self.RotationSpeed)
            self.RotatorManip:SetCurrentAngle(builder.RotatorManip:GetCurrentAngle())
        end
    end,

    OnShieldEnabled = function(self)
        ShieldStructureUnit.OnShieldEnabled(self)
        if self.RotatorManip then
            self.RotatorManip:SetTargetSpeed(self.RotationSpeed)
        end
        self:PlayUnitAmbientSound('ShieldActiveLoop')
    end,

    OnShieldDisabled = function(self)
        ShieldStructureUnit.OnShieldDisabled(self)
        if self.RotatorManip then
            self.RotatorManip:SetTargetSpeed(0)
        end
        self:StopUnitAmbientSound('ShieldActiveLoop')
    end,

    DestroyShield = function(self)
        if self.MyShield then
            self:StopUnitAmbientSound('ShieldActiveLoop')
        end
        ShieldStructureUnit.DestroyShield(self)
    end,
}

---------------------------------------------------------------
--  STRUCTURES
---------------------------------------------------------------
StructureUnit = AddNomadsBeingBuiltEffects(StructureUnit)
NStructureUnit = Class(StructureUnit) {

}

---------------------------------------------------------------
--  WALL  STRUCTURES
---------------------------------------------------------------
WallStructureUnit = AddNomadsBeingBuiltEffects(WallStructureUnit)
NWallStructureUnit = Class(WallStructureUnit) {

}

---------------------------------------------------------------
--  CIVILIAN STRUCTURES
---------------------------------------------------------------
NCivilianStructureUnit = Class(StructureUnit) {

}
