-- T3 SCU factory

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AddLights = import('/lua/nomadsutils.lua').AddLights
local Entity = import('/lua/sim/Entity.lua').Entity
local NSCUFactoryUnit = import('/lua/nomadsunits.lua').NSCUFactoryUnit

NSCUFactoryUnit = AddLights(NSCUFactoryUnit)

XNB0304 = Class(NSCUFactoryUnit) {

    LightBones = { { 'Light1', 'Light3', 'Light5', 'Light2', 'Light4', 'Light6', }, },
    SliderBone = 'BuildArm1',

    OnCreate = function(self)
        NSCUFactoryUnit.OnCreate(self)
        self.TractorSlider = CreateSlider(self, 'TractorFocus', 0, 0, 0, -1, true)
        self.TractorSlider:SetWorldUnits(true)
        self.Trash:Add( self.TractorSlider )
        self.TractorBeamBag = TrashBag()
    end,

    OnDestroy = function(self)
        self:DestroyTractorBeamFx()
        NSCUFactoryUnit.OnDestroy(self)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self:DestroyTractorBeamFx()
        NSCUFactoryUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        -- self being build
        NSCUFactoryUnit.OnStopBeingBuilt(self, builder, layer)
    end,

    OnStartBuild = function(self, unitBeingBuilt, order)
        -- start building a unit
        NSCUFactoryUnit.OnStartBuild(self, unitBeingBuilt, order)

        local ubp = unitBeingBuilt:GetBlueprint()
        if unitBeingBuilt and ubp.Display.BuildEffect.PartArrivesByDropshipBone then
            if self.PartArrivesByDropshipThreadHandle then
                KillThread( self.PartArrivesByDropshipThreadHandle )
            end
            self.PartArrivesByDropshipThreadHandle = self:ForkThread( self.PartArrivesByDropshipThread, unitBeingBuilt)
        end
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        -- stop building a unit
        NSCUFactoryUnit.OnStopBuild(self, unitBeingBuilt)
    end,

    OnFailedToBuild = function(self)
        -- failed to build because the user cancelled construction or the factory was destroyed
        NSCUFactoryUnit.OnFailedToBuild(self)
        self:DestroyPartArrivesByDropshipThread()
    end,

    FinishBuildThread = function(self, unitBeingBuilt, order )
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)

        -- waiting for head attached to body (see thread below)
        while self and not self.Dead and self.PABD_progress < 10 do
            WaitTicks(1)
        end

        NSCUFactoryUnit.FinishBuildThread( self, unitBeingBuilt, order )
    end,

    PartArrivesByDropshipThread = function(self, unitBeingBuilt)

        -- The bones that are supposed to arrive by dropship are hidden and a lookalike is created that shows these hidden bones. Bones can't
        -- be hidden on the lookalike so a seperate model has to be created that is exactly the same as the hidden bones on the unit.
        -- 2 models that appear to be one, it's all trickery and deceit!

        local ubp = unitBeingBuilt:GetBlueprint()
        local ubbBone = ubp.Display.BuildEffect.PartArrivesByDropshipBone
        local pos = self:GetPosition('TractorFocus')

        -- creating and positioning lookalike
        self.lookalike = Entity()
        self.Trash:Add( self.lookalike )
        self.lookalike:SetPosition( pos, true )
        self.lookalike:SetMesh( ubp.Display.BuildEffect.PartArrivesByDropshipMesh, false )
        self.lookalike:SetDrawScale( ubp.Display.UniformScale or 1 )
        self.lookalike:AttachBoneTo(ubbBone, self, 'TractorFocus')
        self.TractorSlider:SetGoal(0,0,0)
        self.TractorSlider:SetSpeed(-1)

        -- hiding bone on the unit being build
        unitBeingBuilt:HideBone(ubbBone, true)

        -- additional effects
        self:CreateTractorBeamFx()

        self.PABD_progress = 0
        local prevProg = -2
        local ok = true
        while ok and self.PABD_progress < 10 do

            WaitTicks(1)

            -- checking current progress to determine the current state ---------------------------

            ok = (self and not self.Dead and unitBeingBuilt and not unitBeingBuilt.Dead)
            if not ok then
                self.PABD_progress = 99
            elseif self:GetWorkProgress() >= 1 or unitBeingBuilt:GetFractionComplete() >= 1 then
                self.PABD_progress = 9
            elseif self:GetWorkProgress() < 0.9 then
                self.PABD_progress = 0
            elseif self:GetWorkProgress() < 1 then
                self.PABD_progress = 1
            end

            -- handling that state ----------------------------------------------------------------

            -- Not using elseif on purpuse, in case the progress goes from 0 to 9 in 1 tick we still need to do all intermediate states

            if self.PABD_progress == prevProg then
                -- no need to do the same thing twice
                continue
            end

            if self.PABD_progress == 99 then
                -- something died. Stop this.
                --LOG('*DEBUG: xnb0304 something died.')

                self:DestroyPartArrivesByDropshipThread()
                break
            end

            if self.PABD_progress == 0 then
                -- wait till progressed far enough
                --LOG('*DEBUG: xnb0304 waiting till unit construction progress is far enough')
            end

            if self.PABD_progress == 1 or (prevProg < 1 and self.PABD_progress > 1) then
                -- start moving head to body
                --LOG('*DEBUG: xnb0304 move head to body')

                local FocusCurPos = self:GetPosition('TractorFocus')
                local TarPos = unitBeingBuilt:GetPosition(ubbBone)
                local SliderGoal = import('/lua/utilities.lua').GetDifferenceVector(FocusCurPos, TarPos)
                --LOG('*DEBUG: v1 = '..repr(FocusCurPos)..' v2 = '..repr(TarPos)..' d = '..repr(SliderGoal))

                self.TractorSlider:SetGoal( -SliderGoal[1], -SliderGoal[2], -SliderGoal[3] )
                self.TractorSlider:SetSpeed(0.5)
                WaitTicks(1)
                WaitFor(self.TractorSlider)
            end

            if self.PABD_progress == 9 then
                -- attach head to body
                --LOG('*DEBUG: xnb0304 attach head to body')

                unitBeingBuilt:ShowBone(ubbBone, true)
                self.lookalike:Destroy()
                self:DestroyTractorBeamFx()
                self.TractorSlider:SetGoal(0,0,0)
                self.TractorSlider:SetSpeed(-1)

                -- setting progress tracker to 10 to signal that we're done here
                self.PABD_progress = 10
                break
            end

            prevProg = self.PABD_progress
        end
    end,

    DestroyPartArrivesByDropshipThread = function(self)
        -- TODO: head explode effect?
        if self.PartArrivesByDropshipThreadHandle then
            KillThread( self.PartArrivesByDropshipThreadHandle )
        end
        self.lookalike:Destroy()
        self:DestroyTractorBeamFx()
        self.PABD_progress = 99
    end,

    CreateTractorBeamFx = function(self)
        self.TractorBeamBag:Add( AttachBeamEntityToEntity(self, 'Tractor1', self, 'TractorFocus', self.Army, NomadsEffectTemplate.SCUFactoryBeam) )
        self.TractorBeamBag:Add( AttachBeamEntityToEntity(self, 'Tractor2', self, 'TractorFocus', self.Army, NomadsEffectTemplate.SCUFactoryBeam) )
        self.TractorBeamBag:Add( AttachBeamEntityToEntity(self, 'Tractor3', self, 'TractorFocus', self.Army, NomadsEffectTemplate.SCUFactoryBeam) )
        self.TractorBeamBag:Add( AttachBeamEntityToEntity(self, 'Tractor4', self, 'TractorFocus', self.Army, NomadsEffectTemplate.SCUFactoryBeam) )

        for k, v in NomadsEffectTemplate.SCUFactoryBeamOrigin do
            self.TractorBeamBag:Add( CreateEmitterAtBone(self, 'Tractor1', self.Army, v) )
            self.TractorBeamBag:Add( CreateEmitterAtBone(self, 'Tractor2', self.Army, v) )
            self.TractorBeamBag:Add( CreateEmitterAtBone(self, 'Tractor3', self.Army, v) )
            self.TractorBeamBag:Add( CreateEmitterAtBone(self, 'Tractor4', self.Army, v) )
        end
        for k, v in NomadsEffectTemplate.SCUFactoryBeamEnd do
            self.TractorBeamBag:Add( CreateEmitterAtBone(self, 'TractorFocus', self.Army, v) )
        end
    end,

    DestroyTractorBeamFx = function(self)
        self.TractorBeamBag:Destroy()
    end,
}

TypeClass = XNB0304