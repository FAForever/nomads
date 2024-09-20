local NOrbitUnit = import('/lua/nomadsunits.lua').NOrbitUnit
local OrbitalGun = import('/lua/nomadsweapons.lua').OrbitalGun

--- Tech 3 Orbital Artillery Unit
---@class XNO2302 : NOrbitUnit
XNO2302 = Class(NOrbitUnit) {
    Weapons = {
        MainGun = Class(OrbitalGun) {
            CreateProjectileAtMuzzle = function(self, muzzle)
                local bp = self:GetBlueprint()
                if bp.Audio.FireSpecial then
                    self:PlaySound(bp.Audio.FireSpecial)
                end

                --allow the projectile to transfer veterancy to its parent unit
                local proj = OrbitalGun.CreateProjectileAtMuzzle(self, muzzle)
                proj.Launcher = self.unit.parent or proj.Launcher
            end,
        },
    },

    ---@param self XNO2302
    OnCreate = function(self)
        NOrbitUnit.OnCreate(self)
    end,

    ---@param self XNO2302
    OnStopBeingBuilt = function(self)
    end,

    ---@param self XNO2302
    OnMotionHorzEventChange = function(self)
        NOrbitUnit.OnMotionHorzEventChange(self)
    end,
}
TypeClass = XNO2302