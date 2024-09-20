local AddNavalLights = import('/lua/nomadsutils.lua').AddNavalLights
local NSeaUnit = import('/lua/nomadsunits.lua').NSeaUnit
local RocketWeapon1 = import('/lua/nomadsweapons.lua').RocketWeapon1
local EnergyCannon1 = import('/lua/nomadsweapons.lua').EnergyCannon1

NSeaUnit = AddNavalLights(NSeaUnit)

--- Tech 2 Cruiser
---@class XNS0202 : NSeaUnit
XNS0202 = Class(NSeaUnit) {
    Weapons = {
        AATurret = Class(RocketWeapon1) {},
        GunTurret = Class(EnergyCannon1) {},
    },

    LightBone_Left = 'Light2',
    LightBone_Right = 'Light1',
    DestructionTicks = 200,
}
TypeClass = XNS0202