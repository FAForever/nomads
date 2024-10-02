local Entity = import('/lua/sim/Entity.lua').Entity

---@class NomadsDepthChargeExplosion01 : Entity
NomadsDepthChargeExplosion01 = Class(Entity) {

    ---@param self NomadsDepthChargeExplosion01
    ---@param spec any
    OnCreate = function(self, spec)
        Entity.OnCreate(self, spec)

        if not self.Trash then
            self.Trash = TrashBag()
        end

        Warp(self, spec.Position)
        self:CreateEffects()
    end,

    ---@param self NomadsDepthChargeExplosion01
    OnDestroy = function(self)
        self.Trash:Destroy()
        Entity.OnDestroy(self)
    end,

    ---@param self NomadsDepthChargeExplosion01
    CreateEffects = function(self)
        local fn = function(self)
            local lifetime = 1
            local scale = self.Spec.Scale or 5
            local scaleDec = scale / lifetime
            self:SetMesh('/effects/Entities/NomadsDepthChargeExplosion01/NomadsDepthChargeExplosion01_mesh')
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

    ---@param self NomadsDepthChargeExplosion01
    ---@param fn any
    ---@param ... unknown
    ---@return thread
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
