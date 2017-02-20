-- T1 Air scout

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local SupportingArtilleryAbility = import('/lua/nomadsutils.lua').SupportingArtilleryAbility

INA1001 = Class(SupportingArtilleryAbility(NAirUnit)) {
    DestructionPartsLowToss = {'INA1001'},
    DestroySeconds = 7.5,
}

TypeClass = INA1001