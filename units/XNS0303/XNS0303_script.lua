-- carrier

local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local AircraftCarrier = import('/lua/defaultunits.lua').AircraftCarrier
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1
local NAMFlakWeapon = import('/lua/nomadsweapons.lua').NAMFlakWeapon
local ExternalFactoryComponent = import("/lua/defaultcomponents.lua").ExternalFactoryComponent

XNS0303 = Class(NSeaUnit, AircraftCarrier, ExternalFactoryComponent) {

    FactoryAttachBone = 'Pad2',
    BuildAttachBone = 'Pad1',

    Weapons = {
        AAGun1 = Class(ParticleBlaster1) {},
        AAGun2 = Class(ParticleBlaster1) {},
        AAGun3 = Class(ParticleBlaster1) {},
        AAGun4 = Class(ParticleBlaster1) {},
        TMD1 = Class(NAMFlakWeapon) {
            TMDEffectBones = {'TMD1_Fx1', 'TMD1_Fx2',},

        },
        TMD2 = Class(NAMFlakWeapon) {
            TMDEffectBones = {'TMD2_Fx1', 'TMD2_Fx2',},
        },
    },

    DestructionPartsLowToss = { 'Pad1_1', 'Pad1_2', 'Pad1_3', 'Pad1_4', 'Pad1_5', 'Pad1_6',
                                'Pad2_1', 'Pad2_2', 'Pad2_3', 'Pad2_4', 'Pad2_5', 'Pad2_6',
                                'Pad3_1', 'Pad3_2', 'Pad3_3', 'Pad3_4', 'Pad3_5', 'Pad3_6',
                                'AAGun1', 'AAGun2', 'AAGun3', 'AAGun4', 'TMD1', 'TMD2',
    },
--    LightBone_Left = 'Light_03',
--    LightBone_Right = 'Light_02',

    OnCreate = function(self, unit)
        NSeaUnit.OnCreate(self, unit)

        self.OpenAnimManips = {}
        local n=1
        for i=1, 3 do  -- change the number of loops to control the number of pads used, max 3 and min 1
            self.OpenAnimManips[n] = CreateAnimator(self):PlayAnim('/units/xns0303/xns0303_OpenPad'..i..'.sca'):SetRate(0)
            self.OpenAnimManips[n]:SetAnimationFraction(0)
            self.Trash:Add(self.OpenAnimManips[n] )
            n = n + 1
        end
    end,
    
    
    DisableIntelOfCargo = function (self, AircraftCarrier)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        AircraftCarrier.OnStopBeingBuilt(self, builder, layer)
        ExternalFactoryComponent.OnStopBeingBuilt(self, builder, layer)
        ChangeState(self, self.IdleState)
    end,

    OnUnitAddedToStorage = function(self, unit)
        NSeaUnit.OnUnitAddedToStorage(self, unit)
    end,

    OnUnitRemovedFromStorage = function(self, unit)
        NSeaUnit.OnUnitRemovedFromStorage(self, unit)

        self:PlayAllOpenAnims(true)
        self:AutoClose()
    end,

    AutoClose = function(self)
        if self.AutoCloseThreadHandle then
            KillThread(self.AutoCloseThreadHandle)
            self.AutoCloseThreadHandle = nil
        end

        local fn = function(self, timeout)
            WaitSeconds(timeout)
            self:PlayAllOpenAnims(false)
        end
        self.AutoCloseThreadHandle = self:ForkThread( fn, 2 )
    end,

    PlayAllOpenAnims = function(self, open)
        for k, v in self.OpenAnimManips do
            if open then
                v:SetRate(5)
            else
                v:SetRate(-1)
            end
        end
    end,

    OnFailedToBuild = function(self)
        NSeaUnit.OnFailedToBuild(self)
        ChangeState(self, self.IdleState)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        AircraftCarrier.OnKilled(self, instigator, type, overkillRatio)
        ExternalFactoryComponent.OnKilled(self, instigator, type, overkillRatio)
    end,
	
	OnLayerChange = function(self)
        OnLayerChange = NSeaUnit.OnLayerChange
    end,

    IdleState = State {
        Main = function(self)
            self:DetachAll(self.BuildAttachBone)
            self:SetBusy(false)
            self:OnIdle()
        end,

        OnStartBuild = function(self, unitBuilding, order)
            NSeaUnit.OnStartBuild(self, unitBuilding, order)
            self.UnitBeingBuilt = unitBuilding
            ChangeState(self, self.BuildingState)
        end,
    },

    BuildingState = State {
        Main = function(self)
            self:SetBusy(true)
            self:DetachAll( self.BuildAttachBone )
            self.UnitBeingBuilt:HideBone( 0, true )
            self.UnitDoneBeingBuilt = false
        end,

        OnStopBuild = function(self, unitBeingBuilt)
            NSeaUnit.OnStopBuild(self, unitBeingBuilt)
            ExternalFactoryComponent.OnStopBuildWithStorage(self, unitBeingBuilt)
            ChangeState(self, self.FinishedBuildingState)
        end,
    },

    FinishedBuildingState = State {
        Main = function(self)
            self:SetBusy(true)
            self.UnitBeingBuilt:DetachFrom(true)
            self:DetachAll(self.BuildAttachBone)
            if self:TransportHasAvailableStorage() then
                self:AddUnitToStorage( self.UnitBeingBuilt )
            else
                local worldPos = self:CalculateWorldPositionFromRelative( {0, 0, -20} )
                Warp( self.UnitBeingBuilt, self:GetPosition( self.BuildAttachBone ), self.UnitBeingBuilt:GetOrientation() )
                IssueMoveOffFactory( { self.UnitBeingBuilt, }, worldPos )
                self.UnitBeingBuilt:ShowBone( 0, true )
            end

            self:SetBusy(false)
            self:RequestRefreshUI()
            ChangeState(self, self.IdleState)
        end,
    },
}

TypeClass = XNS0303