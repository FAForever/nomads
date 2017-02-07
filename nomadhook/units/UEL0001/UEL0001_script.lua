local oldUEL0001 = UEL0001

UEL0001 = Class(oldUEL0001) {
	CreateEnhancement = function(self, enh)
		oldUEL0001.CreateEnhancement(self, enh)

		if enh =='TacticalMissile' then
			LOG('Tac Missile Attached')
			self:GetBlueprint().SpecialAbilities.LaunchTacMissile.NoAutoEnable = false
			self:RegisterSpecialAbilities()
        elseif enh == 'TacticalNukeMissile' then
			LOG('Billy Attached')
			self:RegisterSpecialAbilities()
		elseif enh == 'TacticalMissileRemove' or enh == 'TacticalNukeMissileRemove' then
			LOG('Tac or Billy Removed')
			self:GetBlueprint().SpecialAbilities.LaunchTacMissile.NoAutoEnable = true
			self:UnregisterSpecialAbilities()
        end
    end
}

TypeClass = UEL0001