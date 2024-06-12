local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')
local Util = import('/lua/utilities.lua')
local RandomFloat = Util.GetRandomFloat

---@class NEnergyBomb : NullShell
NEnergyBomb = Class(NullShell) {

    EnergyBombSurfaceFx = NomadsEffectTemplate.EnergyBombSurface,
    EnergyBombUnderWaterFx = NomadsEffectTemplate.EnergyBombUnderWater,

    PassData = function(self, data)
        if data.EnergyBombFxScale then self.FxScale = data.EnergyBombFxScale end
    end,

    PassDamageData = function(self, DamageData)
        NullShell.PassDamageData(self, DamageData)
        self:CreateNuclearExplosion()
    end,

    CreateNuclearExplosion = function(self)
        self:DoDamage( self:GetLauncher() or self, self.DamageData, nil )
        self:ForkThread(self.EffectThread)
    end,

    EffectThread = function(self)
        local position = self:GetPosition()
        local scale = self.FxScale or 1
        local surface = GetTerrainHeight(position[1], position[3]) + GetTerrainTypeOffset(position[1], position[3])
        local underWater = (position[2] < (surface -1) )

        -- Play the "NukeExplosion" sound
        local bp = self:GetBlueprint()
        if bp.Audio.NukeExplosion then
            self:PlaySound(bp.Audio.NukeExplosion)
        end

        -- Create ground decals
        local orientation = RandomFloat( 0, 2 * math.pi )
        CreateDecal(position, orientation, 'Crater01_albedo', '', 'Albedo', (20 * scale), (20 * scale), 1200, 0, self.Army)
        CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', (20 * scale), (20 * scale), 1200, 0, self.Army)
        CreateDecal(position, orientation, 'nuke_scorch_003_albedo', '', 'Albedo', (20 * scale), (20 * scale), 1200, 0, self.Army)

        -- Plasma bomb effects
        local templ = self.EnergyBombSurfaceFx
        if underWater then
            templ = self.EnergyBombUnderWaterFx
        end
        local emitters = EffectUtilities.CreateEffects( self, self.Army, templ )
        for k, emit in emitters do
            emit:ScaleEmitter( scale )
        end

        -- Knockdown force rings
        DamageRing(self, position, 0.1, (15 * scale), 1, 'Force', true)
        WaitSeconds(0.1)
        DamageRing(self, position, 0.1, (15 * scale), 1, 'Force', true)

        -- Residual smoke and fire
        WaitSeconds(1.9)

        local maxOffset = 5
        local m = Random(-4, 5)
        for i = 1, m do
            local templ = NomadsEffectTemplate.EnergyBombResidualFlames_Var1
            local emitters = EffectUtilities.CreateEffectsWithOffset( self, self.Army, templ, RandomFloat(-maxOffset, maxOffset), 0, RandomFloat(-maxOffset, maxOffset) )
            local scl = RandomFloat(0.75, 1.25)
            for k, emit in emitters do
                emit:ScaleEmitter( scl )
            end
        end

        self:Destroy()
    end,
}

TypeClass = NEnergyBomb
