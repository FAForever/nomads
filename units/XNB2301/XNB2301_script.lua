-- T2 PD

local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local KineticCannon1 = import('/lua/nomadsweapons.lua').KineticCannon1

XNB2301 = Class(NStructureUnit) {
    Weapons = {
        MainGun = Class(KineticCannon1) {
            FxMuzzleScale = 1,
        },
    },
}

TypeClass = XNB2301
