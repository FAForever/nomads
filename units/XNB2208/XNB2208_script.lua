local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon2
local EffectTemplate = import('/lua/EffectTemplates.lua')

--- Tech 2 TML
---@class XNB2208 : NStructureUnit
XNB2208 = Class(NStructureUnit) {
    Weapons = {
        CruiseMissile = Class(TacticalMissileWeapon1) {
            FxMuzzleFlash = EffectTemplate.TIFCruiseMissileLaunchBuilding,
        },
    },

    ---@param self XNB2208
    ---@param builder Unit
    ---@param layer string
    OnStartBeingBuilt = function(self, builder, layer)
        local bp = self:GetBlueprint()
        if bp.Display.AnimationPermOpenAlt then
            self.PermOpenAnimManipulator = CreateAnimator(self):PlayAnim(bp.Display.AnimationPermOpenAlt):SetRate(0)
            self.Trash:Add(self.PermOpenAnimManipulator)
        end
        NStructureUnit.OnStartBeingBuilt(self, builder, layer)
    end,

    ---@param self XNB2208
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self, builder, layer)
        if self.PermOpenAnimManipulator then
            self.PermOpenAnimManipulator:SetRate(1)
        end
        NStructureUnit.OnStopBeingBuilt(self, builder, layer)
    end,
}
TypeClass = XNB2208