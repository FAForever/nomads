-- T3 artillery
local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local DefaultProjectileWeapon = import('/lua/sim/defaultweapons.lua').DefaultProjectileWeapon

INB2302 = Class(NStructureUnit) {
    Weapons = {
    },

    OnCreate = function(self)
        NStructureUnit.OnCreate(self)
        self.ArtilleryUnit = nil
        self.CanSetNewArtilleryUnitTarget = true
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
            ForkThread(function()
                WaitSeconds(5)
                if not self.ArtilleryUnitRequested then
                    self.ArtilleryUnitRequested = true
                    self:GetAIBrain():RequestUnitAssignedToParent(self, 'ino2302', self.OnArtilleryUnitAssigned)
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

        -- position artillery gun above us
        gun:SetUnSelectable(true)
        gun:SetFireState(import('/lua/game.lua').FireState.GROUND_FIRE)
        IssueClearCommands( {gun} )

        -- tell the gun unit we're it's parent
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
            newUnit.ArtilleryUnitRequested = true
            local pos = self.ArtilleryUnit:GetPosition()
            ChangeUnitArmy(self.ArtilleryUnit, (newUnit:GetAIBrain()):GetArmyIndex() )
            for _ , unit in GetUnitsInRect( Rect(pos[1]-2.5, pos[3]-2.5, pos[1]+2.5, pos[3]+2.5) ) do
                if string.find(unit:GetBlueprint().BlueprintId, 'ino2302') then
                    newUnit:OnArtilleryUnitAssigned(unit)
                    return
                end
            end
        else
            self.ArtilleryUnitRequested = true
            newUnit.ArtilleryUnitRequested = false
            local requestqueue = self:GetAIBrain().RequestUnitQueue['ino2302']
            if requestqueue then
                requestqueue[1] = nil
                table.removeByValue(requestqueue, 1)
            end
        end
    end,
}

TypeClass = INB2302
