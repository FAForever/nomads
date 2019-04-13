-- T2 shield generator + stealth field generator

local NShieldStructureUnit = import('/lua/nomadsunits.lua').NShieldStructureUnit

XNB4205 = Class(NShieldStructureUnit) {
    ShieldEffects = {
        '/effects/Entities/Shield05/Shield05b_emit.bp',
    },

    IntelEffects = {
        {
            Bones = {
                'shield',
            },
            Offset = { 0, 0, 0, },
            Type = 'Jammer01',
        },
    },

    RotationSpeed = 30,

    OnCreate = function(self)
        NShieldStructureUnit.OnCreate(self)
        self.UpgrAnim = CreateAnimator(self):PlayAnim('/units/INB4301/INB4301_UpgradeToT2Stlth.sca')
        self.UpgrAnim:SetRate(0):SetAnimationFraction(1)
        self.Trash:Add(self.UpgrAnim)
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

TypeClass = XNB4205