local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local Prop = import('/lua/sim/Prop.lua').Prop

-- Redone the trees quite significantly. This is necessary because the original tree prop was pretty cursed, and this one has a lot better mod support
-- Sadly this means the prop is overwritten pretty much.
-- We no longer use states, instead using a table of OnDamage functions, and also this means we can control what happens to the trees more.
-- For instance we handle burning and falling separately so a tree can be in both "states" at once. Also, mods can mod/add damage types and behaviours super easily now.
local oldTree = Tree

--call with: DamageBehaviours[damageType](self, instigator, armormod, direction, damageType)
DamageBehaviours = {
        BlackholeDamage = function(self, instigator, armormod, direction, damageType)
            if not self.CanTakeDamage then return end
            self:DoBlackHoleCallbacks(self, instigator)
            
            --call the standard nuke code, which destroys the prop
            DamageBehaviours['Nuke'](self, instigator, armormod, direction, damageType)
        end,
        
        Nuke = function(self, instigator, armormod, direction, damageType)
            local templ = NomadsEffectTemplate.TreeDisintegrate
            if self.Fallen then templ = NomadsEffectTemplate.FallenTreeDisintegrate end
            for k, v in templ do
                CreateEmitterAtBone(self, 0, -1, v) -- the effects must have a limited life...
            end
            
            --disintegrate the tree
            DamageBehaviours['Disintegrate'](self, instigator, armormod, direction, damageType)
        end,
        
        Disintegrate = function(self, instigator, armormod, direction, damageType)
            self.Burning = false
            self:DestroyFireEffects()
            self:Destroy()
        end,
        
        --Force
        
        Force = function(self, instigator, armormod, direction, damageType)
            if self.Fallen then return end --TODO: change this so it disappears if damaged again?
            self:FallOver(direction, 1, true)
        end,
        
        ForceInwards = function(self, instigator, armormod, direction, damageType)
            direction = -direction[1], direction[2], -direction[3]
            DamageBehaviours['Force'](self, instigator, armormod, direction, damageType)
        end,
        
        --Fire
        
        Fire = function(self, instigator, armormod, direction, damageType)
            if self.Burning then return end
            self.Burning = true
            self.BigFireFx = (damageType == 'BigFire')
            self:PlayFireEffects()
        end,
        
        ForestFire = function(self, instigator, armormod, direction, damageType)
            if self.Burning or (Random(1, 5) > 1) then return end
            DamageBehaviours['Fire'](self, instigator, armormod, direction, damageType)
        end,
        
        Generic = function(self, instigator, armormod, direction, damageType)
        end,
}

--set up duplicate functions
DamageBehaviours.BlackholeDeathNuke = DamageBehaviours.BlackholeDamage
DamageBehaviours.Deathnuke = DamageBehaviours.Nuke
DamageBehaviours.BigFire = DamageBehaviours.Fire
DamageBehaviours.ExperimentalFootfall = DamageBehaviours.Force -- knock over trees by exp footsteps

Tree = Class(oldTree) {
    
    OnCreate = function(self)
        oldTree.OnCreate(self)
        self.Fallen = false
        self.Burning = false
        self.BurnTime = Random(10, 30)
    end,

    OnCollision = function(self, other, nx, ny, nz, depth)
        local direction = {nx, ny, nz}
        self:PlayUprootingEffect(other)
        
        local otherbp = other:GetBlueprint()
        local is_big = (otherbp.SizeX * otherbp.SizeZ) > 0.2
        if is_big then
            self:FallOver(direction, depth, true)
        else
            self:FallOver(direction, 0.05, false)
        end
    end,

    OnDamage = function(self, instigator, armormod, direction, type)
        if DamageBehaviours[type] then
            if self.Fallen and (not self:DamageIsForce(type) and Random(1, 4) <= 1) then --a chance that fallen trees are destroyed
                DamageBehaviours['Nuke'](self, instigator, armormod, direction, type)
            else
                DamageBehaviours[type](self, instigator, armormod, direction, type)
            end
        elseif Random(1, 8) <= 1 then --a chance to destroy trees when they get damaged by regular AOE
            DamageBehaviours['Fire'](self, instigator, armormod, direction, type)
        elseif Random(1, 8) <= 1 then --a chance to knock over trees when they get damaged by regular AOE
            DamageBehaviours['Force'](self, instigator, armormod, direction, type)
        end
    end,
    
    FallOver = function(self, direction, speed, toggle)
        self.Fallen = true
        
        self.Motor = self.Motor or self:FallDown()
        self.Motor:Whack(direction[1], direction[2], direction[3], speed or 1, toggle or true)
        self:SetMesh(self:GetBlueprint().Display.MeshBlueprintWrecked)
        
        self:ForkThread(self.FallenTreeThread)
    end,
    
    FallenTreeThread = function(self)
        WaitSeconds(30)
        self:SinkAway(-.1)
        self.Motor = nil
        WaitSeconds(10)
        self:Destroy()
    end,
    
    DoBlackHoleCallbacks = function(self, instigator)
        if not self.BlackholeSuckedIn then
            self.BlackholeSuckedIn = true
            instigator.NukeEntity:OnPropBeingSuckedIn(self)
            self:DestroyFireEffects()  -- fire < black hole
        end
    end,

    DamageIsForce = function(self, type)
        return (type == 'Force' or type == 'ForceInwards' or type == 'ExperimentalFootfall') -- exp footfall so the trees fall by steps from experimentals
    end,

    PlayFireEffects = function(self, initialScale, curveParam)
        if self.BurnTime <= 0 then return end

        if self.FireEffectsThread then
            KillThread(self.FireEffectsThread)
            self:DestroyFireEffects()
        end

        if not initialScale or initialScale <= 0 then initialScale = 1 end
        if not curveParam or curveParam <= 0 then curveParam = 2 end
        self.FireEffects = self.FireEffects or {}

        local templ = NomadsEffectTemplate.TreeFire
        if self.BigFireFx and self.Fallen then
            templ = NomadsEffectTemplate.FallenTreeBigFire
        elseif self.BigFireFx then
            templ = NomadsEffectTemplate.TreeBigFire
        elseif self.Fallen then
            templ = NomadsEffectTemplate.FallenTreeFire
        end
        
        --self:SetMesh(self:GetBlueprint().Display.MeshBlueprintWrecked) --not working for some reason here?
        local fn = function(self, templ, initialScale, curveParam)
            local scale, frac, curve, dmgTime, emit = initialScale, 1, 1, 1
            self:PlayPropSound('BurnStart')
            self:PlayPropAmbientSound('BurnLoop')

            for k, v in templ do
                emit = CreateAttachedEmitter(self, 0, -1, v):ScaleEmitter(scale)
                table.insert(self.FireEffects, emit)
                self.Trash:Add(emit)
            end

            if not self.ScorchMarkCreated then
                self.ScorchMarkCreated = true
                DefaultExplosions.CreateScorchMarkSplat(self, 0.5, -1)
            end

            for i = self.BurnTime,1,-1 do
                frac = i / self.BurnTime
                curve = (-curveParam * math.pow(frac, 2)) + (curveParam * frac) + 1
                scale = initialScale * frac * curve
                for k, v in self.FireEffects do
                    v:ScaleEmitter(scale)
                end
                WaitSeconds(1)
            end
            
            self:PlayPropAmbientSound(nil)

            for k, v in self.FireEffects do
                v:Destroy()
            end
            
            --topple some trees after theyre done burning
            local randomF = GetRandomFloat(-1, 1)
            if randomF < -0.5 then
                local direction = {randomF, 0, GetRandomFloat(-1, 1)}
                self:FallOver(direction, 0.05, true)
            end
            self:PlayAfterFireEffects()
        end

        self.FireEffectsThread = self:ForkThread(fn, templ, initialScale, curveParam)
    end,

    DestroyFireEffects = function(self)
        if self.FireEffectsThread then
            KillThread(self.FireEffectsThread)
        end
        if self.FireEffects then
            for k, v in self.FireEffects do
                v:Destroy()
            end
        end
    end,

    PlayAfterFireEffects = function(self)
        if not self.PlayingAfterFireEffects then
            self.PlayingAfterFireEffects = true
            if Random(1, 10) <= 6 then
                local lifetime = Random(200, 500)
                for k, v in NomadsEffectTemplate.TreeAfterFireEffects do  -- these effects should have a limited life...
                    CreateEmitterAtEntity(self, -1, v):SetEmitterParam('LIFETIME', lifetime)
                end
            end
        end
    end,
}


local oldTreeGroup = TreeGroup
TreeGroup = Class(TreeGroup) {
    OnDamage = function(self, instigator, armormod, direction, type)
        -- making all new damage types break up the tree group so each tree properly handles the damage type
        if type == 'ForceInwards' or type == 'Fire' or type == 'BigFire' then
            self:Breakup()
        else
            oldTreeGroup.OnDamage(self, instigator, armormod, direction, type)
        end
    end,
}
