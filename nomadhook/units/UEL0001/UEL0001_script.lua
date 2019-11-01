local oldUEL0001 = UEL0001

UEL0001 = Class(oldUEL0001) {
    CreateEnhancement = function(self, enh)
        oldUEL0001.CreateEnhancement(self, enh)

        if enh =='TacticalMissile' then
            self:GetAIBrain():SetUnitSpecialAbility(self, 'LaunchTacMissile', {Enabled = true})
        elseif enh == 'TacticalNukeMissile' then
            self:GetAIBrain():SetUnitSpecialAbility(self, 'LaunchTacMissile', {Enabled = false})
        elseif enh == 'TacticalMissileRemove' then
            self:GetAIBrain():SetUnitSpecialAbility(self, 'LaunchTacMissile', {Enabled = false})
        end
    end
}

TypeClass = UEL0001
