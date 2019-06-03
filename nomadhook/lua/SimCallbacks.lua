LetterArray["Nomads"] = "xn"



Callbacks.ActivateCapacitor = function(data, units)
    for _, u in units or {} do
        if IsEntity(u) and OkayToMessWithArmy(u:GetArmy()) and u.Sync.HasCapacitorAbility then
            --run the function for the state the capacitor is in.
            if u.Sync.CapacitorState then
                u.CapacitorSwitchStates[u.Sync.CapacitorState](u)
                continue
            else
                WARN('Nomads: could not determine capacitor state correctly!')
            end
        end
    end
end

Callbacks.AutoCapacitor = function(data, units)
    for _, u in units or {} do
        if IsEntity(u) and OkayToMessWithArmy(u:GetArmy()) and u.SetAutoCapacitor then
            u:SetAutoCapacitor(data.auto == true)
        end
    end
end
