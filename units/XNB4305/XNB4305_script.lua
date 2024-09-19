local NShieldStructureUnit = import('/lua/nomadsunits.lua').NShieldStructureUnit

--- Tech 3 Shield & Stealth Field Generator
---@class XNB4305 : NShieldStructureUnit
XNB4305 = Class(NShieldStructureUnit) {
    ShieldEffects = {
        '/effects/Entities/Shield05/Shield05d_emit.bp',
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

    RotationSpeed = 100,

    ---@param self XNB4305
    OnCreate = function(self)
        NShieldStructureUnit.OnCreate(self)
        self.UpgrAnim = CreateAnimator(self):PlayAnim('/units/XNB4301/XNB4301_UpgradeToT3Stlth.sca')
        self.UpgrAnim:SetRate(0):SetAnimationFraction(1)
        self.Trash:Add(self.UpgrAnim)
        self.ShieldEffectsBag = {}
    end,

    ---@param self XNB4305
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

    ---@param self XNB4305
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

TypeClass = XNB4305