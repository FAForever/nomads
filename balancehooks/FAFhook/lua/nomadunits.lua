do


local DefaultUnitsFile = import('/lua/defaultunits.lua')
local AirTransport = DefaultUnitsFile.AirTransport

NAirTransportUnit = Class(AirTransport) {
    BeamExhaustCruise = NomadEffectTemplate.AirThrusterCruisingBeam,
    BeamExhaustIdle = NomadEffectTemplate.AirThrusterIdlingBeam,
}



end