do


local oldOnSync = OnSync
function OnSync()
    oldOnSync()

    for k, v in Sync.UpdateSpecialAbilityUI do
        local army = v.Army
        if army == GetFocusArmy() and v.BrainAbilitiesTable and v.BrainAbilitiesTable then
            import('/lua/ui/ability_panel/abilities.lua').UpdateSpecialAbilityUI(v.BrainAbilitiesTable, v.UnitAbilitiesTable)
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
