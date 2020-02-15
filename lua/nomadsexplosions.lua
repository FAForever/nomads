local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

--TODO:Remove this?
function CreateFlashCustom( obj, bone, army, scale, duration, textureflash, rampflash )
    CreateLightParticle( obj, bone, army, scale, duration, textureflash, rampflash )
end

function CreateImpactMedium(self, pos, army, targetType)
    if targetType == 'Terrain' then
        DamageArea(self, pos, self.DamageData.DamageRadius * 1.2, 1, 'Force', true)
    end

    CreateLightParticle( self, -2, army, 2.5, 5*2, 'glow_05_red', 'ramp_jammer_01' )
    CreateLightParticle( self, -2, army, 3, 2*2, 'glow_05_red', 'ramp_jammer_01' )

    -- create some additional effects
    if targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater' then
        -- CreateScorchMarkDecal(pos, army, 'Scorch_012_albedo', 4, 5.5, 100, 150) --not a smart idea to leave decals on something that fires so fast
        if self.DoImpactFlash then
            CreateLightParticle( self, -1, army, 6, 5, 'glow_03', 'ramp_yellow_blue_01' )
            CreateLightParticle( self, -1, army, 8, 16, 'glow_03', 'ramp_antimatter_02' )
        end
    end
end

function CreateArtilleryImpactLarge(self, pos, army, targetType)
    DamageArea(self, pos, self.DamageData.DamageRadius * 3, 1, 'Force', true)

    if self.DoImpactFlash then
        CreateLightParticle( self, -1, army, 16, 6, 'glow_03', 'ramp_antimatter_02' )
    end

    if targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' then
        CreateScorchMarkDecal(pos, army, 'nuke_scorch_002_albedo', 13, 16, 40, 60)
    end
end

function CreateScorchMarkDecal(pos, army, blueprint, SizeMin, SizeMax, LifeMin, LifeMax)
    local rotation = RandomFloat(0,2*math.pi)
    local size = RandomFloat(SizeMin or 13, SizeMax or 16)
    local life = Random(LifeMin or 40, LifeMax or 60)
    CreateDecal(pos, rotation, blueprint, '', 'Albedo', size, size, 300, life, army)
end
