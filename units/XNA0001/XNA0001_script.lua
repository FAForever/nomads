local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local Unit = import('/lua/sim/Unit.lua').Unit

XNA0001 = Class(Unit) {

    CoverLaunchFx = NomadsEffectTemplate.ACUMeteorCoverLaunch,
    CoverOpenFx = NomadsEffectTemplate.ACUMeteorCoverOpen,

    OnCreate = function(self)
        Unit.OnCreate(self)

        self.EventCallbacks = table.merged(self.EventCallbacks, {
            openup = {},
        })

        if self:GetBlueprint().Display.AnimationOpen then
            self.OpenAnimManip = CreateAnimator(self)
            self.Trash:Add(self.OpenAnimManip)
            self.OpenAnimManip:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(0)
            self:OpenUp()
        else
            self:DelayedDestroy()
        end
    end,

    AddOpenUpCallback = function(self, fn)
        -- fn -> function( <INA0001 instance>, <Opening anim state: opening|opened|expired>)
        self:AddUnitCallback(fn, 'openup')
    end,

    OpenUp = function(self)
        local fn = function(self)
            local bp = self:GetBlueprint()

            WaitTicks(10)

            if not self:IsUnderWater() then
                self:PlaySound(bp.Audio['Open'])
            end

            self:DoUnitCallbacks('openup', 'opening')
            self.OpenAnimManip:SetRate(2)
            self:PlayCoverOpenFx()
            WaitFor(self.OpenAnimManip)

            local CoverPos = self:GetPosition('Cover')
            local Cover = self:CreateProjectile('/effects/Entities/NomadsACUDropPodCover/NomadsACUDropPodCover_proj.bp')
            self.Trash:Add(Cover)
            Warp(Cover, CoverPos)
            Cover:Launch()

            self:PlayCoverLaunchFx(Cover)
            if not self:IsUnderWater() then
                self:PlaySound(bp.Audio['CoverLaunch'])
            end

            WaitTicks(1)
            self:HideBone('Cover', true)

            self:DoUnitCallbacks('openup', 'opened')
            WaitSeconds(10)
            self:DoUnitCallbacks('openup', 'expired')
            self:Destroy()
        end
        self:ForkThread(fn)
    end,

    IsUnderWater = function(self)
        -- since we're actually an air unit and we use trickery to appear under water a simple  call to GetCurrentLayer()
        -- always returns 'Air'. So using a workaround to determine if we're under water or not.
        local x,y,z = unpack(self:GetPosition())
        return (y < GetSurfaceHeight(x, z))
    end,

    PlayCoverOpenFx = function(self)
        local army = self:GetArmy()
        local emitters, emit = {}
        for k, v in self.CoverOpenFx do
            emit = CreateEmitterAtBone(self, 'Cover', army, v)
            table.insert(emitters, emit)
        end
        return emitters
    end,

    PlayCoverLaunchFx = function(self, CoverEnt)
        local army = self:GetArmy()
        local emitters, emit = {}
        for k, v in self.CoverLaunchFx do
            emit = CreateAttachedEmitter(CoverEnt, 0, army, v)
            table.insert(emitters, emit)
        end
        return emitters
    end,

    DelayedDestroy = function(self)
        local fn = function(self)
            WaitSeconds(5)
            self:Destroy()
        end
        self:ForkThread(fn)
    end,
}

TypeClass = XNA0001