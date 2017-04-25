LetterArray["Nomads"] = "in"

Callbacks.ActivateCapacitor = function(data, units)
    for _, u in units or {} do
        WARN("ActivateCapacitor")
        if IsEntity(u) and OkayToMessWithArmy(u:GetArmy()) and u.Sync.HasCapacitorAbility then
            WARN("HasCapacitorAbility")
            --active
            if u:IsCapActive() then
                WARN("IsCapActive")
                continue
            end
            --charged
            if u:IsCapCharged() then
                WARN("IsCharged")
                u:TryToActivateCapacitor()
                continue
            end
            --charging
            if u:IsCapCharging() then
                WARN("IsCharging")
                u:PauseCharging()
                continue
            end
            --paused
            if u:IsCapPaused() then
                WARN("IsPaused")
                u:StartCharging()
                continue
            end
        end
    end
end
Callbacks.AutoCapacitor = function(data, units)
    for _, u in units or {} do
        WARN("AutoCapacitor")
        if IsEntity(u) and OkayToMessWithArmy(u:GetArmy()) and u.SetAutoCapacitor then
            u:SetAutoCapacitor(data.auto == true)
        end
    end
end