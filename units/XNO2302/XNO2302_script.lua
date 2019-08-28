-- T3 orbital artillery unit (the one that floats in space)

local NOrbitUnit = import('/lua/nomadsunits.lua').NOrbitUnit
local OrbitalGun = import('/lua/nomadsweapons.lua').OrbitalGun

xno2302 = Class(NOrbitUnit) {
    Weapons = {
        MainGun = Class(OrbitalGun) {},
    },

    OnCreate = function(self)
        NOrbitUnit.OnCreate(self)
        self:SetWeaponEnabledByLabel('MainGun', false)
        
        self.parent = nil
        self.parentCallbacks = {}
        self.parentCallbacks[ 'OnKilledUnit' ] = false
    end,

    OnSetParent = function(self, parent, cbKilledUnit)
        self:SetImmobile(false)
        self.parent = parent
        self.Unused = false
        self.parentCallbacks[ 'OnKilledUnit' ] = cbKilledUnit or false
    end,

    --called by the spawning frigate when assigning us. After that its up to the parent to decide what to do.
    OnSpawnedInOrbit = function(self, parent)
        if parent then
            parent:OnArtilleryUnitAssigned(self)
        else
            WARN('spawned without parent!')
        end
    end,

    OnKilledUnit = function(self, unitKilled)
        local cb = self.parentCallbacks[ 'OnKilledUnit' ]
        if cb then
            cb( self.parent, unitKilled )
        end
        NOrbitUnit.OnKilledUnit(self, unitKilled)
    end,

    OnParentKilled = function(self)
        self:EnableWeapon(false)
        self.parentCallbacks[ 'OnWeaponFired' ] = false
        self.parentCallbacks[ 'OnKilledUnit' ] = false
        IssueClearCommands( {self} )
        self.Unused = true
    end,

    EnableWeapon = function(self, enable)
        self:SetWeaponEnabledByLabel('MainGun', enable)
    end,
}

TypeClass = xno2302
