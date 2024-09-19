local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local KineticCannon1 = import('/lua/nomadsweapons.lua').KineticCannon1

--- Tech 2 Point Defence
---@class XNB2301: NStructureUnit
XNB2301 = Class(NStructureUnit) {
    Weapons = {
        MainGun = Class(KineticCannon1) {
            FxMuzzleScale = 1,
        },
    },
}
TypeClass = XNB2301