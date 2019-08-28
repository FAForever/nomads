-- T3 artillery
local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local GetOwnUnitsInSphere = import('/lua/utilities.lua').GetOwnUnitsInSphere
local NIFTargetFinderWeapon = import('/lua/nomadsweapons.lua').NIFTargetFinderWeapon
local NUtils = import('/lua/nomadsutils.lua')
local CreateOrbitalUnit = NUtils.CreateOrbitalUnit
local RequestOrbitalSpawnThread = NUtils.RequestOrbitalSpawnThread
local FindOrbitalUnit = NUtils.FindOrbitalUnit

XNB2302 = Class(NStructureUnit) {
    Weapons = {
        --Instead of creating the projectile, we order the satellite to strike there.
        TargetFinder = Class(NIFTargetFinderWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
                local target = self:GetCurrentTargetPos()
                self.unit:StrikeTarget(target)
            end,
        },
    },

    StrikeTarget = function(self, target)
        if self.ArtilleryUnit then
            self.LaunchOrbitalStrike(self.ArtilleryUnit, target)
        else
            WARN('Nomads: attempt to fire T3 artillery without satellite - aborting')
        end
    end,
    
    LaunchOrbitalStrike = function(unit, targetPosition)
        local weapon = unit:GetWeaponByLabel('MainGun')
        weapon:SetTargetGround( targetPosition )
        weapon:OnFire()
    end,
    
    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
        self.ArtilleryUnit = nil
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.ArtilleryUnit then
            self.ArtilleryUnit:OnParentKilled()
        end
        NStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnStartBeingBuilt = function(self, builder, layer)
        NStructureUnit.OnStartBeingBuilt(self, builder, layer)
        self:ForkThread( self.WatchBuildProgress )
    end,

    WatchBuildProgress = function(self)
        while not self.Dead and self:GetFractionComplete() < 1 and not self.ArtilleryAlreadyRequested do
            if self:GetFractionComplete() >= 0.5 and (self:GetHealth() / self:GetMaxHealth()) >= 0.5 then
                self.ArtilleryAlreadyRequested = true
                self:FindArtillerySatellite()
            end
            WaitSeconds(2)
        end
    end,

    FindArtillerySatellite = function(self)
        local position = self:GetPosition()
        local satellites = GetOwnUnitsInSphere(position, 500, self:GetArmy(), categories.xno2302)
        local ArtilleryAssigned = false
        
        for _,satellite in satellites do
            if satellite.Unused == true then
                self:OnArtilleryUnitAssigned(satellite)
                ArtilleryAssigned = true
                break
            end
        end
        
        if ArtilleryAssigned == false then
            --search in a certain range so it doesnt take too long for the satellites to arrive
            local OrbitalFrigate = FindOrbitalUnit(self, categories.xno0001, 350)
            if OrbitalFrigate then
                OrbitalFrigate:AddToSpawnQueue( 'xno2302', self )
            else
                self:ForkThread( RequestOrbitalSpawnThread, 'xno2302')
            end
        end
    end,
    
    OnStopBeingBuilt = function(self, builder, layer)
        NStructureUnit.OnStopBeingBuilt(self, builder, layer)

        -- in case we haven't asked for a slave unit, do it now
        if not self.ArtilleryAlreadyRequested then
            ForkThread(function()
                WaitSeconds(2)
                if not self.ArtilleryAlreadyRequested then
                    self.ArtilleryAlreadyRequested = true
                    self:FindArtillerySatellite()
                end
            end)
        end

        -- enable dummy weapon if there's a slave unit assigned to us, if not, wait for it
        if self.ArtilleryUnit then
            self.ArtilleryUnit:EnableWeapon(true)
        end
    end,

    OnArtilleryUnitAssigned = function(self, gun)
        self.ArtilleryUnit = gun

        -- Set the satellite to ground fire so we can tell it where to shoot
        gun:SetFireState(import('/lua/game.lua').FireState.GROUND_FIRE)
        IssueClearCommands( {gun} )

        -- tell the satellite we're it's parent and position it above us
        gun:OnSetParent(self, self.OnArtilleryUnitKilledUnit )
        IssueMove( {gun}, self:GetPosition() )

        ForkThread(function()
                local stillMoving = true
                while stillMoving do
                    local pos = self:GetPosition()
                    local gunPos = gun:GetPosition()
                    if math.abs(pos[1] - gunPos[1]) < 2 and math.abs(pos[3] - gunPos[3]) < 2 then
                        stillMoving = false
                        gun:SetUnSelectable(false)
                        gun:SetImmobile(true)
                    end
                    WaitSeconds(2)
                end
            end
        )
        if self:GetFractionComplete() >= 1 then
            self.ArtilleryUnit:EnableWeapon(true)
        end
    end,

    OnArtilleryUnitKilledUnit = function(self, unitKilled)
        -- called each time the gun kills a unit
        self:OnKilledUnit(unitKilled)
    end,

    OnGiven = function(self, newUnit)
        if self.ArtilleryUnit ~= nil then
            newUnit.ArtilleryAlreadyRequested = true
            local pos = self.ArtilleryUnit:GetPosition()
            ChangeUnitArmy(self.ArtilleryUnit, (newUnit:GetAIBrain()):GetArmyIndex() ) --why not newUnit:GetArmy()
            for _ , unit in GetUnitsInRect( Rect(pos[1]-2.5, pos[3]-2.5, pos[1]+2.5, pos[3]+2.5) ) do
                if string.find(unit:GetBlueprint().BlueprintId, 'xno2302') then
                    newUnit:OnArtilleryUnitAssigned(unit)
                    return
                end
            end
        else
            self.ArtilleryAlreadyRequested = true
            newUnit.ArtilleryAlreadyRequested = false
        end
    end,
}

TypeClass = XNB2302
