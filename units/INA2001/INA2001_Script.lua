-- T2 transport

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AddFlares = import('/lua/nomadsutils.lua').AddFlares
local AddLights = import('/lua/nomadsutils.lua').AddLights
local NAirTransportUnit = import('/lua/nomadsunits.lua').NAirTransportUnit

NAirTransportUnit = AddFlares( AddLights( NAirTransportUnit ) )

INA2001 = Class(NAirTransportUnit) {
    DestructionTicks = 250,

    -- bones that can be hidden: Antenna01, Antenna02, Flare01, Flare02, Flare03, Flare04, Flare05, Flare06, RocketLauncherArm
    LightBones = { { 'Antenna01', }, },
    ThrusterBurnBones = { 'Engine1', 'Engine2', },
    RocketLauncherBone = 'RocketLauncherArm',

    OnCreate = function(self)
        NAirTransportUnit.OnCreate(self)

        self:HideBone(self.RocketLauncherBone, true)

        self.ThrusterEffectsBag = TrashBag()
        self.ThrusterBurnEffectsBag = TrashBag()

        self.UnfoldAnim = CreateAnimator(self):PlayAnim('/units/INA2001/INA2001_Unfold.sca'):SetRate(0)
        self.UnfoldAnim:SetAnimationFraction(0)
        self.Trash:Add(self.UnfoldAnim)

        self:SetFlaresEnabled(false)
    end,

    OnDestroy = function(self)
        self:DestroyThrusterEffects()
        self:DestroyThrusterBurnEffects()
        NAirTransportUnit.OnDestroy(self)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        NAirTransportUnit.OnStopBeingBuilt(self,builder,layer)

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
        if self.UnfoldAnim then
            self.UnfoldAnim:SetRate(0)
        end
        NAirTransportUnit.OnKilled(self, instigator, type, overkillRatio)
        self:TransportDetachAllUnits(true)
    end,

    OnMotionVertEventChange = function( self, new, old )
        NAirTransportUnit.OnMotionVertEventChange( self, new, old )

        -- special abilities only available when on cruising height
        if new == 'Top' then
            -- unit reaching target altitude, coming from surface
            self:SetFlaresEnabled(true)
            self:DestroyThrusterBurnEffects()
            self:PlayThrusterEffects()

        elseif new == 'Down' then
            -- unit starts landing
            self:SetFlaresEnabled(false)
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
--            if old ~= 'Hover' and old ~= 'Down' then
                self:DestroyThrusterEffects()
                self:DestroyThrusterBurnEffects()
                self:PlayThrusterBurnEffects()
                self:DelayDestroyThrusterBurnEffects(2)
--            end
        end
    end,

    -- =============================================

    PlayThrusterEffects = function(self)
        -- normal thruster effects, probably on all the time

        if self:GetFractionComplete() < 1 then return end

        local army, emit = self:GetArmy()
        for k, v in NomadsEffectTemplate.T2TransportThrusters do
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
        for k, v in NomadsEffectTemplate.T2TransportThrusterBurn do
            for _, bone in self.ThrusterBurnBones do
                emit = CreateAttachedEmitter( self, bone, army, v )
                self.ThrusterBurnEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
        end

        local thread = self:ForkThread( self.ThrusterBurnDamageThread, 4 )
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
                            emitTempl = NomadsEffectTemplate.T2TransportThrusterBurnWaterSurfaceEffect
                        else
                            emitTempl = NomadsEffectTemplate.T2TransportThrusterBurnSurfaceEffect
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

    DelayDestroyThrusterBurnEffects = function(self, delay)
        -- stop thruster burn after x seconds
        local fn = function(self, delay)
            WaitSeconds(delay)
            if self and not self:IsDead() then
                self:DestroyThrusterBurnEffects()
            end
        end
        self:ForkThread(fn, delay)
    end,

    -- =============================================

    -- When one of our attached units gets killed, detach it
    OnAttachedKilled = function(self, attached)
        attached:DetachFrom()
    end,

    OnStartTransportLoading = function(self)
        --LOG('*DEBUG: OnStartTransportLoading')
        NAirTransportUnit.OnStartTransportLoading(self)
        self:Fold(true)
    end,

    OnStopTransportLoading = function(self)
        --LOG('*DEBUG: OnStopTransportLoading')
        NAirTransportUnit.OnStopTransportLoading(self)
        self:Fold(false)
    end,

    OnTransportAttach = function(self, attachBone, unit)
        --LOG('*DEBUG: OnTransportAttach')
        NAirTransportUnit.OnTransportAttach(self, attachBone, unit)
        self:Fold(true)
    end,

    OnTransportDetach = function(self, attachBone, unit)
        --LOG('*DEBUG: OnTransportDetach')
        NAirTransportUnit.OnTransportDetach(self, attachBone, unit)
        self:Fold(false)
    end,

    Fold = function(self, DoUnfold)
        if not self:IsDead() then

            -- makes the unit compact or not, depending on current cargo and some other parameters. Also adjusts hitbox accordingly.
            local FoldState = self:GetFoldState()
            local ShouldFold = ( table.getsize(self:GetCargo()) <= 0 )
            --LOG('*DEBUG: state = '..repr(FoldState)..' should fold = '..repr(ShouldFold)..' DoUnfold = '..repr(DoUnfold))

            if (FoldState == 'folded' or FoldState == 'folding') and (not ShouldFold or DoUnfold) then
                --LOG('*DEBUG: unfolding')
                local bp = self:GetBlueprint()
                local scale = bp.Display.UniformScale or 1
                self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, (bp.CollisionOffsetY + (bp.SizeY*1.0)) or 0, bp.CollisionOffsetZ or 0, bp.SizeX * scale, bp.SizeY * scale, bp.SizeZ * scale )
                self.UnfoldAnim:SetRate(1)

            elseif (FoldState == 'unfolded' or FoldState == 'unfolding') and ShouldFold then
                --LOG('*DEBUG: folding')
                local bp = self:GetBlueprint()
                local scale = bp.Display.UniformScale or 1
                self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, (bp.CollisionOffsetY + (bp.SizeYContracted*1.0)) or 0, bp.CollisionOffsetZ or 0, bp.SizeXContracted * scale, bp.SizeYContracted * scale, bp.SizeZContracted * scale )
                self.UnfoldAnim:SetRate(-1)
            end

        end
    end,

    GetFoldState = function(self)
        -- returning folded state based on animation state and direction
        if self.UnfoldAnim then
            if self.UnfoldAnim:GetAnimationFraction() <= 0 then return 'folded'
            elseif self.UnfoldAnim:GetAnimationFraction() >= 1 then return 'unfolded'
            elseif self.UnfoldAnim:GetRate() < 0 then return 'folding'
            elseif self.UnfoldAnim:GetRate() > 0 then return 'unfolding'
            end
        end
        return 'unknown'
    end,

    GetUnitSizes = function(self)
        local bp = self:GetBlueprint()
        if self:GetFoldState() == 'folded' or self:GetFoldState() == 'folding' then
            return bp.SizeXContracted, bp.SizeYContracted, bp.SizeZContracted
        end
        return bp.SizeX, bp.SizeY, bp.SizeZ
    end,
}

TypeClass = INA2001