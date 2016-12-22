do

local Prefs = import('/lua/user/prefs.lua')

function PlaySelectionSound(newSelection)

    local OptionValue = Prefs.GetOption('unitsnd_selection')

    if OptionValue == 'simple' then
        for k, v in newSelection do
            local bp = v:GetBlueprint()
            if bp.Audio.UISelection then
                PlaySound(bp.Audio.UISelection)
                break
            end
        end

    elseif OptionValue == 'full' then
        local prio, unit

        # find unit with highest selection sound prio
        for k, v in newSelection do
            local bp = v:GetBlueprint()
            if bp.Audio.UISelection or bp.Audio.UISelectionMultiple then
                local p = bp.General.SelectionPriority or 10
                if not prio or p < prio then
                    prio = p
                    unit = v
                end
            end
        end

        # play selected unit sound. Units with multiple selection sounds get a key derived from their unit id. This way each time you
        # select the unit you get the same voice.
        if unit then
            local bp = unit:GetBlueprint()
            if bp.Audio.UISelectionMultiple then
                local uid = unit:GetEntityId()
                local n = table.getsize(bp.Audio.UISelectionMultiple)
                local k = 1 + math.mod(uid, n)
                local sndTable = bp.Audio.UISelectionMultiple[k]
                PlaySound( Sound(sndTable[ Random(1, table.getsize(sndTable) ) ]) )
            else
                PlaySound(bp.Audio.UISelection)
            end
        end
    end
end



end