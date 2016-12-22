do

local oldShield = Shield
Shield = Class(oldShield) {

    OnState = State(oldShield.OnState) {
        Main = function(self)

            -- If the shield was turned off; use the recharge time before turning back on
            if self.OffHealth >= 0 then
                self.Owner:SetMaintenanceConsumptionActive()
                self:ChargingUp(0, self.ShieldEnergyDrainRechargeTime)

                -- If the shield has less than full health, allow the shield to begin regening
                if self:GetHealth() < self:GetMaxHealth() and self.RegenRate > 0 then
                    self.RegenThread = ForkThread(self.RegenStartThread, self)
                    self.Owner.Trash:Add(self.RegenThread)
                end
            end

            -- We are no longer turned off
            self.OffHealth = -1
            
            self:UpdateShieldRatio(-1)
            self:CreateShieldMesh()
            
            --Code for Personal Bubbles, currently only the Harbinger
            local OwnerBp = self.Owner:GetBlueprint()
            local OwnerShield = OwnerBp.Defense.Shield
            if OwnerShield.PersonalBubble and OwnerShield.PersonalBubble == true then
                self.Owner:SetCollisionShape('Sphere', 0, OwnerBp.SizeY * 0.5, 0, OwnerShield.ShieldSize * 0.5)
                --Manually disable the bubble shield's collision sphere after its creation so it acts like the new personal shields
                self:SetCollisionShape('None')
            end
            
            self.Owner:PlayUnitSound('ShieldOn')
            self.Owner:SetMaintenanceConsumptionActive()
            
            --Then we can make any units inside a transport with a Shield invulnerable here
            self:ProtectTransportedUnits()

            local aiBrain = self.Owner:GetAIBrain()

            WaitSeconds(1.0)
            local fraction = self.Owner:GetResourceConsumed()
            local on = true
            local test = false

            -- Test in here if we have run out of power; if the fraction is ever not 1 we don't have full power
            while on do
                WaitTicks(1)

                self:UpdateShieldRatio(-1)

                fraction = self.Owner:GetResourceConsumed()

# TODO: See if this is necessary. Added after watching FAF replay 1957910, after 35 minutes or so 3 harbs become invincible.
# Sometimes shields stay on when there's no power to run them. This change should fix that.
#                if fraction != 1 and aiBrain:GetEconomyStored('ENERGY') <= 0 then
if fraction != 1 and aiBrain:GetEconomyStored('ENERGY') < 1 then

                    if test then
                        on = false
                    else
                        test = true
                    end
                else
                    on = true
                    test = false
                end
            end

            -- Record the amount of health on the shield here so when the unit tries to turn its shield
            -- back on and off it has the amount of health from before.
            --self.OffHealth = self:GetHealth()
            ChangeState(self, self.EnergyDrainRechargeState)
        end,
    },
}

end