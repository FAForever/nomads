local oldUEL0001 = UEL0001

UEL0001 = Class(oldUEL0001) {
    CreateEnhancement = function(self, enh)
        oldUEL0001.CreateEnhancement(self, enh)

    if enh =='TacticalMissile' then
        self:GetBlueprint().SpecialAbilities.LaunchTacMissile.NoAutoEnable = false
        self:RegisterSpecialAbilities()
    elseif enh == 'TacticalNukeMissile' then
            self:GetBlueprint().SpecialAbilities.LaunchTacMissile.NoAutoEnable = true
            self:UnregisterSpecialAbilities()
    elseif enh == 'TacticalMissileRemove' then
        self:GetBlueprint().SpecialAbilities.LaunchTacMissile.NoAutoEnable = true
        self:UnregisterSpecialAbilities()
        end
    end
}

TypeClass = UEL0001
