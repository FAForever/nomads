-- civilian vehicle

local AddLights = import('/lua/nomadutils.lua').AddLights
local NLandUnit = import('/lua/nomadunits.lua').NLandUnit

NLandUnit = AddLights(NLandUnit)

INU9001 = Class(NLandUnit) {
--    KickupBones = {'Kickup_R','Kickup_L'},
    LightBones = { {'Antenna',}, },
}

TypeClass = INU9001