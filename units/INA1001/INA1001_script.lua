-- t1 air scout

local NAirUnit = import('/lua/nomadunits.lua').NAirUnit

INA1001 = Class(NAirUnit) {
    DestructionPartsLowToss = {'INA1001'},
    DestroySeconds = 7.5,
}

TypeClass = INA1001