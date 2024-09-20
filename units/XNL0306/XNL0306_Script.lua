local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local EMPGun = import('/lua/nomadsweapons.lua').EMPGun

--- Tech 2 EMP Tank
---@class XNL0306 : NLandUnit
XNL0306 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(EMPGun) {
            FxMuzzleFlash = import('/lua/nomadseffecttemplate.lua').EMPGunMuzzleFlash_Tank,
            CreateProjectileAtMuzzle = function(self, muzzle)
                local proj = EMPGun.CreateProjectileAtMuzzle(self, muzzle)
                local data = self:GetBlueprint().DamageToShields
                if proj and not proj:BeenDestroyed() then
                    proj:PassData(data)
                end
            end,
        },
    },
}
TypeClass = XNL0306