do


local NomadsShieldChanges = function(SuperClass)
    return Class(SuperClass) {
    
    --TODO:Remove this once Relevant PR is merged
    OnCreate = function(self, spec)
        SuperClass.OnCreate(self, spec)
        self.Army = self:GetArmy()
    end,

    OnDamage =  function(self,instigator,amount,vector,type)
        -- experimental footfall damage shouldn't damage the shield. This type of damage is also done by hover experimentals such as the crawler
        if type ~= 'ExperimentalFootfall' then
            SuperClass.OnDamage(self, instigator, amount, vector, type)
        end
    end,

    CollapseShield = function(self, instigator)
        ChangeState(self, self.EnergyDrainedState)
    end,

    CreateImpactEffect = function(self, vector)
        if self:IsOn() then
            SuperClass.CreateImpactEffect(self, vector)
        end
    end,

    RegenStartThread = function(self)
        if self:IsOn() then
            SuperClass.RegenStartThread(self)
        end
    end,

} end


Shield = NomadsShieldChanges(Shield)
AntiArtilleryShield = NomadsShieldChanges(AntiArtilleryShield)


end