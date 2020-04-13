-- T2 transport

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AddLights = import('/lua/nomadsutils.lua').AddLights
local NAirTransportUnit = import('/lua/nomadsunits.lua').NAirTransportUnit

NAirTransportUnit = AddLights( NAirTransportUnit )

XNA0104 = Class(NAirTransportUnit) {
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

        self.UnfoldAnim = CreateAnimator(self):PlayAnim('/units/XNA0104/XNA0104_Unfold.sca'):SetRate(0)
        self.UnfoldAnim:SetAnimationFraction(0)
        self.Trash:Add(self.UnfoldAnim)

    end,

    OnDestroy = function(self)
        self:DestroyThrusterEffects()
        self:DestroyThrusterBurnEffects()
        NAirTransportUnit.OnDestroy(self)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        NAirTransportUnit.OnStopBeingBuilt(self,builder,layer)

        -- effects
        self:PlayThrusterEffects()
        self:Fold(true)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.UnfoldAnim then
            self.UnfoldAnim:SetRate(0)
        end
        self:DestroyThrusterEffects()
        NAirTransportUnit.OnKilled(self, instigator, type, overkillRatio)
        self:TransportDetachAllUnits(true)
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

        local emit
        for k, v in NomadsEffectTemplate.T2TransportThrusters do
            for _, bone in self.ThrusterBurnBones do
                emit = CreateAttachedEmitter( self, bone, self.Army, v )
                self.ThrusterEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
        end
    end,

    DestroyThrusterEffects = function(self)
        self.ThrusterEffectsBag:Destroy()
    end,

    PlayThrusterBurnEffects = function(self)

        if self:GetFractionComplete() < 1 then return end

        local emit
        for k, v in NomadsEffectTemplate.T2TransportThrusterBurn do
            for _, bone in self.ThrusterBurnBones do
                emit = CreateAttachedEmitter( self, bone, self.Army, v )
                self.ThrusterBurnEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
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
            if self and not self.Dead then
                self:DestroyThrusterBurnEffects()
            end
        end
        self:ForkThread(fn, delay)
    end,

    -- =============================================

    Fold = function(self, DoUnfold)
        if not self.Dead then

            -- makes the unit compact or not, depending on current cargo and some other parameters. Also adjusts hitbox accordingly.
            local FoldState = self:GetFoldState()
            local ShouldFold = ( table.getsize(self:GetCargo()) <= 0 )
            --LOG('*DEBUG: state = '..repr(FoldState)..' should fold = '..repr(ShouldFold)..' DoUnfold = '..repr(DoUnfold))

            if (FoldState == 'folded' or FoldState == 'folding') and (not ShouldFold or DoUnfold) then
                --LOG('*DEBUG: unfolding')
                local bp = self:GetBlueprint()
                local scale = bp.Display.UniformScale or 1
                self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, (bp.CollisionOffsetY + (bp.SizeY*1.0)) or 0, bp.CollisionOffsetZ or 0, bp.SizeX * scale, bp.SizeY * scale, bp.SizeZ * scale )
                self.UnfoldAnim:SetRate(0.5)

            elseif (FoldState == 'unfolded' or FoldState == 'unfolding') and ShouldFold then
                --LOG('*DEBUG: folding')
                local bp = self:GetBlueprint()
                local scale = bp.Display.UniformScale or 1
                self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, (bp.CollisionOffsetY + (bp.SizeYContracted*1.0)) or 0, bp.CollisionOffsetZ or 0, bp.SizeXContracted * scale, bp.SizeYContracted * scale, bp.SizeZContracted * scale )
                self.UnfoldAnim:SetRate(-0.5)
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

TypeClass = XNA0104
