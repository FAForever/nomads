do


local oldOnSync = OnSync
function OnSync()
    oldOnSync()

    for k, v in Sync.AddSpecialAbility do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/ui/ability_panel/abilities.lua').AddSpecialAbility(v)
        end
    end
    for k, v in Sync.RemoveSpecialAbility do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/ui/ability_panel/abilities.lua').RemoveSpecialAbility(v)
        end
    end

    for k, v in Sync.EnableSpecialAbility do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/ui/ability_panel/abilities.lua').EnableSpecialAbility(v)
        end
    end
    for k, v in Sync.DisableSpecialAbility do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/ui/ability_panel/abilities.lua').DisableSpecialAbility(v)
        end
    end

    for k, v in Sync.StartAbilityCoolDown do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/ui/ability_panel/abilities.lua').DisableButtonStartCoolDown(v.AbilityName)
        end
    end
    for k, v in Sync.StopAbilityCoolDown do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/ui/ability_panel/abilities.lua').EnableButtonStopCoolDown(v.AbilityName)
        end
    end

    for k, v in Sync.RemoveStaticDecal do
        local army = v.Army
        if army == GetFocusArmy() and v['DecalKeys'] then
            local decalKeys = v['DecalKeys']
            local views = import('/lua/ui/game/worldview.lua').GetWorldViews()
            for k, view in views do
                if decalKeys[ k ] then
                    view:RemoveStaticAbilityDecal( decalKeys[ k ] )
                end
            end
        end
    end

    for k, v in Sync.SetAbilityUnits do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/user/tasks/Tasks.lua').SetAbilityUnits( v.AbilityName, army, v.UnitIds )
        end
    end
    for k, v in Sync.SetAbilityRangeCheckUnits do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/user/tasks/Tasks.lua').SetAbilityRangeCheckUnits( v.AbilityName, army, v.UnitIds )
        end
    end

    for k, v in Sync.VOUnitEvents do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/ui/game/voiceovers.lua').VOUnitEvent(v.UnitId, v.Event)
        end
    end

	for k, v in Sync.VOEvents do
        local army = v.Army
        if army == GetFocusArmy() then
            import('/lua/ui/game/voiceovers.lua').VOUIEvent(v.Event)
        end
    end
end



end
