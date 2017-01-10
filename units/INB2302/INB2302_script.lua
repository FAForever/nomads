-- T3 artillery

-- this is the ground statino for the T3 artillery unit. It gets an orbital 'slave' unit assigned which does the shooting.
-- the base station should tell the orbital unit what to fire on. I'm using a fake weapon to do the targetting. It's target
-- is relayed to the slave unit.

local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local DefaultProjectileWeapon = import('/lua/sim/defaultweapons.lua').DefaultProjectileWeapon

INB2302 = Class(NStructureUnit) {
    Weapons = {
        TargetFinder = Class(DefaultProjectileWeapon) {

            CreateProjectileForWeapon = function(self, bone)
            end,

            CreateProjectileAtMuzzle = function(self, muzzle)
            end,

            OnLostTarget = function(self)
                self.unit:SetArtilleryUnitTarget( nil, nil )
            end,

            OnGotTarget = function(self)
                self.unit:SetArtilleryUnitTarget( self:GetCurrentTarget(), self:GetCurrentTargetPos() )
            end,

            OnStartTracking = function(self, label)
                self.unit:SetArtilleryUnitTarget( self:GetCurrentTarget(), self:GetCurrentTargetPos() )
            end,

            OnStopTracking = function(self, label)
                self.unit:SetArtilleryUnitTarget( nil, nil )
            end,

            IdleState = State(DefaultProjectileWeapon.IdleState) {
                OnGotTarget = function(self)
                    self.unit:SetArtilleryUnitTarget( self:GetCurrentTarget(), self:GetCurrentTargetPos() )
                end,
            },
        }
    },

    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
        self.ArtilleryUnit = nil
        self.CanSetNewArtilleryUnitTarget = true
        self:SetWeaponEnabledByLabel( 'DummyWeapon', false )
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.ArtilleryUnit then
            self.ArtilleryUnit:OnParentKilled()
            self:GetAIBrain():ParentOfUnitKilled( self.ArtilleryUnit )
        end
        NStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnStartBeingBuilt = function(self, builder, layer)
        NStructureUnit.OnStartBeingBuilt(self, builder, layer)
        self:ForkThread( self.WatchBuildProgress )
    end,

    WatchBuildProgress = function(self)
        while not self:IsDead() and self:GetFractionComplete() < 1 and not self.ArtilleryUnitRequested do
            if self:GetFractionComplete() >= 0.5 and (self:GetHealth() / self:GetMaxHealth()) >= 0.5 then
                self.ArtilleryUnitRequested = true
                self:GetAIBrain():RequestUnitAssignedToParent(self, 'ino2302', self.OnArtilleryUnitAssigned)
            end
            WaitSeconds(2)
        end
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NStructureUnit.OnStopBeingBuilt(self, builder, layer)

        -- in case we haven't asked for a slave unit, do it now
        if not self.ArtilleryUnitRequested then
            self.ArtilleryUnitRequested = true
            self:GetAIBrain():RequestUnitAssignedToParent(self, 'ino2302', self.OnArtilleryUnitAssigned)
        end

        -- enable dummy weapon if there's a slave unit assigned to us, if not, wait for it
        if self.ArtilleryUnit then
            self:SetWeaponEnabledByLabel( 'DummyWeapon', true )
        else
            self:SetWeaponEnabledByLabel( 'DummyWeapon', false )
        end
    end,

    WatchFireState = function(self, beam)
        local oldFireState = self.ArtilleryUnit:GetFireState()
        while true do
            local FireState = self:GetFireState()
            if FireState ~= oldFireState then
                self.ArtilleryUnit:SetFireState( FireState )
            end
            oldFireState = FireState
            WaitSeconds(1)
        end
    end,

    SetWeaponEnabledByLabel = function(self, label, enable )
        if self.ArtilleryUnit then
            self.ArtilleryUnit:EnableWeapon(enable)
        end
        self.CanSetNewArtilleryUnitTarget = enable
        return NStructureUnit.SetWeaponEnabledByLabel(self, label, enable)
    end,

    SetArtilleryUnitTarget = function(self, target, targetPos)
        if self.CanSetNewArtilleryUnitTarget then
            if self.ArtilleryUnit then
                target = self:GetTargetEntity()   -- this function is much more reliable than the weapon one
                self.ArtilleryUnit:SetTarget( target, targetPos )
            else
                WARN( 'No artillery unit associated with T3 artillery unit! (2)' )
            end
        end
    end,

    OnArtilleryUnitAssigned = function(self, gun)
        self.ArtilleryUnit = gun

        -- position artillery gun above us
        local pos = self:GetPosition()
        local gunPos = gun:GetPosition()
        pos[2] = gunPos[2]
        IssueClearCommands( {gun} )
        IssueMove( {gun}, pos )

        -- tell the gun unit we're it's parent
        gun:OnSetParent(self, self.OnArtilleryUnitFired, self.OnArtilleryUnitKilledUnit )

        -- if we're constructed completely then enable the dummy weapon
        if self:GetFractionComplete() >= 1 then
            self:SetWeaponEnabledByLabel( 'DummyWeapon', true )
        end

        self:ForkThread( self.WatchFireState )
    end,

    OnArtilleryUnitFired = function(self)
        -- called each time the gun fires a projectile
    end,

    OnArtilleryUnitKilledUnit = function(self)
        -- called each time the gun kills a unit
        self:AddKills(1)
    end,
}

TypeClass = INB2302