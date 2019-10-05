-- T1 Air scout

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit

XNA0101 = Class(NAirUnit) {
    DestructionPartsLowToss = {0},
    DestroySeconds = 7.5,
}

TypeClass = XNA0101