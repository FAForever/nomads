do

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local Prop = import('/lua/sim/Prop.lua').Prop

local RemoveDamagedTrees = false


-- Redone the trees quite significantly. This may be a bit destructive but else I couldn't get the trees working like I wanted.

local oldTree = Tree
Tree = Class(oldTree) {

    OnCreate = function(self)
        oldTree.OnCreate(self)
        self.Fallen = false
        self.Burning = false
        self.BurnTime = Random(10, 30)
        ChangeState(self, self.UprightState)
    end,

    OnCollision = function(self, other, nx, ny, nz, depth)
        self:StateVariable( {nx, ny, nz} )
        self:PlayUprootingEffect(other)
        ChangeState(self, self.FallingOutwardsState)
    end,

    OnDamage = function(self, instigator, armormod, direction, type)
        self:CheckForBlackHoleDamage(instigator, type)
    end,

    OnBlackHoleSuckingIn = function(self, blackhole)
        oldTree.OnBlackHoleSuckingIn(self, blackhole)
        self:DestroyFireEffects()  -- fire < black hole
    end,

    CheckForBlackHoleDamage = function(self, instigator, type)
        if self:BlackhHoleCanPropSuckIn() then
            if type == 'BlackholeDamage' or type == 'BlackholeDeathNuke' then
                if not self.BlackholeSuckedIn then
                    self.BlackholeSuckedIn = true
                    instigator:OnPropBeingSuckedIn( self )
                end
            end
        end
    end,

    UprightState = State {
        Main = function(self)
            self.Burning = false
            self:DestroyFireEffects()
        end,

        OnDamage = function(self, instigator, armormod, direction, type)
            if self:DamageIsForce(type) then

                if GetGameTimeSeconds() < 10 then  -- game start, trees should be gone where ACU spawns
                    ChangeState(self, self.ObliteratedState)

                else
                    self:StateVariable(direction)
                    if type == 'ForceInwards' then
                        ChangeState(self, self.FallingInwardsState)
                    else
                        ChangeState(self, self.FallingOutwardsState)
                    end
                end

            elseif self:DamageIsFire(type) then
                if not self.Burning and (type ~= 'ForestFire' or Random(1, 5) <= 1) then
                    self.Burning = true
                    self.BigFireFx = (type == 'BigFire')
                    self:PlayFireEffects()
                end

            elseif self:DamageIsDisintegrate(type) then
                ChangeState(self, self.DisintegrateState)

            elseif self:DamageIsObliterate() or Random(1, 8) <= 1 then
                ChangeState(self, self.ObliteratedState)

            end

            self:CheckForBlackHoleDamage(instigator, type)
        end,
    },

    FallenState = State {
        Main = function(self)
            self.Fallen = true
            self.Burning = false
            self:DestroyFireEffects()
            if RemoveDamagedTrees then
                WaitSeconds(30)
                self:Disappear()
            end
        end,

        OnDamage = function(self, instigator, armormod, direction, type)
            if self:DamageIsFire(type) then
                if not self.Burning and (type ~= 'ForestFire' or Random(1, 3) <= 1) then
                    self.Burning = true
                    self.BigFireFx = (type == 'BigFire')
                    self:PlayFireEffects()
                end

            elseif self:DamageIsDisintegrate(type) then
                ChangeState(self, self.DisintegrateState)

            elseif self:DamageIsObliterate() or (not self:DamageIsForce(type) and Random(1, 4) <= 1) then
                ChangeState(self, self.ObliteratedState)
            end

            self:CheckForBlackHoleDamage(instigator, type)
        end,
    },

    FallingInwardsState = State {
        Main = function(self)
            local direction = self:StateVariable()
            self.Motor = self.Motor or self:FallDown()
            self.Motor:Whack(-direction[1], direction[2], -direction[3], 1, true)
            self:SetMesh(self:GetBlueprint().Display.MeshBlueprintWrecked)
            ChangeState(self, self.FallenState)
        end,
    },

    FallingOutwardsState = State {
        Main = function(self)
            local direction = self:StateVariable()
            self.Motor = self.Motor or self:FallDown()
            self.Motor:Whack(direction[1], direction[2], direction[3], 1, true)
            self:SetMesh(self:GetBlueprint().Display.MeshBlueprintWrecked)
            ChangeState(self, self.FallenState)
        end,
    },

    SinkingState = State {
        Main = function(self)
            self.Burning = false
            self:DestroyFireEffects()
            if not self.Motor then
                self.Motor = self.Motor or self:FallDown()
            end
            self:SinkAway(-.1)
            self.Motor = nil
            WaitSeconds(10)
            self:Destroy()
        end,


        OnCollisionCheck = function(self, other)
            return false
        end,

        OnCollision = function(self, other, nx, ny, nz, depth)
        end,

        OnDamage = function(self, instigator, armormod, direction, type)
            if self:DamageIsDisintegrate(type) then
                ChangeState(self, self.DisintegrateState)
            elseif not self:DamageIsForce(type) and not self:DamageIsFire(type) then
                ChangeState(self, self.ObliteratedState)
            end

            self:CheckForBlackHoleDamage(instigator, type)
        end,
    },

    DisintegrateState = State {
        Main = function(self)
            self.Burning = false
            self:DestroyFireEffects()
            self:Destroy()
        end,
    },

    ObliteratedState = State {
        Main = function(self)
            local templ = NomadsEffectTemplate.TreeDisintegrate
            if self.Fallen then templ = NomadsEffectTemplate.FallenTreeDisintegrate end
            for k, v in templ do
                CreateEmitterAtBone( self, 0, -1, v )  -- the effects must have a limited life...
            end
            self.Burning = false
            self:DestroyFireEffects()
            self:Destroy()
        end,
    },

    StateVariable = function(self, var)
        if var then self._StateVariable = var end
        return self._StateVariable
    end,

    DamageIsForce = function(self, type)
        return (type == 'Force' or type == 'ForceInwards' or type == 'ExperimentalFootfall')  -- exp footfall so the trees fall by steps from experimentals
    end,

    DamageIsFire = function(self, type)
        return (type == 'Fire' or type == 'BigFire' or type == 'ForestFire')
    end,

    DamageIsDisintegrate = function(self, type)
        return type == 'Disintegrate'
    end,

    DamageIsObliterate = function(self, type)
        return (type == 'BlackholeDeathNuke' or type =='BlackholeDamage' or type == 'Deathnuke' or type == 'Nuke')
    end,

    PlayFireEffects = function(self, initialScale, curveParam)

        if self.BurnTime <= 0 then return end

        if self.FireEffectsThread then
            KillThread(self.FireEffectsThread)
            self:DestroyFireEffects()
        end

        if not initialScale or initialScale <= 0 then initialScale = 1 end
        if not curveParam or curveParam <= 0 then curveParam = 2 end
        if not self.FireEffects then self.FireEffects = {} end
        if not self.BurnTimeOrg then self.BurnTimeOrg = self.BurnTime end

        local templ = NomadsEffectTemplate.TreeFire
        if self.BigFireFx and self.Fallen then
            templ = NomadsEffectTemplate.FallenTreeBigFire
        elseif self.BigFireFx then
            templ = NomadsEffectTemplate.TreeBigFire
        elseif self.Fallen then
            templ = NomadsEffectTemplate.FallenTreeFire
        end

        local fn = function(self, templ, initialScale, curveParam)
            local scale, frac, curve, dmgTime, emit = initialScale, 1, 1, 1
-- FIXME: this seems to put the flames on a wrong place
--            local offset = RandomFloat(0, 1)
--            local dx, dy, dz = self:GetBoneDirection(0)

            self:PlayPropSound('BurnStart')
            self:PlayPropAmbientSound('BurnLoop')

            for k, v in templ do
                emit = CreateAttachedEmitter(self, 0, -1, v):ScaleEmitter( scale )
--                emit:OffsetEmitter( dx * offset, dy * offset, dz * offset)
                table.insert( self.FireEffects, emit )
                self.Trash:Add(emit)
            end

            self:SetMesh(self:GetBlueprint().Display.MeshBlueprintWrecked)
            if not self.ScorchMarkCreated then
                self.ScorchMarkCreated = true
                DefaultExplosions.CreateScorchMarkSplat( self, 0.5, -1 )
            end

            while self and self.BurnTime > 0 do
                frac = self.BurnTime / self.BurnTimeOrg
                curve = (-curveParam * math.pow(frac, 2)) + (curveParam * frac) + 1
                scale = initialScale * frac * curve
                for k, v in self.FireEffects do
                    v:ScaleEmitter( scale )
                end
-- TODO: disabled for performance reasons. remove completely?
--                if dmgTime <= 0 then
--                    DamageArea(self, self:GetCachePosition(), 1, 1, 'ForestFire', true)
--                    dmgTime = Random(140, 200)
--                    if self.BigFireFx then
--                        dmgTime = dmgTime * 0.75
--                    end
--                end
                WaitTicks(10)
                self.BurnTime = self.BurnTime - 1
--                dmgTime = dmgTime - 10
            end

            self:PlayPropAmbientSound(nil)

            for k, v in self.FireEffects do
                v:Destroy()
            end

            self:PlayAfterFireEffects()
        end

        self.FireEffectsThread = self:ForkThread(fn, templ, initialScale, curveParam)
    end,

    DestroyFireEffects = function(self)
        if self.FireEffectsThread then
            KillThread( self.FireEffectsThread )
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


end