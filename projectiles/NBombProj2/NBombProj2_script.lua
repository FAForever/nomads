local ConcussionBomb = import('/lua/nomadsprojectiles.lua').ConcussionBomb
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

-- Coded to only split up if NumFragments is passed to the projectile

NBombProj2 = Class(ConcussionBomb) {

    OnCreate = function(self)
        ConcussionBomb.OnCreate(self)
        self.FragmentSpread = 0.7
    end,

    PassDamageData = function(self, DamageData)
        ConcussionBomb.PassDamageData(self, DamageData)
        self.FragmentSpread = DamageData.FragmentSpread
        if not self.DamageData.NumFragments or self.DamageData.NumFragments <= 1 then
            self:ChangeDetonateBelowHeight( 0 )
        end
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        -- if these parameters are nil then we detonate because we're below a certain height, see BP
        if TargetType == 'Air' and not TargetEntity and self.DamageData.NumFragments and self.DamageData.NumFragments > 1 then
            self:Split()
        else
            ConcussionBomb.OnImpact(self, TargetType, TargetEntity)
        end
    end,

    Split = function(self)

        local ChildProjectileBP = '/projectiles/NBombProj2Child/NBombProj2Child_proj.bp'
        local numProjectiles = self.DamageData.NumFragments or 1

        -- split damage between projectiles
        self.DamageData.DamageAmount = self.DamageData.DamageAmount / numProjectiles

        -- Split effects
        for k, v in NomadsEffectTemplate.ConcussionBombSplit do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end

        local vx, vy, vz = self:GetVelocity()
        local velocity = 9

        -- One initial projectile following same directional path as the original
        local child = self:CreateChildProjectile(ChildProjectileBP)
        child:SetVelocity(vx, vy, vz)
        child:SetVelocity(velocity)
        child:PassDamageData(self.DamageData)

        numProjectiles = numProjectiles - 1  -- already created one

        if numProjectiles > 0 then

            -- Create several other projectiles in a dispersal pattern
            local angle = (2*math.pi) / numProjectiles
            local angleInitial = RandomFloat( 0, angle )

            -- Randomization of the spread
            local angleVariation = angle * 0.75 -- Adjusts angle variance spread
            local spreadMul = self.FragmentSpread or 1 -- Adjusts the width of the dispersal

            local xVec = vx
            local yVec = vy
            local zVec = vz

            -- Launch projectiles at semi-random angles away from split location. NumProjs minus 2 iso 1 because we already made a
            -- child proj.
            for i = 0, (numProjectiles - 1) do
                xVec = vx + (math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
                zVec = vz + (math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
                local proj = self:CreateChildProjectile(ChildProjectileBP)
                proj:SetVelocity(xVec,yVec,zVec)
                proj:SetVelocity(velocity)
                proj:PassDamageData(self.DamageData)
            end
        end

        self:Destroy()
    end,
}

TypeClass = NBombProj2
