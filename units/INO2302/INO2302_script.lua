-- T3 orbital artillery unit (the one that floats in space)

local NOrbitUnit = import('/lua/nomadsunits.lua').NOrbitUnit
local OrbitalGun = import('/lua/nomadsweapons.lua').OrbitalGun

INO2302 = Class(NOrbitUnit) {
    Weapons = {
        MainGun = Class(OrbitalGun) {
        },
    },

    EngineRotateBones = { 'Panel_L', 'Panel_R', },

    OnCreate = function(self)
        NOrbitUnit.OnCreate(self)
-- TODO: fix this. Gives weird behaviour right now
--        -- create the engine thrust manipulators and set up the thursting arcs for the engines
--        self.EngineManipulators = {}
--        local manip
--        for k, v in self.EngineRotateBones do
--            manip = CreateThrustController(self, 'Thruster', v)
--            manip:SetThrustingParam( 0, 0, 0, 0, -0.1, 0.1, 1, 0.25 )  -- XMAX, XMIN, YMAX, YMIN, ZMAX, ZMIN, TURNMULT, TURNSPEED
--            self.Trash:Add(manip)
--            table.insert(self.EngineManipulators, manip)
--        end
        self:SetWeaponEnabledByLabel('MainGun', false)
        self:SetUnSelectable(true)
        
        self.parent = nil
        self.parentCallbacks = {}
        self.parentCallbacks[ 'OnKilledUnit' ] = false
    end,

    OnSetParent = function(self, parent, cbKilledUnit)
        self.parent = parent
        self.parentCallbacks[ 'OnKilledUnit' ] = cbKilledUnit or false
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
        if self.xp then
            self:AddXP(-self.xp)
        end
        -- TODO: maybe some effects stop? lights, I dont know..
    end,

    EnableWeapon = function(self, enable)
        self:SetWeaponEnabledByLabel('MainGun', enable)
    end,
}

TypeClass = INO2302
