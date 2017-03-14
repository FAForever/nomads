do

local Prefs = import('/lua/user/prefs.lua')


local oldOnCommandIssued = OnCommandIssued
function OnCommandIssued(command)
    --LOG('OnCommandIssued '..repr(command))

    local OptionValue = Prefs.GetOption('unitsnd_acknowledge')

    if OptionValue == 'simple' then
        for k, v in command.Units do
            local bp = v:GetBlueprint()
            if bp.Audio.UICommandAcknowledge then
                PlaySound(bp.Audio.UICommandAcknowledge)
                break
            end
        end

    elseif OptionValue == 'full' then
        local prio, unit
        for k, v in command.Units do
            local bp = v:GetBlueprint()
            if bp.Audio.UICommandAcknowledge or bp.Audio.UICommandAcknowledgeMultiple then
                local p = bp.General.SelectionPriority or 10
                if not prio or prio == -1 or p < prio then
                    prio = p
                    unit = v
                end
            end
        end
        if unit then
            local bp = unit:GetBlueprint()
            if bp.Audio.UICommandAcknowledgeMultiple then
                local uid = unit:GetEntityId()
                local n = table.getsize(bp.Audio.UICommandAcknowledgeMultiple)
                local k = 1 + math.mod(uid, n)
                local sndTable = bp.Audio.UICommandAcknowledgeMultiple[k]
                PlaySound( Sound(sndTable[ Random(1, table.getsize(sndTable) ) ]) )
            else
                PlaySound(bp.Audio.UICommandAcknowledge)
            end
        end
    end

    return oldOnCommandIssued(command)
end


end