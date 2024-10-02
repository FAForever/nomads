local Util = import('/lua/utilities.lua')
local RandomFloat = Util.GetRandomFloat
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

---@class NomadsACUDropPodCover : NullShell
NomadsACUDropPodCover = Class(NullShell) {

    FxImpactAirUnit = NomadsEffectTemplate.ACUMeteorCoverExplodeAirUnit,
    FxImpactLand = NomadsEffectTemplate.ACUMeteorCoverExplodeLand,
    FxImpactNone = NomadsEffectTemplate.ACUMeteorCoverExplode,
    FxImpactProp = NomadsEffectTemplate.ACUMeteorCoverExplodeProp,
    FxImpactShield = NomadsEffectTemplate.ACUMeteorCoverExplodeShield,
    FxImpactWater = NomadsEffectTemplate.ACUMeteorCoverExplodeWater,
    FxImpactUnderWater = NomadsEffectTemplate.ACUMeteorCoverExplodeUnderWater,
    FxImpactUnit = NomadsEffectTemplate.ACUMeteorCoverExplodeUnit,
    FxImpactProjectile = NomadsEffectTemplate.ACUMeteorCoverExplodeProjectile,
    FxImpactProjectileUnderWater = NomadsEffectTemplate.ACUMeteorCoverExplodeUnderWater,

    InitialHeight = 300,

    ---@param self NomadsACUDropPodCover
    Launch = function(self)
        local fn = function(self)

            -- determine a random launch vector and set velocities
            local angle = RandomFloat(0, 2 * math.pi)
            local vx = math.sin(angle)
            local vy = 5
            local vz = math.cos(angle)

            vx, vy, vz = unpack( Util.NormalizeVector(Vector( vx, vy, vz )))

            self:SetStayUpright(true)
            self:SetVelocity(vx, vy, vz)
            self:SetVelocity(RandomFloat(13,17))
            self:SetBallisticAcceleration(-10)

            self:SetCollision(false)
            WaitSeconds(1)
            self:SetCollision(true)
        end

        self:ForkThread(fn)
    end,

    ---@param self NomadsACUDropPodCover
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        -- need to use the correct impact type to play the right sound
        if targetType == 'Terrain' and self:IsUnderWater() then
            targetType = 'Underwater'
        end

        NullShell.OnImpact(self, targetType, targetEntity)

        -- create some additional effects
        local ok = (targetType ~= 'Water' and targetType ~= 'Shield' and targetType ~= 'Air' and targetType ~= 'UnitAir' and targetType ~= 'UnitUnderwater')
        if ok then
            local rotation = RandomFloat(0,2*math.pi)
            local size = RandomFloat(5, 6.5)
            local life = Random(40, 60)
            CreateDecal(self:GetPosition(), rotation, 'Scorch_010_albedo', '', 'Albedo', size, size, 300, life, self.Army)
        end    
    end,

    ---@param self NomadsACUDropPodCover
    ---@return boolean
    IsUnderWater = function(self)
        local x,y,z = unpack(self:GetPosition())
        return (y < GetSurfaceHeight(x, z))
    end,
}
TypeClass = NomadsACUDropPodCover