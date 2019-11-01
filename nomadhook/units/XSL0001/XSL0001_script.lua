local oldXSL0001 = XSL0001

XSL0001 = Class(oldXSL0001) {
    CreateEnhancement = function(self, enh)
        oldXSL0001.CreateEnhancement(self, enh)

        if enh =='Missile' then
            self:GetAIBrain():SetUnitSpecialAbility(self, 'LaunchTacMissile', {Enabled = true})
        elseif enh == 'MissileRemove' then
            self:GetAIBrain():SetUnitSpecialAbility(self, 'LaunchTacMissile', {Enabled = false})
        end
    end
}

TypeClass = XSL0001
