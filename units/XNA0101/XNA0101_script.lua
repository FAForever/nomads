-- T1 Air scout

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local SupportingArtilleryAbility = import('/lua/nomadsutils.lua').SupportingArtilleryAbility

XNA0101 = Class(SupportingArtilleryAbility(NAirUnit)) {
    DestructionPartsLowToss = {0},
    DestroySeconds = 7.5,
}

TypeClass = XNA0101