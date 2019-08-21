do


local SetBeamsToColoured = import('/lua/NomadsUtils.lua').SetBeamsToColoured
local CreateEmitterAtBone = import('/lua/NomadsUtils.lua').CreateEmitterAtBoneColoured
local CreateEmitterAtEntity = import('/lua/NomadsUtils.lua').CreateEmitterAtEntityColoured

local oldProjectile = Projectile

Projectile = Class(oldProjectile) {

    OnCreate = function(self, inWater)
        self.ColourIndex = self:GetLauncher().ColourIndex or 383.999
        SetBeamsToColoured(self, self.BeamsToRecolour)
        oldProjectile.OnCreate(self, inWater)
        self.ImpactOnType = "Unknown"
    end,

    --fill this table with emitters to recolour. This one works on trails and beams.
    BeamsToRecolour = {},

    --completely unchanged, just put here to allow the imported functions to override the engine functions.
    CreateImpactEffects = function(self, army, EffectTable, EffectScale)
        local emit = nil
        for _, v in EffectTable do
            if self.FxImpactTrajectoryAligned then
                emit = CreateEmitterAtBone(self, -2, army, v)
            else
                emit = CreateEmitterAtEntity(self, army, v)
            end
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,

    --completely unchanged, just put here to allow the imported functions to override the engine functions.
    CreateTerrainEffects = function(self, army, EffectTable, EffectScale)
        local emit = nil
        for _, v in EffectTable do
            emit = CreateEmitterAtBone(self, -2, army, v)
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,


    --TODO:Remove this?
    PassDamageData = function(self, DamageData)
        oldProjectile.PassDamageData(self, DamageData)
    end,

    --TODO:see if this can be removed. either merged into faf or just deleted if we dont need it.
    OnImpact = function(self, targetType, targetEntity)
        self.ImpactOnType = targetType   -- adding this var so destructively hooking is not necessary

        if targetType == 'Terrain' then  -- Terrain does not equal Land, it could also be the seabed...
            local pos = self:GetPosition()
            local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
            if pos[2] < surface then
                self.FxImpactLand = self.FxImpactSeabed or self.FxImpactLand
            end
        end

        oldProjectile.OnImpact(self, targetType, targetEntity)
    end,

    --TODO: see if this is needed still, it should be functional in FAF
    DoUnitImpactBuffs = function(self, target)
        -- the original version of this function has the parent unit do the buffing when there's a radius specified. I also need the
        -- unit that was hit to fix a problem where that unit isn't stunned (see unit.lua for more info). Destructively overwriting this fn
        -- to fix the problem.

        local data = self.DamageData
        local ok = true

        if data.Buffs then

            local orgTarget = target  -- remember original unit
            for k, v in data.Buffs do

                if v.Add.OnImpact == true then

                    if v.Add.ImpactTypeDisallow and self.ImpactOnType then   -- check impact restrictions. In some cases we dont want buffs applied when hitting for example water or shields.
                        if table.find(v.Add.ImpactTypeDisallow, self.ImpactOnType) then
                            --LOG('*DEBUG: dont do impact buffs because surfacetype is disallowed: '..repr(self.ImpactOnType))
                            continue
                        end
                    end

                    if ( v.AppliedToTarget ~= true ) or ( v.Radius and (v.Radius > 0) ) then  -- right side of the OR is the problem
                        target = self:GetLauncher()
                    end

                    if target and IsUnit(target) then
                        if ( v.Radius and (v.Radius > 0) ) then
                            target:AddBuff(v, self:GetPosition(), orgTarget)  -- added last argument
                        else
                            target:AddBuff(v)
                        end
                    end
                end
            end
        end
    end,
}


end