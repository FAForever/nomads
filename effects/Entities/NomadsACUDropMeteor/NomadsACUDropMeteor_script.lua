local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local Meteor = import('/effects/Entities/Meteor/Meteor_script.lua').Meteor

NomadsACUDropMeteor = Class(Meteor) {

    ImpactLandFx = NomadsEffectTemplate.ACUMeteorLandImpact,
    ImpactSeabedFx = NomadsEffectTemplate.ACUMeteorSeabedImpact,
    ImpactWaterFx = NomadsEffectTemplate.ACUMeteorWaterImpact,
    ResidualSmoke1 = NomadsEffectTemplate.ACUMeteorResidualSmoke01,
    ResidualSmoke2 = NomadsEffectTemplate.ACUMeteorResidualSmoke02,
    ResidualSmoke3 = NomadsEffectTemplate.ACUMeteorResidualSmoke03,
    TrailFx = NomadsEffectTemplate.ACUMeteorTrail,
    TrailUnderwaterFx = NomadsEffectTemplate.ACUMeteorUnderWaterTrail,

    DecalLifetime = 600,

    ImpactEffects = function(self, position, InWater, scale)
        Meteor.ImpactEffects(self, position, InWater, scale)

        local ori = self:GetOrientation()
        local pos = self:GetPosition()
        local x,y,z = unpack(pos)
        local terrain = GetTerrainHeight(x, z)
        y = terrain
        local droppod = CreateUnitHPR('XNA0001', self.Army, x, y, z, 0, 0, 0)
        --self.Trash:Add(droppod)

        -- adjusting droppod elevation to make the unit appear under water if we need it there. Since it is an air unit
        -- it will always stay on the surface but changing the elevation works.
        local surface = GetSurfaceHeight(x, z)
        local baseElev = droppod:GetBlueprint().Physics.Elevation or 0
        local elev = baseElev - (surface-terrain)
        droppod:SetElevation(elev)

        Warp(droppod, Vector(x,y,z))
    end,
}

TypeClass = NomadsACUDropMeteor
