-- Experimental transport

local Explosion = import('/lua/defaultexplosions.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NExperimentalAirTransportUnit = import('/lua/nomadsunits.lua').NExperimentalAirTransportUnit
local DarkMatterWeapon1 = import('/lua/nomadsweapons.lua').DarkMatterWeapon1
local MissileWeapon1 = import('/lua/nomadsweapons.lua').MissileWeapon1

XNA0401 = Class(NExperimentalAirTransportUnit) {

    Weapons = {
        ChainGun01 = Class(DarkMatterWeapon1) {},
        ChainGun02 = Class(DarkMatterWeapon1) {},
        ChainGun03 = Class(DarkMatterWeapon1) {},
        ChainGun04 = Class(DarkMatterWeapon1) {},
        SAM01 = Class(MissileWeapon1) {},
        SAM02 = Class(MissileWeapon1) {},
    },

    DestroyNoFallRandomChance = 1.1,  -- don't blow up in air when killed
    
    --engine bones that tilt side to side, and forwards/backwards
    EngineThrustControllerBones = {
        EngineArmRotatorLeft02 = false,
        EngineArmRotatorLeft01 = false,
        EngineArmRotatorRight01 = false,
        EngineArmRotatorRight02 = false,
        
        --the actual engines
        EngineRotatorRight01 = true,
        EngineRotatorRight02 = true,
        EngineRotatorRight03 = true,
        EngineRotatorRight04 = true,
        EngineRotatorLeft01 = true,
        EngineRotatorLeft02 = true,
        EngineRotatorLeft03 = true,
        EngineRotatorLeft04 = true
    },

    OnStopBeingBuilt = function(self, builder, layer)
        NExperimentalAirTransportUnit.OnStopBeingBuilt(self, builder, layer)

        -- set up the thrusting arcs for the engines
        for boneName,tiltForwards in self.EngineThrustControllerBones do
            local controller = CreateThrustController(self, "thruster", boneName)
            if tiltForwards == true then
                --                      XMAX,XMIN,YMAX,YMIN,ZMAX,ZMIN, TURNMULT, TURNSPEED
                controller:SetThrustingParam(-0.0, 0.0, -0.75, 0.75, -0.2, 0.2, 1.0, 0.08)
            elseif tiltForwards == false then
                controller:SetThrustingParam(-0.15, 0.15, -1.0, 1.0, -0.0, 0.0, 1.0, 0.08)
            end
        end

        self.LandingAnimManip = CreateAnimator(self)
        self.LandingAnimManip:SetPrecedence(0)
        self.Trash:Add(self.LandingAnimManip)
        self.LandingAnimManip:PlayAnim(self:GetBlueprint().Display.AnimationLand):SetRate(0)
        
        self.HolderArmManip = CreateAnimator(self)
        self.HolderArmManip:SetPrecedence(1)
        self.Trash:Add(self.HolderArmManip)
        self.HolderArmManip:PlayAnim(self:GetBlueprint().Display.AnimationHolder):SetRate(0.5)
    end,
    
    OnTransportAttach = function(self, attachBone, unit)
        NExperimentalAirTransportUnit.OnTransportAttach(self, attachBone, unit)
        if EntityCategoryContains(categories.NAVAL + categories.EXPERIMENTAL, unit) and self.HolderArmManip then
            self.HolderArmManip:SetRate(-1)
        end
    end,

    OnTransportDetach = function(self, attachBone, unit)
        NExperimentalAirTransportUnit.OnTransportDetach(self, attachBone, unit)
        if EntityCategoryContains(categories.NAVAL + categories.EXPERIMENTAL, unit) and self.HolderArmManip then
            self.HolderArmManip:SetRate(0.5)
        end
    end,
    
    OnMotionVertEventChange = function(self, new, old)
        NExperimentalAirTransportUnit.OnMotionVertEventChange(self, new, old)
        if (new == 'Hover') then
            self.LandingAnimManip:SetRate(1)
        elseif (new == 'Up') then
            self.LandingAnimManip:SetRate(-1)
        end
    end,
    
    BeamExhaustCruise = '/effects/emitters/transport_thruster_beam_01_emit.bp',
    BeamExhaustIdle = '/effects/emitters/transport_thruster_beam_02_emit.bp',


    --TODO: redo the crashing thread so its just as awesome but also makes sense with the new model:
    --[[
    option 1:
    1. create a rotator to tilt the transport to one side, randomly
    2. create explosions at the engine bones on that side.
    3. as the engines explode, the transport begins tilting towards that side.
    
    option 2 (superior):
    1. create 2 or more animations and put them in an anim block
    2. create explosions at the engine bones that correspond to the anim block (work out how to do this)
    3. add parts falling from the transport, and engines being displaced, ect. as the transport crashes
    --]]

    OnKilled = function(self, instigator, type, overkillRatio)
        self:ForkThread( self.CrashingThread )
        NExperimentalAirTransportUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    CrashingThread = function(self)

        -- Which engines to kill? Engines 1-4 left side (top down), 5-8 right side
        local engineToDestroy = Random( 1, 8 )

        if not self.Rotator then
            self.Rotator = CreateRotator( self, 0, 'z' )
            self.Trash:Add( self.Rotator )
            self.Rotator:SetAccel( 0 )
            self.Rotator:SetTargetSpeed( 0 )
            self.Rotator:SetSpeed( 0 )    
        end

        if engineToDestroy < 5 then
            -- explode here - all the engines are going to explode
            Explosion.CreateDefaultHitExplosionAtBone( self, 'EngineRotatorLeft01', Random( 1, 4) )
            Explosion.CreateDefaultHitExplosionAtBone( self, 'EngineRotatorLeft02', Random( 1, 4) )
            Explosion.CreateDefaultHitExplosionAtBone( self, 'EngineRotatorLeft03', Random( 1, 4) )
            Explosion.CreateDefaultHitExplosionAtBone( self, 'EngineRotatorLeft04', Random( 1, 4) )

            -- hide the actual engines - they exploded
            self:HideBone('EngineRotatorLeft01', true)
            self:HideBone('EngineRotatorLeft02', true)
            self:HideBone('EngineRotatorLeft04', true)
            self:HideBone('EngineRotatorLeft03', true)

            -- bank LEFT and spiral out of control
            self.Rotator:SetAccel(20)
            self.Rotator:SetTargetSpeed(-700)
            self.Rotator:SetSpeed(1)
        else 
            -- explode here - all the engines are going to explode
            Explosion.CreateDefaultHitExplosionAtBone( self, 'EngineRotatorRight01', Random( 1, 4) )
            Explosion.CreateDefaultHitExplosionAtBone( self, 'EngineRotatorRight02', Random( 1, 4) )
            Explosion.CreateDefaultHitExplosionAtBone( self, 'EngineRotatorRight03', Random( 1, 4) )
            Explosion.CreateDefaultHitExplosionAtBone( self, 'EngineRotatorRight04', Random( 1, 4) )

            -- hide the actual engines - they exploded
            self:HideBone('EngineRotatorRight01', true)
            self:HideBone('EngineRotatorRight02', true)
            self:HideBone('EngineRotatorRight03', true)
            self:HideBone('EngineRotatorRight04', true)

            -- bank RIGHT and spiral out of control
            self.Rotator:SetAccel(20)
            self.Rotator:SetTargetSpeed(700)
            self.Rotator:SetSpeed(1)
        end



        -- create detector so we know when we hit the surface with what bone
        self.detector = CreateCollisionDetector(self)
        self.Trash:Add(self.detector)
        self.detector:WatchBone('Attachpoint_Lrg_01')
        self.detector:WatchBone('Attachpoint_Lrg_02')
        self.detector:WatchBone('Attachpoint_Lrg_17')
        self.detector:WatchBone('Attachpoint_Lrg_18')
        self.detector:EnableTerrainCheck(true)
        self.detector:Enable()
    end,

    OnAnimTerrainCollision = function(self, bone, x, y, z)
        local bp = self:GetBlueprint()

        -- do damage
        for k, wep in bp.Weapon do
            if wep.Label == 'ImpactWithSurface' then
                DamageArea( self, Vector(x, y, z), wep.DamageRadius, wep.Damage, wep.DamageType, wep.DamageFriendly, false)
                DamageRing(self, Vector(x, y, z), 1, 4, 1, 'Force', true)
                break
            end
        end
        Explosion.CreateDebrisProjectiles(self, Explosion.GetAverageBoundingXYZRadius(self), { self:GetUnitSizes() })
        Explosion.CreateDefaultHitExplosionAtBone( self, bone, 2 )
    end,

    OnImpact = function(self, with, other)
        -- plays when the unit is killed. All effects should have a lifetime cause we won't remove them via scripting; this unit is dead in a moment.

        local bp = self:GetBlueprint()
        local pos = self:GetPosition()
        local emit

        -- find damage ring sizes
        local damageRingSize = 10
        for k, wep in bp.Weapon do
            if wep.Label == 'DeathImpact' then
                damageRingSize = wep.DamageRadius * 1.2
                break
            end
        end

        -- damage effects
        for k, v in NomadsEffectTemplate.ExpTransportDestruction do
            emit = CreateEmitterAtBone(self, 0, self.Army, v)
        end
        DamageRing(self, pos, 0.1, damageRingSize, 1, 'Force', true)
        DamageRing(self, pos, 0.1, damageRingSize, 1, 'Force', true)
        Explosion.CreateFlash( self, 0, 3, self.Army )

        self:ShakeCamera(8, 3, 1, 1)

        NExperimentalAirTransportUnit.OnImpact(self, with, other)
    end,
}

TypeClass = XNA0401