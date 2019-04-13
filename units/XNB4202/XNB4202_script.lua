-- T2 shield generator

local NShieldStructureUnit = import('/lua/nomadsunits.lua').NShieldStructureUnit

XNB4202 = Class(NShieldStructureUnit) {
    ShieldEffects = {
        '/effects/Entities/Shield05/Shield05_emit.bp',
    },

    OnStopBeingBuilt = function(self,builder,layer)
        NShieldStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self.ShieldEffectsBag = {}
    end,

    OnShieldEnabled = function(self)
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
            self.ShieldEffectsBag = {}
        end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'shield', self:GetArmy(), v ):ScaleEmitter(0.75) )
        end
    end,

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