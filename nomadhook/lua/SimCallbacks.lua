LetterArray["Nomads"] = "xn"

Callbacks.ActivateCapacitor = function(data, units)
    for _, u in units or {} do
        if IsEntity(u) and OkayToMessWithArmy(u:GetArmy()) and u.Sync.HasCapacitorAbility then
            --active
            if u:IsCapActive() then
                continue
            end
            --charged
            if u:IsCapCharged() then
                u:TryToActivateCapacitor()
                continue
            end
            --charging
            if u:IsCapCharging() then
                u:PauseCharging()
                continue
            end
            --paused
            if u:IsCapPaused() then
                u:StartCharging()
                continue
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
