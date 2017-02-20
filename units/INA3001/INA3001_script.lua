-- T3 spy plane

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local SupportingArtilleryAbility = import('/lua/nomadsutils.lua').SupportingArtilleryAbility

INA3001 = Class(SupportingArtilleryAbility(NAirUnit)) {}

TypeClass = INA3001