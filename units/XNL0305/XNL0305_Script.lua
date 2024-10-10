local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local PlasmaCannon = import('/lua/nomadsweapons.lua').PlasmaCannon

--- Tech 3 Tank
---@class XNL0305 : NLandUnit
XNL0305 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(PlasmaCannon) {},
    },
}
TypeClass = XNL0305