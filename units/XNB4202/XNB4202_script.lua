local NShieldStructureUnit = import('/lua/nomadsunits.lua').NShieldStructureUnit

--- Tech 2 Shield Generator
---@class XNB4202 : NShieldStructureUnit
XNB4202 = Class(NShieldStructureUnit) {
    ShieldEffects = {
        '/effects/Entities/Shield05/Shield05_emit.bp',
    },

    ---@param self XNB4202
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        NShieldStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self.ShieldEffectsBag = {}
    end,

    ---@param self XNB4202
    OnShieldEnabled = function(self)
        NShieldStructureUnit.OnShieldEnabled(self)
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
            self.ShieldEffectsBag = {}
        end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'shield', self.Army, v ):ScaleEmitter(0.75) )
        end
    end,

    ---@param self XNB4202
    OnShieldDisabled = function(self)
        NShieldStructureUnit.OnShieldDisabled(self)
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
            self.ShieldEffectsBag = {}
        end
    end,
}
TypeClass = XNB4202