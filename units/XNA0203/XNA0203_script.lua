local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local DroppedTorpedoWeapon1  = import('/lua/nomadsweapons.lua').DroppedTorpedoWeapon1

--- Tech 2 Torpedo Gunship
---@class XNA0203 : NAirUnit
XNA0203 = Class(NAirUnit) {
     Weapons = {
        MainGun = Class(DroppedTorpedoWeapon1) {},
    },
}
TypeClass = XNA0203