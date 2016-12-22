# T2 TML

local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local TacticalMissileWeapon1 = import('/lua/nomadweapons.lua').TacticalMissileWeapon1
local EffectTemplate = import('/lua/EffectTemplates.lua')

INB2208 = Class(NStructureUnit) {
    Weapons = {
        CruiseMissile = Class(TacticalMissileWeapon1) {
            FxMuzzleFlash = EffectTemplate.TIFCruiseMissileLaunchBuilding,
        },
    },

    OnStartBeingBuilt = function(self, builder, layer)
        local bp = self:GetBlueprint()
        if bp.Display.AnimationPermOpenAlt then
            self.PermOpenAnimManipulator = CreateAnimator(self):PlayAnim(bp.Display.AnimationPermOpenAlt):SetRate(0)
            self.Trash:Add(self.PermOpenAnimManipulator)
        end        
        NStructureUnit.OnStartBeingBuilt(self, builder, layer)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        if self.PermOpenAnimManipulator then
            self.PermOpenAnimManipulator:SetRate(1)
        end
        NStructureUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}

TypeClass = INB2208