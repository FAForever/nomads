# T3 orbital artillery unit (the one that floats in space)

local NOrbitUnit = import('/lua/nomadunits.lua').NOrbitUnit
local OrbitalGun = import('/lua/nomadweapons.lua').OrbitalGun

INO2302 = Class(NOrbitUnit) {
    Weapons = {
        MainGun = Class(OrbitalGun) {

            MasterWeaponBlueprint = function(self, _mbp)
                self.mbp = {}
                self.mbp['DamageAmount'] = _mbp.Damage
                self.mbp['DamageRadius'] = _mbp.DamageRadius
                self.mbp['DamageType'] = _mbp.DamageType
                self.mbp['DamageFriendly'] = _mbp.DamageFriendly
                self.mbp['DoTTime'] = _mbp.DoTTime
                self.mbp['DoTPulses'] = _mbp.DoTPulses
            end,

            GetDamageTable = function(self)
                local damageTable = OrbitalGun.GetDamageTable(self)
                for k, v in self.mbp do
                    damageTable[k] = v
                end
                return damageTable
            end,

            OnWeaponFired = function(self)
                OrbitalGun.OnWeaponFired(self)
                self.unit:OnWeaponFired()
            end,
        },
    },

    EngineRotateBones = { 'Panel_L', 'Panel_R', },

    OnCreate = function(self)
        NOrbitUnit.OnCreate(self)

# TODO: fix this. Gives weird behaviour right now
#        # create the engine thrust manipulators and set up the thursting arcs for the engines
#        self.EngineManipulators = {}
#        local manip
#        for k, v in self.EngineRotateBones do
#            manip = CreateThrustController(self, 'Thruster', v)
#            manip:SetThrustingParam( 0, 0, 0, 0, -0.1, 0.1, 1, 0.25 )  # XMAX, XMIN, YMAX, YMIN, ZMAX, ZMIN, TURNMULT, TURNSPEED
#            self.Trash:Add(manip)
#            table.insert(self.EngineManipulators, manip)
#        end

        self:SetWeaponEnabledByLabel('MainGun', false)

        self.parent = nil
        self.parentCallbacks = {}
        self.parentCallbacks[ 'OnWeaponFired' ] = false
        self.parentCallbacks[ 'OnKilledUnit' ] = false
    end,

    OnSetParent = function(self, parent, cbWepFired, cbKilledUnit)
        self.parent = parent
        self.parentCallbacks[ 'OnWeaponFired' ] = cbWepFired or false
        self.parentCallbacks[ 'OnKilledUnit' ] = cbKilledUnit or false

        # quick check of unit blueprints
        local myBp, theirBp = self:GetBlueprint(), parent:GetBlueprint()
        if (theirBp.Buffs and not myBp.Buffs) or (not theirBp.Buffs and myBp.Buffs) or (theirBp.Buffs and myBp.Buffs and not table.equal( myBp.Buffs, theirBp.Buffs)) then
            WARN('INO2302: Buffs sections in parent and slave unit blueprints do not match')
        end
        if (theirBp.Veteran and not myBp.Veteran) or (not theirBp.Veteran and myBp.Veteran) or (theirBp.Veteran and myBp.Veteran and not table.equal( myBp.Veteran, theirBp.Veteran)) then
            WARN('INO2302: Veteran sections in parent and slave unit blueprints do not match')
        end

        # set my gun equal to what the parent has set in terms of range and damage, etc. This way we can balance the artillery
        # by adjusting the base unit only.
        local TheirGun = parent:GetWeaponByLabel('TargetFinder')
        if TheirGun then
            local gbp = TheirGun:GetBlueprint()
            local MyGun = self:GetWeaponByLabel('MainGun')
            MyGun:ChangeMaxRadius( gbp.MaxRadius or 1)
            MyGun:ChangeMinRadius( gbp.MinRadius or 0) 
            MyGun:ChangeRateOfFire ( gbp.RateOfFire or 1)
            MyGun:SetFiringRandomness( gbp.FiringRandomness or 0)
            MyGun:MasterWeaponBlueprint( gbp)
        else
            WARN('INO2302: Cant find target finder weapon on parent unit')
        end
    end,

    OnWeaponFired = function(self)
        local cb = self.parentCallbacks[ 'OnWeaponFired' ]
        if cb then
            cb( self.parent )
        end
    end,

    OnKilledUnit = function(self, unitKilled)
        NOrbitUnit.OnKilledUnit(self, unitKilled)
        local cb = self.parentCallbacks[ 'OnKilledUnit' ]
        if cb then
            cb( self.parent )
        end
    end,

    OnParentKilled = function(self)
        self:EnableWeapon(false)
        self.parentCallbacks[ 'OnWeaponFired' ] = false
        self.parentCallbacks[ 'OnKilledUnit' ] = false

        # TODO: maybe some effects stop? lights, I dont know..
    end,

    SetTarget = function( self, target, targetPos )
        local MyGun = self:GetWeapon(1)
        if target and target != nil then
            MyGun:SetTargetEntity( target )
        elseif targetPos and targetPos != nil then
            MyGun:SetTargetGround( targetPos )
        else
            MyGun:OnLostTarget()
            MyGun:ResetTarget()
        end
    end,

    EnableWeapon = function(self, enable)
        self:SetWeaponEnabledByLabel('MainGun', enable)
    end,
}

TypeClass = INO2302