-- civilian vehicle

local AddLights = import('/lua/nomadsutils.lua').AddLights
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit

NLandUnit = AddLights(NLandUnit)

INU9001 = Class(NLandUnit) {
--    KickupBones = {'Kickup_R','Kickup_L'},
    LightBones = { {'Antenna',}, },
}

TypeClass = INU9001