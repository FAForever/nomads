# an energy proj based on EnergyProj1 but with smaller effects

local NEnergyProj1 = import('/projectiles/NEnergyProj1/NEnergyProj1_script.lua').NEnergyProj1

NEnergyProj2 = Class(NEnergyProj1) {
    OnCreate = function(self)
        # adjust scale of original projectile
        local scale = 0.5
        self.FxNoneHitScale = scale * (self.FxNoneHitScale or 1)
        self.FxWaterHitScale = scale * (self.FxWaterHitScale or 1)
        self.FxUnderWaterHitScale = scale * (self.FxUnderWaterHitScale or 1)
        self.FxUnitHitScale = scale * (self.FxUnitHitScale or 1)
        self.FxAirUnitHitScale = scale * (self.FxAirUnitHitScale or 1)
        self.FxLandHitScale = scale * (self.FxLandHitScale or 1)
        self.FxProjectileHitScale = scale * (self.FxProjectileHitScale or 1)
        self.FxProjectileUnderWaterHitScale = scale * (self.FxProjectileUnderWaterHitScale or 1)
        self.FxPropHitScale = scale * (self.FxPropHitScale or 1)
        self.FxShieldHitScale = scale * (self.FxShieldHitScale or 1)
        NEnergyProj1.OnCreate(self)
    end,
}

TypeClass = NEnergyProj2
