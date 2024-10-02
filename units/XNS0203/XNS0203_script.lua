local NSubUnit = import('/lua/nomadsunits.lua').NSubUnit
local TorpedoWeapon1 = import('/lua/nomadsweapons.lua').TorpedoWeapon1

--- Tech 1 Submarine
---@class XNS0203 : NSubUnit
XNS0203 = Class(NSubUnit) {
    Weapons = {
        Torpedo01 = Class(TorpedoWeapon1) {},
    },
}
TypeClass = XNS0203