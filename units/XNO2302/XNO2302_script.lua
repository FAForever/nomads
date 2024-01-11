-- T3 orbital artillery unit (the one that floats in space)

local NOrbitUnit = import('/lua/nomadsunits.lua').NOrbitUnit
local OrbitalGun = import('/lua/nomadsweapons.lua').OrbitalGun

xno2302 = Class(NOrbitUnit) {
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
    
    OnCreate = function(self)
        NOrbitUnit.OnCreate(self)
    end,
    
    OnStopBeingBuilt = function(self)
    end,
    
    OnMotionHorzEventChange = function(self)
        NOrbitUnit.OnMotionHorzEventChange(self)
    end,
}

TypeClass = xno2302
