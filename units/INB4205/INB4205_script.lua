-- T2 shield generator + stealth field generator

local NShieldStructureUnit = import('/lua/nomadunits.lua').NShieldStructureUnit

INB4205 = Class(NShieldStructureUnit) {

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
    end,
}

TypeClass = INB4205