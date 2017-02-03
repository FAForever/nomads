local Entity = import('/lua/sim/Entity.lua').Entity
local util = import('utilities.lua')

local DefaultUnitsFile = import('defaultunits.lua')
local AirFactoryUnit = DefaultUnitsFile.AirFactoryUnit
local AirStagingPlatformUnit = DefaultUnitsFile.AirStagingPlatformUnit
local AirUnit = DefaultUnitsFile.AirUnit
local AirTransport = DefaultUnitsFile.AirTransport
local ConcreteStructureUnit = DefaultUnitsFile.ConcreteStructureUnit
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
local ShieldLandUnit = DefaultUnitsFile.ShieldLandUnit
local ShieldStructureUnit = DefaultUnitsFile.ShieldStructureUnit
local SonarUnit = DefaultUnitsFile.SonarUnit
local StructureUnit = DefaultUnitsFile.StructureUnit
local SubUnit = DefaultUnitsFile.SubUnit
local WalkingLandUnit = DefaultUnitsFile.WalkingLandUnit
local WallStructureUnit = DefaultUnitsFile.WallStructureUnit
local QuantumGateUnit = DefaultUnitsFile.QuantumGateUnit
local RadarJammerUnit = DefaultUnitsFile.RadarJammerUnit
local ShieldSeaUnit = DefaultUnitsFile.ShieldSeaUnit

local HoverLandUnit = DefaultUnitsFile.HoverLandUnit

local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

local EffectUtil = import('/lua/EffectUtilities.lua')
local NomadsEffectUtil = import('/lua/nomadseffectutilities.lua')
local PlayEffectsAtBones = EffectUtil.CreateBoneTableRangedScaleEffects
local CreateBuildCubeThread = NomadsEffectUtil.CreateBuildCubeThread
local CreateNomadsBuildSliceBeams = NomadsEffectUtil.CreateNomadsBuildSliceBeams
local CreateRepairBuildBeams = NomadsEffectUtil.CreateRepairBuildBeams


-- added later
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local Unit = import('/lua/sim/Unit.lua').Unit
local NomadsOrbitUtils = import('/lua/nomadsorbitalutils.lua')


function AddNomadsBeingBuiltEffects( SuperClass )
  return Class(SuperClass) {

    StartBeingBuiltEffects = function(self, builder, layer)
        -- starts the build effect thread, which creates the build cube and the flashing. The flashing is avoided if the unit is upgrading.
        local UpgradesFrom = self:GetBlueprint().General.UpgradesFrom or false
        local IsUpgrade = (UpgradesFrom == builder:GetUnitId())
        self.OnBeingBuiltEffectsBag:Add( self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag, nil, IsUpgrade))
        if not IsUpgrade then
            self:SetMesh(self:GetBlueprint().Display.BuildMeshBlueprint, true)
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
        if self:GetBlueprint().General.BuildBones.BuildEffectBones then

            local bp, army, emit, offset, unitHeight = self:GetBlueprint(), self:GetArmy()
            local bones = bp.General.BuildBones.BuildEffectBones
            local emitrate = math.ceil((bp.Economy.BuildRate or 1) / 2)

            -- creates the orange build fields
            self.BuildEffectsBag:Add( self:ForkThread(NomadsEffectUtil.CreateFactoryBuildBeams, unitBeingBuilt, bones, self.BuildEffectsBag) )

            -- add effects to the build field
            for k, bone in bones do
                offset, unitHeight = self:GetEffectOffsetRange(bone)
                for _, v in NomadsEffectTemplate.FactoryConstructionField do
                    emit = CreateAttachedEmitter( self, bone, army, v)
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
            --WARN('NLandFactoryUnit -> MovingArmsThread: no unit being built '..repr(self:GetUnitId()))
            return
        elseif not self.ArmSlider1 then
            --wARN('NLandFactoryUnit -> MovingArmsThread: No arm slider '..repr(self:GetUnitId()))
            return
        end

        local r = 0.9         -- while the construction progress is below this move to 'max'. When over this, go back to 'min'
        local z, mul, dir, emit = 0, 0, 1
        local InitialDist, Length = self:GetInitialAndLength()
        if self:GetBlueprint().Display.BuildEffect.Factory.BuildFieldReversed then dir = -1 end  -- some factories have backwards bones, here's a correction
        self.ArmSlider1:SetSpeed( 1000 ):SetWorldUnits(true)

        while not self:BeenDestroyed() and not self.UnitBeingBuilt:BeenDestroyed() and self.UnitBeingBuilt:GetFractionComplete() < 1 and not self:IsDead() do

            if self.UnitBeingBuilt:GetFractionComplete() <= r then
                mul = self.UnitBeingBuilt:GetFractionComplete() / r
            else
                mul = 1 - ((self.UnitBeingBuilt:GetFractionComplete() - r) * (1 / (1 - r)))
            end

            z = (InitialDist + (Length * mul)) * dir
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
        local BuildAttachBone = self:GetBlueprint().Display.BuildAttachBone or 0
        local ubbBp = self.UnitBeingBuilt:GetBlueprint()
        local UnitSizeZ = (ubbBp.SizeZ or 1)
        local MeshExtendsFront = ubbBp.Display.BuildEffect.ExtendsFront or 0
        local MeshExtendsRear = ubbBp.Display.BuildEffect.ExtendsRear or 0
        local UnitOffsetZ = ubbBp.CollisionOffsetZ or 0
        local diffZ = self:GetPosition(self.SliderBone)[3] - self:GetPosition(BuildAttachBone)[3]
        local correction = self:GetBlueprint().Display.BuildEffect.Factory.BuildFieldOffset or 0
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

        if not self:IsDead() then
            local layer = self:GetCurrentLayer()
            if new == 'Stopped' or new == 'Stopping' then   -- when stopping play the idle sound, on water play a different one
                if layer == 'Water' and self:GetBlueprint().Audio and self:GetBlueprint().Audio.AmbientMoveWater then
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
            while not self:IsDead() and self.DoCrushing do
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
        -- CreateUnitHPR('inu1002', self:GetArmy(), pos[1], pos[2], pos[3], 0,0,0)
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

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        -- If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom ~= 'none' and self:IsUnitState('Guarding'))then
            self.BuildEffectsBag:Add( NomadsEffectUtil.CreateRepairBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag ) )
        else
            self.BuildEffectsBag:Add( NomadsEffectUtil.CreateNomadsBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag ) )
        end
    end,

    OnStopBuild = function(self, unitBuilding)
        WalkingLandUnit.OnStopBuild(self, unitBuilding)
        if self.BuildRotator then
            self.BuildRotator:SetGoal(0)
        end
        if self.BuildArmManipulator then
            self.BuildArmManipulator:SetAimingArc(-180, 180, 360, -180, 180, 360)
        end
    end,

    CreateReclaimEffects = function( self, target )
        NomadsEffectUtil.PlayNomadsReclaimEffects( self, target, self:GetBlueprint().General.BuildBones.BuildEffectBones or {0,}, self.ReclaimEffectsBag )
    end,

    CreateReclaimEndEffects = function( self, target )
        NomadsEffectUtil.PlayNomadsReclaimEndEffects( self, target, self.ReclaimEffectsBag )
    end,
}

---------------------------------------------------------------
--  SUBMARINE UNITS
---------------------------------------------------------------
NSubUnit = Class(SubUnit) {}

---------------------------------------------------------------
--  Construction Units
---------------------------------------------------------------
NConstructionUnit = Class(ConstructionUnit) {

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        if (not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom ~= 'none' and self:IsUnitState('Guarding')) then
            CreateRepairBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
        else
            CreateNomadsBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )   
        end  	
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

    CreateReclaimEffects = function( self, target )
        NomadsEffectUtil.PlayNomadsReclaimEffects( self, target, self:GetBlueprint().General.BuildBones.BuildEffectBones or {0,}, self.ReclaimEffectsBag )
    end,

    CreateReclaimEndEffects = function( self, target )
        NomadsEffectUtil.PlayNomadsReclaimEndEffects( self, target, self.ReclaimEffectsBag )
    end,

    -- The code below for speed reduction and weapon disabling in water should be the same as the amphibious unit class, above

    OnKilled = function(self, instigator, type, overkillRatio)
        ConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
        self:DestroyMovementEffects()  -- remove green hover effect
        self:StopBuildingEffects()  -- remove building beams
    end,

    OnMotionHorzEventChange = function( self, new, old )
        ConstructionUnit.OnMotionHorzEventChange( self, new, old )

        if not self:IsDead() then
            local layer = self:GetCurrentLayer()
            if new == 'Stopped' or new == 'Stopping' then   -- when stopping play the idle sound, on water play a different one
                if layer == 'Water' and self:GetBlueprint().Audio and self:GetBlueprint().Audio.AmbientMoveWater then
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
        local orbit = self:GetBlueprint().Physics.Elevation or 75
        pos[2] = surface + orbit
        Warp( self, pos, self:GetOrientation() )

        -- in orbit we have a slight rotation
        if self:GetBlueprint().Physics.RotateOnSpot ~= false then
            self.RotatorManip = CreateRotator( self, 0, 'y', nil, 2 )
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
            local army, emit = self:GetArmy()
            for k, v in NomadsEffectTemplate[ self.ActiveEffectTemplateName ] do
                emit = CreateAttachedEmitter(self, self.ActiveEffectBone, army, v)
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
--  RADAR STRUCTURES
---------------------------------------------------------------
RadarUnit = AddNomadsBeingBuiltEffects(RadarUnit)
NRadarUnit = Class(RadarUnit) {

    OverchargeFxBone = 0,
    OverchargeChargingFxBone = 0,

    OverchargeFx = NomadsEffectTemplate.T1RadarOvercharge,
    OverchargeRecoveryFx = NomadsEffectTemplate.T1RadarOverchargeRecovery,
    OverchargeChargingFx = NomadsEffectTemplate.T1RadarOverchargeCharging,
    OverchargeFxScale = 1,
    OverchargeRecoveryFxScale = 1,
    OverchargeChargingFxScale = 1,
}

---------------------------------------------------------------
--  SONAR STRUCTURES
---------------------------------------------------------------
SonarUnit = AddNomadsBeingBuiltEffects(SonarUnit)
NSonarUnit = Class(SonarUnit) {

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
            local speed = builder.RotationSpeed or self.RotationSpeed
            self.RotatorManip:SetSpeed(speed)
            self.RotatorManip:SetCurrentAngle(builder.RotatorManip:GetCurrentAngle())
        end
    end,

    OnShieldEnabled = function(self)
        ShieldStructureUnit.OnShieldEnabled(self)
        self:PlayUnitAmbientSound('ShieldActiveLoop')
    end,

    OnShieldDisabled = function(self)
        ShieldStructureUnit.OnShieldDisabled(self)
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
