-- Experimental transport

local Explosion = import('/lua/defaultexplosions.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NAirTransportUnit = import('/lua/nomadsunits.lua').NAirTransportUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local DarkMatterWeapon1 = import('/lua/nomadsweapons.lua').DarkMatterWeapon1

XNA0401 = Class(NAirTransportUnit) {

    Weapons = {
        ChainGun01 = Class(DarkMatterWeapon1) {},
        ChainGun02 = Class(DarkMatterWeapon1) {},
        ChainGun03 = Class(DarkMatterWeapon1) {},
        ChainGun04 = Class(DarkMatterWeapon1) {},
        --AGRockets = Class(RocketWeapon1) {},
    },

    DestroyNoFallRandomChance = 1.1,  -- don't blow up in air when killed

    OnCreate = function(self)
        NAirTransportUnit.OnCreate(self)
        self.ThrusterEffectsBag = TrashBag()
    end,

    OnDestroy = function(self)
        self:DestroyThrusterEffects()
        NAirTransportUnit.OnDestroy(self)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NAirTransportUnit.OnStopBeingBuilt(self, builder, layer)

        end

        -- self.LandingAnimManip = CreateAnimator(self)
        -- self.LandingAnimManip:SetPrecedence(0)
        -- self.Trash:Add(self.LandingAnimManip)
        -- self.LandingAnimManip:PlayAnim(self:GetBlueprint().Display.AnimationLand):SetRate(1)
        self:ForkThread(self.ExpandThread)
    end,
    

    OnMotionVertEventChange = function(self, new, old)
        NAirTransportUnit.OnMotionVertEventChange(self, new, old)
        if (new == 'Down') then
            --self.LandingAnimManip:SetRate(-1)
        elseif (new == 'Up') then
            --self.LandingAnimManip:SetRate(1)
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
-- TODO: investigate destroying parts of the model while falling to earth. Probably requires vertex groups used on model (not sure if that's the case) and
-- then hiding certain bones. The wreckage needs to have these bones hidden aswell (not sure if that goes automatically).
        self:DestroyThrusterEffects()
        self:ForkThread( self.CrashingThread )
        NAirTransportUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    


    PlayThrusterEffects = function(self)
        -- normal thruster effects, probably on all the time

        if self:GetFractionComplete() < 1 then return end

        local army, emit = self:GetArmy()
        for k, v in NomadsEffectTemplate.ExpTransportThrusters do
            for _, bone in self.ThrusterBurnBones do
                emit = CreateAttachedEmitter( self, bone, army, v )
                self.ThrusterEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
        end
    end,

    DestroyThrusterEffects = function(self)
        self.ThrusterEffectsBag:Destroy()
    end,


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
    
    CrashingThread = function(self)

        -- create detector so we know when we hit the surface with what bone
        self.detector = CreateCollisionDetector(self)
        self.Trash:Add(self.detector)
        self.detector:WatchBone('Attachpoint01')
        self.detector:WatchBone('Attachpoint02')
        self.detector:WatchBone('Attachpoint03')
        self.detector:WatchBone('Attachpoint04')
        self.detector:WatchBone('Attachpoint05')
        self.detector:WatchBone('Attachpoint06')
        self.detector:WatchBone('Attachpoint07')
        self.detector:WatchBone('Attachpoint08')
        self.detector:WatchBone('Attachpoint09')
        self.detector:WatchBone('Attachpoint10')
        self.detector:WatchBone('Attachpoint11')
        self.detector:WatchBone('Attachpoint12')
        self.detector:WatchBone('Attachpoint13')
        self.detector:WatchBone('Attachpoint14')
        self.detector:WatchBone('Attachpoint15')
        self.detector:WatchBone('Attachpoint16')
        self.detector:WatchBone('Attachpoint17')
        self.detector:WatchBone('Attachpoint18')
        for k, bone in self.ThrusterBurnBones do
            self.detector:WatchBone( bone )
        end
        self.detector:EnableTerrainCheck(true)
        self.detector:Enable()

        -- set up all thruster emitters again, then keep checking over time which thruster bones are lowest and disable those thrusters
        local army, emits, emit = self:GetArmy(), {}
        for i, bone in self.ThrusterBurnBones do
            emits[i] = {}
            for k, v in NomadsEffectTemplate.ExpTransportThrusters do
                emit = CreateAttachedEmitter( self, bone, army, v )
                table.insert( emits[i], emit )
                self.Trash:Add( emit )
            end
        end

        WaitTicks( 2 )

        -- check which thrusters are lowest and which are highest
        local avg, height, bAvgList, aAvgList, pos = 0, {}, {}, {}
        for i, bone in self.ThrusterBurnBones do
            pos = self:GetPosition(bone)
            height[i] = pos[2]
            avg = avg + height[i]
        end
        avg = avg / table.getsize( self.ThrusterBurnBones )
        for i, bone in self.ThrusterBurnBones do
            if height[i] < avg then
                table.insert( bAvgList, i )
            else
                table.insert( aAvgList, i )
            end
        end

        -- the bAvgList (belowAvererageList) contains the thruster numbers that should quickly be disabled
        for k, i in RandomIter( bAvgList ) do
            WaitTicks( Random(1, 3) )
            for k, emit in emits[i] do
                emit:Destroy()
            end
        end

        WaitTicks( 5 )

        -- the aAvgList (aboveAvererageList) contains the thruster numbers that are still active. Over random periods disable these
        for k, i in RandomIter( aAvgList ) do
            WaitTicks( Random(1, 7) )
            for k, emit in emits[i] do
                emit:Destroy()
            end
        end
    end,

    OnAnimTerrainCollision = function(self, bone, x, y, z)
        -- happens when detector detects collision with surface
        self:KilledAndBoneHitsSurface( bone, Vector(x, y, z) )
    end,

    KilledAndBoneHitsSurface = function(self, bone, pos )
        local bp = self:GetBlueprint()

        -- do damage
        for k, wep in bp.Weapon do
            if wep.Label == 'ImpactWithSurface' then
                DamageArea( self, pos, wep.DamageRadius, wep.Damage, wep.DamageType, wep.DamageFriendly, false)
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
        local army, emit = self:GetArmy()

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
            emit = CreateEmitterAtBone(self, 0, army, v)
        end
        DamageRing(self, pos, 0.1, damageRingSize, 1, 'Force', true)
        DamageRing(self, pos, 0.1, damageRingSize, 1, 'Force', true)
        Explosion.CreateFlash( self, 0, 3, army )

        self:ShakeCamera(8, 3, 1, 1)

        NAirTransportUnit.OnImpact(self, with, other)
    end,
}

TypeClass = XNA0401