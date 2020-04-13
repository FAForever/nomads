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
        self:SetWeaponEnabledByLabel('MainGun', false)
        
        self.parent = nil
    end,
    
    OnDestroy = function(self)
        --if the satellite is destroyed for any reason, and it has a parent, it should let its parent know.
        if self.parent then
            self.parent.ArtilleryUnit = nil
            --if the parent is in a condition to do so, it should get a replacement
            if not self.parent.Dead and self.parent:GetFractionComplete() >= 0.5 then
                self.parent.ArtilleryAlreadyRequested = true
                self.parent:FindArtillerySatellite()
            end
        end
        NOrbitUnit.OnDestroy(self)
    end,

    --called by the spawning frigate when assigning us. After that its up to the parent to decide what to do.
    OnSpawnedInOrbit = function(self, parentUnit)
        if parentUnit then
            parentUnit:OnArtilleryUnitAssigned(self)
        else
            WARN('spawned without parent unit!')
        end
    end,

    OnParentKilled = function(self)
        self:EnableWeapon(false)
        IssueClearCommands( {self} )
        self.Unused = true
        self.parent = nil
    end,

    EnableWeapon = function(self, enable)
        self:SetWeaponEnabledByLabel('MainGun', enable)
    end,
}

TypeClass = xno2302
