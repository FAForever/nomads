local oldXSL0001 = XSL0001

XSL0001 = Class(oldXSL0001) {
    CreateEnhancement = function(self, enh)
        oldXSL0001.CreateEnhancement(self, enh)

    if enh =='Missile' then
            self:GetBlueprint().SpecialAbilities.LaunchTacMissile.Enabled = true
        self:RegisterSpecialAbilities()
    elseif enh == 'MissileRemove' then
            self:GetBlueprint().SpecialAbilities.LaunchTacMissile.Enabled = false
        self:UnregisterSpecialAbilities()
        end
    end
}

TypeClass = XSL0001
