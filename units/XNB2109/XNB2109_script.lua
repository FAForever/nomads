local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local TorpedoWeapon1 = import('/lua/nomadsweapons.lua').TorpedoWeapon1

--- Tech 1 Torpedo Launcher
---@class XNB2109 : NStructureUnit
XNB2109 = Class(NStructureUnit) {
    Weapons = {
        Turret01 = Class(TorpedoWeapon1) {},
    },
}
TypeClass = XNB2109