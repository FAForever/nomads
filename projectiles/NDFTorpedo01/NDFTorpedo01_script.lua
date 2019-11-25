local NDFAmphibiousMissile = import('/lua/nomadsprojectiles.lua').NDFAmphibiousMissile

NDFTorpedo01 = Class(NDFAmphibiousMissile) {
    OnCreate = function(self, inWater)
        NDFAmphibiousMissile.OnCreate(self)
        local target = self:GetTrackingTarget()
        if target and IsBlip(target) then target = target:GetSource() end
        
        if target and IsUnit(target) then
            local layer = target:GetCurrentLayer()
            if layer == 'Water' or layer == 'Seabed' or layer == 'Sub' then
                self:ForkThread(self.PassDamageThread)
            end
        end
        
    end,

    PassDamageThread = function(self)
        local bp = self:GetLauncher():GetBlueprint().Weapon
        WaitSeconds(0.1)
        self.DamageData.DamageAmount = bp[1].DamageWater or 100
        self.DamageData.DamageRadius = bp[1].DamageRadiusWater or 0
    end,
}

TypeClass = NDFTorpedo01