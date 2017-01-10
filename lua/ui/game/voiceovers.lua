local Factions = import('/lua/factions.lua').Factions
local VoiceOverSounds = import('/lua/ui/game/voiceover_sounds.lua').VOSounds


RequireSelected = {
    ['CapacitorFull'] = true,
    ['CapacitorEmpty'] = true,
    ['IntelBoostInitiated'] = true,
    ['IntelBoostReady'] = true,
    ['IntelProbeLaunched'] = false,
    ['IntelProbeReady'] = false,
    ['OrbitalStrikeLaunched'] = false,
    ['OrbitalStrikeReady'] = false,
}


-- TODO: This can probably be refactored a bit, make a new function out of the similar code below

function VOUIEvent(event)
    if event then
        local armyTable = GetArmiesTable()
        local fac = armyTable.armiesTable[armyTable.focusArmy].faction or 0
        local facStr = Factions[fac + 1].SoundPrefix
        local VOS = VoiceOverSounds[facStr][event]

        if VOS and VOS.Bank and VOS.Cue then
            --LOG('*DEBUG: VOUIEvent Playing VO for event '..repr(event))
            local snd = Sound( {Bank = VOS.Bank, Cue = VOS.Cue} )
            local IsVoice = VOS.IsVoice or false
            if IsVoice then
                local voHandle = PlayVoice( snd )
            else
                local voHandle = PlaySound( snd )
            end
        else
            WARN('*DEBUG: VOUIEvent no sound for event '..repr(event))
        end
    else
        WARN('*DEBUG: VOUIEvent called but required parameter is missing')
    end
end

function VOUnitEvent(unitId, event)
    --LOG('*DEBUG VOUnitEvent event = '..repr(event)..' unit = '..repr(unitId))
    if event and unitId then
        if RequireSelected[event] == false or UnitIsSelected(unitId) then

            local armyTable = GetArmiesTable()
            local facStr = Factions[armyTable.armiesTable[armyTable.focusArmy].faction + 1].SoundPrefix
            local VOS = VoiceOverSounds[facStr][event]

            if VOS and VOS.Bank and VOS.Cue then
                --LOG('*DEBUG: VOUnitEvent Playing VO for event '..repr(event))
                local snd = Sound( {Bank = VOS.Bank, Cue = VOS.Cue} )
                local IsVoice = VOS.IsVoice or false
                if IsVoice then
                    local voHandle = PlayVoice( snd )
                else
                    local voHandle = PlaySound( snd )
                end
            else
                WARN('*DEBUG: VOUnitEvent no sound for event '..repr(event))
            end
        end
    else
        WARN('*DEBUG: VOUnitEvent called but required parameters are missing')
    end
end


function UnitIsSelected(unitId)
    local selection = GetSelectedUnits()
    if selection then
        for k, unit in selection do
            if unit:GetEntityId() == unitId then
                return true
            end
        end
    end
    return false
end



