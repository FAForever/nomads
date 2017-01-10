-- T3 shield generator

local NShieldStructureUnit = import('/lua/nomadunits.lua').NShieldStructureUnit

INB4301 = Class(NShieldStructureUnit) {

    RotationSpeed = 18,

    OnCreate = function(self)
        NShieldStructureUnit.OnCreate(self)
        self.UpgrAnim = CreateAnimator(self):PlayAnim('/units/INB4301/INB4301_UpgradeFromT2Std.sca')
        self.UpgrAnim:SetRate(0):SetAnimationFraction(1)
        self.Trash:Add(self.UpgrAnim)
    end,

    UpgradingState = State(NShieldStructureUnit.UpgradingState) {
        -- having 2 animations manipulating the arms is no good. Disabling the above anim if we're upgrading to stealth.

        Main = function(self)
            local bp = self:GetBlueprint().Display
            if bp.AnimationUpgrade and self.UpgrAnim then
                self.UpgrAnim:SetAnimationFraction(0)
            end

            NShieldStructureUnit.UpgradingState.Main(self)

            if bp.AnimationUpgrade and self.UpgrAnim then
                self.UpgrAnim:SetAnimationFraction(1)
            end
        end,

        OnFailedToBuild = function(self)
            NShieldStructureUnit.UpgradingState.OnFailedToBuild(self)

            local bp = self:GetBlueprint().Display
            if bp.AnimationUpgrade and self.UpgrAnim then
                self.UpgrAnim:SetAnimationFraction(1)
            end
        end,
    }
}

TypeClass = INB4301