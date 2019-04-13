-- T1 pgen

local NEnergyCreationUnit = import('/lua/nomadsunits.lua').NEnergyCreationUnit

XNB1101 = Class(NEnergyCreationUnit) {
    ActiveEffectBone = 'exhaust',
    ActiveEffectTemplateName = 'T1PGAmbient',
}

TypeClass = XNB1101