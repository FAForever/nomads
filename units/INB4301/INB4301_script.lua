-- T3 shield generator

local NShieldStructureUnit = import('/lua/nomadsunits.lua').NShieldStructureUnit

INB4301 = Class(NShieldStructureUnit) {
    ShieldEffects = {
        '/effects/Entities/Shield05/Shield05c_emit.bp',
    },

    RotationSpeed = 18,

    OnCreate = function(self)
        NShieldStructureUnit.OnCreate(self)
        self.UpgrAnim = CreateAnimator(self):PlayAnim('/units/INB4301/INB4301_UpgradeFromT2Std.sca')
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