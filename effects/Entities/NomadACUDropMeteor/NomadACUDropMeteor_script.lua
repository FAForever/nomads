local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local Meteor = import('/effects/Entities/Meteor/Meteor_script.lua').Meteor

NomadACUDropMeteor = Class(Meteor) {

    ImpactLandFx = NomadEffectTemplate.ACUMeteorLandImpact,
    ImpactSeabedFx = NomadEffectTemplate.ACUMeteorSeabedImpact,
    ImpactWaterFx = NomadEffectTemplate.ACUMeteorWaterImpact,
    ResidualSmoke1 = NomadEffectTemplate.ACUMeteorResidualSmoke01,
    ResidualSmoke2 = NomadEffectTemplate.ACUMeteorResidualSmoke02,
    ResidualSmoke3 = NomadEffectTemplate.ACUMeteorResidualSmoke03,
    TrailFx = NomadEffectTemplate.ACUMeteorTrail,
    TrailUnderwaterFx = NomadEffectTemplate.ACUMeteorUnderWaterTrail,

    DecalLifetime = 600,

    ImpactEffects = function(self, position, InWater, scale)
        Meteor.ImpactEffects(self, position, InWater, scale)

        local army = self:GetArmy()
        local ori = self:GetOrientation()
        local pos = self:GetPosition()
        local x,y,z = unpack(pos)
        local terrain = GetTerrainHeight(x, z)
        y = terrain
        local droppod = CreateUnitHPR('INA0001', army, x, y, z, 0, 0, 0)
        --self.Trash:Add(droppod)

        -- adjusting droppod elevation to make the unit appear under water if we need it there. Since it is an air unit
        -- it will always stay on the surface but changing the elevation works.
        local surface = GetSurfaceHeight(x, z)
        local baseElev = droppod:GetBlueprint().Physics.Elevation or 0
        local elev = baseElev - (surface-terrain)
        droppod:SetElevation(elev)

        Warp(droppod, Vector(x,y,z))
    end,

    DoDamage = function(self)
        local pos = self:GetPosition()
        DamageRing(self, pos, .1, 11, 100, 'Force', false, false)
        DamageRing(self, pos, .1, 11, 100, 'Force', false, false)
        DamageRing(self, pos, 11, 20, 1, 'Force', false, false)
        DamageRing(self, pos, 11, 20, 1, 'Force', false, false)
        DamageRing(self, pos, 20, 27, 1, 'Fire', false, false)
    end,

    SetVisuals = function(self)
    end,
}

TypeClass = NomadACUDropMeteor
