LetterArray["Nomads"] = "in"

Callbacks.ActivateCapacitor = function(data, units)
    for _, u in units or {} do
        if IsEntity(u) and OkayToMessWithArmy(u:GetArmy()) and u.Sync.HasCapacitorAbility then
            u:TryToActivateCapacitor()
        end
    end
end