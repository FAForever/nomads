-- T3 spy plane

local NAirUnit = import('/lua/nomadsunits.lua').NAirUnit
local SupportingArtilleryAbility = import('/lua/nomadsutils.lua').SupportingArtilleryAbility

XNA0302 = Class(SupportingArtilleryAbility(NAirUnit)) {}

TypeClass = XNA0302