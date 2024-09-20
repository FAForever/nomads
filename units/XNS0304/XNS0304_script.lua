local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSubUnit = import('/lua/nomadsunits.lua').NSubUnit
local TorpedoWeapon1 = import('/lua/nomadsweapons.lua').TorpedoWeapon1
local TacticalMissileWeapon1 = import('/lua/nomadsweapons.lua').TacticalMissileWeapon1

NSubUnit = AddNavalLights(NSubUnit)

--- Tech 3 Strategic Submarine
---@class XNS0304 : NSubUnit
XNS0304 = Class(NSubUnit) {
    Weapons = {
        MissileLauncher1 = Class(TacticalMissileWeapon1) {},
        Torpedo = Class(TorpedoWeapon1) {},
    },

    DeathThreadDestructionWaitTime = 2,
    LightBone_Left = 'Light1',
    LightBone_Right = 'Light2',

    ---@param self XNS0304
    OnCreate = function(self)
        NSubUnit.OnCreate(self)
        -- save weapon ranges to toggle them when under or over water
        local wbp = self:GetWeaponByLabel('MissileLauncher1'):GetBlueprint()
        self.MaxRadiusMissilesUnderWater = wbp.MaxRadiusUnderWater
        self.MaxRadiusMissilesOverWater = wbp.MaxRadius
    end,

    ---@param self XNS0304
    ---@param new VerticalMovementState
    ---@param old VerticalMovementState
    OnLayerChange = function(self, new, old)
        NSubUnit.OnLayerChange(self, new, old)
        local wep = self:GetWeaponByLabel('MissileLauncher1')
        if not wep then return end --technically this is bad for mod support but who is gonna hook this function right :D
        if new == 'Water' then
            wep:ChangeMaxRadius(self.MaxRadiusMissilesOverWater)
        elseif new == 'Sub' or new == 'Seabed' then
            wep:ChangeMaxRadius(self.MaxRadiusMissilesUnderWater)
        end
    end,
}
TypeClass = XNS0304