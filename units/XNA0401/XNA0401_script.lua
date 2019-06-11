-- Experimental transport

local Explosion = import('/lua/defaultexplosions.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NAirTransportUnit = import('/lua/nomadsunits.lua').NAirTransportUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1

XNA0401 = Class(NAirTransportUnit) {

    Weapons = {
        AARockets = Class(RocketWeapon1) {},
        AGRockets = Class(RocketWeapon1) {},
    },

    DestroyNoFallRandomChance = 1.1,  -- don't blow up in air when killed
    ThrusterBurnBones = { 'ThrustMain1', 'ThrustMain2', 'ThrustMain3', 'ThrustMain4', 'ThrustMain5', 'ThrustMain6', },

    OnCreate = function(self)
        NAirTransportUnit.OnCreate(self)
        self.ThrusterEffectsBag = TrashBag()
        self.ThrusterBurnEffectsBag = TrashBag()
    end,

    OnDestroy = function(self)
        self:DestroyThrusterEffects()
        self:DestroyThrusterBurnEffects()
        NAirTransportUnit.OnDestroy(self)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NAirTransportUnit.OnStopBeingBuilt(self, builder, layer)

        -- find thruster burn weapon. It's a dummy so we can't use getweaponbylabel
        local wepBp, n = self:GetBlueprint().Weapon, -1
        self.ThrusterBurnBpNum = nil
        for k, v in wepBp do
            if v.Label == 'ThrusterBurn' then
                self.ThrusterBurnBpNum = k
                break
            end
        end

        -- effects
        self:PlayThrusterEffects()
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
-- TODO: investigate destroying parts of the model while falling to earth. Probably requires vertex groups used on model (not sure if that's the case) and
-- then hiding certain bones. The wreckage needs to have these bones hidden aswell (not sure if that goes automatically).
        self:DestroyThrusterEffects()
        self:DestroyThrusterBurnEffects()
        self:ForkThread( self.CrashingThread )
        NAirTransportUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnMotionVertEventChange = function( self, new, old )
        NAirTransportUnit.OnMotionVertEventChange( self, new, old )

        -- special abilities only available when on cruising height
        if new == 'Top' then
            -- unit reaching target altitude, coming from surface
            self:DestroyThrusterBurnEffects()
            self:PlayThrusterEffects()

        elseif new == 'Down' then
            -- unit starts landing
            self:DestroyThrusterEffects()
            self:DestroyThrusterBurnEffects()
            self:PlayThrusterBurnEffects()

        elseif new == 'Hover' then
            if old ~= 'Down' then
                self:DestroyThrusterEffects()
                self:DestroyThrusterBurnEffects()
                self:PlayThrusterBurnEffects()
            end

        elseif new == 'Up' then
            if old ~= 'Hover' then
                self:DestroyThrusterEffects()
                self:DestroyThrusterBurnEffects()
                self:PlayThrusterBurnEffects()
            end

        elseif new == 'Bottom' then  -- when the transport lands on the surface (happens when the unit it's loading is destroyed just before it can be attached)
            if old ~= 'Hover' and old ~= 'Down' then
                self:DestroyThrusterEffects()
                self:DestroyThrusterBurnEffects()
                self:PlayThrusterBurnEffects()
            end

        end
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

    PlayThrusterBurnEffects = function(self)
        -- do a thruster burn, damaging the units below the transport

        if self:GetFractionComplete() < 1 then return end

        local army, emit = self:GetArmy()
        for k, v in NomadsEffectTemplate.ExpTransportThrusterBurn do
            for _, bone in self.ThrusterBurnBones do
                emit = CreateAttachedEmitter( self, bone, army, v )
                self.ThrusterBurnEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
        end

        local thread = self:ForkThread( self.ThrusterBurnDamageThread, 7 )
        self.ThrusterBurnEffectsBag:Add( thread )
    end,

    ThrusterBurnDamageThread = function(self, maxDist)
        -- repeatedly damages the area below the transport. The maxDist determines how far below the transport the area is damaged. This should be close to the
        -- edge of the burn effects. Damage stats set by dummy weapon in unit BP.

        -- get weapon stats
        local wepBp = false
        local dmgInt = 100
        if self.ThrusterBurnBpNum then
            wepBp = self:GetBlueprint().Weapon[ self.ThrusterBurnBpNum ]
            dmgInt = 10 / wepBp.RateOfFire
        end

        local cntr = math.ceil( dmgInt / 2 )
        local army, emits, prevOffset, emit, emitTempl, offset, pos, surface, doDmg, onWater = self:GetArmy(), {}, {}

        while self do

            -- check if we should do damage and do damage interval things
            doDmg = (cntr <= 0)
            if doDmg then cntr = dmgInt end
            cntr = cntr - 1

            -- go through all bones and adjust surface effect offset
            for boneN, bone in self.ThrusterBurnBones do

                -- calculate the distance from the thruster bone to the surface. if it's low enough create the surface emitter and
                -- start to deal damage. The emitter is atatched to the thruster bone and given an offset so it's always moving along
                -- with the unit nicely but we'll have to update the offset of the effect continuously. IF not the emitter disappears
                -- below the surface if the unit is further descending.

                -- calculating surface height and emitter offset
                pos = self:GetPosition(bone)
                surface = GetSurfaceHeight(pos[1], pos[3])    --GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
                onWater = GetTerrainHeight(pos[1], pos[3]) < GetSurfaceHeight(pos[1], pos[3])
                offset = pos[2]
                pos[2] = math.max( pos[2] - maxDist, surface )
                offset = offset - pos[2]

                -- adjust emitter height if the calculated endpoint of the fire jet is at or below the surface. Also dealing damage.
                if pos[2] <= surface then

                    -- create emitters if not done yet
                    if not emits[ boneN ] then emits[ boneN ] = {} end
                    if table.getsize( emits[boneN] ) <= 0 then

                        if onWater then
                            emitTempl = NomadsEffectTemplate.ExpTransportThrusterBurnWaterSurfaceEffect
                        else
                            emitTempl = NomadsEffectTemplate.ExpTransportThrusterBurnSurfaceEffect
                        end


                        for k, v in emitTempl do
                            emit = CreateAttachedEmitter( self, bone, army, v )
                            table.insert( emits[ boneN ], emit )
                            self.ThrusterBurnEffectsBag:Add( emit )
                            self.Trash:Add( emit )
                        end
                    end

                    -- changing offset so the emitter stays more or less on the surface. Since the offset stacks first the previous offset
                    -- is reverted, so we're back at the bone before setting the new offset. If not the effect moves away.
                    if not prevOffset[ boneN ] then prevOffset[ boneN ] = 0 end
                    if offset ~= prevOffset[ boneN ] then
                        for k, emit in emits[ boneN ] do
                            emit:OffsetEmitter(0, 0, -prevOffset[ boneN ] )
                            emit:OffsetEmitter(0, 0, offset)
                        end
                        prevOffset[ boneN ] = offset
                    end

                    -- deal damage at end of flame jet
                    if doDmg and wepBp ~= false then
                        DamageRing( self, pos, 0.1, wepBp.DamageRadius, wepBp.Damage, wepBp.DamageType, wepBp.DamageFriendly, false)
                    end

                    -- burn trees
                    DamageRing( self, pos, 0.1, 2, 1, 'BigFire', false, false )

                -- if the flame endpoint is above the surface remove the emitters and don't deal damage
                else

                    -- remove surface emitters
                    if table.getsize( emits[boneN] ) > 0 then
                        for k, emit in emits[ boneN ] do
                            emit:Destroy()
                        end
                        emits[boneN] = {}
                    end
                    prevOffset[ boneN ] = 0

                end
            end

            WaitTicks(1)
        end
    end,

    DestroyThrusterBurnEffects = function(self)
        -- stop thruster burn
        self.ThrusterBurnEffectsBag:Destroy()
    end,

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