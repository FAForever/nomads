-- T2 destroyer

local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local EnergyCannon1 = import('/lua/nomadsweapons.lua').EnergyCannon1
local TorpedoWeapon1 = import('/lua/nomadsweapons.lua').TorpedoWeapon1

NSeaUnit = AddNavalLights(NSeaUnit)


XNS0201 = Class(NSeaUnit) {
    Weapons = {
        FrontTurret = Class(EnergyCannon1) {},
        RearTurret = Class(EnergyCannon1) {},
        MiniRailgun = Class(TorpedoWeapon1) {
            IdleState = State(TorpedoWeapon1.IdleState) {
                OnGotTarget = function(self)
                    self.unit:ExtendMiniRailguns()
                    TorpedoWeapon1.IdleState.OnGotTarget(self)
                end,

                OnFire = function(self)
                    self.unit:ExtendMiniRailguns()
                    TorpedoWeapon1.IdleState.OnFire(self)
                end,
            },
        },
    },

    DestructionTicks = 200,
    LightBone_Left = 'Antenna.001',
    LightBone_Right = 'Antenna.002',

    OnCreate = function(self)
        NSeaUnit.OnCreate(self)
        self:HideBone('DCTYaw', true)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        NSeaUnit.OnStopBeingBuilt(self, builder, layer)
        self:SetupMiniRailguns()
    end,

    OnMotionHorzEventChange = function( self, new, old )
        NSeaUnit.OnMotionHorzEventChange( self, new, old )
        if old == 'Stopped' then
            self:ContractMiniRailguns()
        end
    end,

    SetupMiniRailguns = function(self)
        local bp = self:GetBlueprint()
        if bp.Display.MiniRailgunsExtend then
            local speed = 20
            self.RailgunExt = {
                ['Left'] = CreateSlider(self, 'MiniRailgunLeft_Ext', 0,0,0, speed, true),
                ['Right'] = CreateSlider(self, 'MiniRailgunRight_Ext', 0,0,0, speed, true),
            }
            self.Trash:Add( self.RailgunExt['Left'] )
            self.Trash:Add( self.RailgunExt['Right'] )
            self.RailgunsExtended = false
            self.RailgunsDoExtend = true
        else
            self.RailgunsDoExtend = false
        end
    end,

    ExtendMiniRailguns = function(self)
        if self.RailgunsDoExtend and not self.RailgunsExtended then
            local length = 0.5
            self.RailgunExt['Left']:SetGoal(length, 0, 0)
            self.RailgunExt['Right']:SetGoal(-length, 0, 0)
            self.RailgunsExtended = true
        end
    end,

    ContractMiniRailguns = function(self)
        if self.RailgunsDoExtend and self.RailgunsExtended then
            self.RailgunExt['Left']:SetGoal(0, 0, 0)
            self.RailgunExt['Right']:SetGoal(0, 0, 0)
            self.RailgunsExtended = false
        end
    end,
}

TypeClass = XNS0201
