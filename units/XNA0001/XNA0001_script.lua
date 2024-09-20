local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local Unit = import('/lua/sim/Unit.lua').Unit

---@class XNA0001 : Unit
XNA0001 = Class(Unit) {

    CoverLaunchFx = NomadsEffectTemplate.ACUMeteorCoverLaunch,
    CoverOpenFx = NomadsEffectTemplate.ACUMeteorCoverOpen,

    ---@param self XNA0001
    OnCreate = function(self)
        Unit.OnCreate(self)

        local bp = self.Blueprint

        self.EventCallbacks = table.merged(self.EventCallbacks, {openup = {} })

        if bp.Display.AnimationOpen then
            self.OpenAnimManip = CreateAnimator(self)
            self.Trash:Add(self.OpenAnimManip)
            self.OpenAnimManip:PlayAnim(bp.Display.AnimationOpen, false):SetRate(0)
            self:OpenUp()
        else
            self:DelayedDestroy()
        end
    end,

    ---@param self XNA0001
    ---@param fn fun(instance: XNA0001, animationState: "opening" | "opened" | "expired")
    AddOpenUpCallback = function(self, fn)
        self:AddUnitCallback(fn, 'openup')
    end,

    ---@param self XNA0001
    OpenUp = function(self)
        local fn = function(self)
            local bp = self.Blueprint

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
        self.Trash:Add(ForkThread(fn,self))
    end,

    ---@param self XNA0001
    IsUnderWater = function(self)
        -- since we're actually an air unit and we use trickery to appear under water a simple  call to GetCurrentLayer()
        -- always returns 'Air'. So using a workaround to determine if we're under water or not.
        local x,y,z = unpack(self:GetPosition())
        return (y < GetSurfaceHeight(x, z))
    end,

    ---@param self XNA0001
    PlayCoverOpenFx = function(self)
        local emitters, emit = {}
        for k, v in self.CoverOpenFx do
            emit = CreateEmitterAtBone(self, 'Cover', self.Army, v)
            table.insert(emitters, emit)
        end
        return emitters
    end,

    ---@param self XNA0001
    ---@param CoverEnt Entity
    ---@return moho.IEffect[]
    PlayCoverLaunchFx = function(self, CoverEnt)
        local emitters, emit = {}
        for k, v in self.CoverLaunchFx do
            emit = CreateAttachedEmitter(CoverEnt, 0, self.Army, v)
            table.insert(emitters, emit)
        end
        return emitters
    end,

    ---@param self XNA0001
    DelayedDestroy = function(self)
        local fn = function(self)
            WaitSeconds(5)
            self:Destroy()
        end
        self.Trash:Add(ForkThread(fn,self))
    end,
}
TypeClass = XNA0001