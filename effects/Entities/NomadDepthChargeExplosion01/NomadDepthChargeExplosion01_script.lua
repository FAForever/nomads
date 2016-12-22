local Entity = import('/lua/sim/Entity.lua').Entity

NomadDepthChargeExplosion01 = Class(Entity) {

    OnCreate = function(self, spec)
        Entity.OnCreate(self, spec)

        if not self.Trash then
            self.Trash = TrashBag()
        end

        Warp(self, spec.Position)
        self:CreateEffects()
    end,

    OnDestroy = function(self)
        self.Trash:Destroy()
        Entity.OnDestroy(self)
    end,

    CreateEffects = function(self)
        local fn = function(self)
            local lifetime = 1
            local scale = self.Spec.Scale or 5
            local scaleDec = scale / lifetime
            self:SetMesh('/effects/Entities/NomadDepthChargeExplosion01/NomadDepthChargeExplosion01_mesh')
            self:SetDrawScale(self.Spec.Scale or 5)
            self:SetVizToAllies('Intel')
            self:SetVizToNeutrals('Intel')
            self:SetVizToEnemies('Intel')
            for i = 1, lifetime do
                WaitTicks(1)
                scale = math.max(0, scale - scaleDec)
                self:SetDrawScale(scale)
            end
            self:Destroy()
        end
        self:ForkThread(fn)
    end,

    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,
}
