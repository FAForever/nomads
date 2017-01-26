-- T3 stealth + shield generator

local NShieldStructureUnit = import('/lua/nomadsunits.lua').NShieldStructureUnit

INB4305 = Class(NShieldStructureUnit) {

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

    OnCreate = function(self)
        NShieldStructureUnit.OnCreate(self)
        self.UpgrAnim = CreateAnimator(self):PlayAnim('/units/INB4301/INB4301_UpgradeToT3Stlth.sca')
        self.UpgrAnim:SetRate(0):SetAnimationFraction(1)
        self.Trash:Add(self.UpgrAnim)
    end,
}

TypeClass = INB4305