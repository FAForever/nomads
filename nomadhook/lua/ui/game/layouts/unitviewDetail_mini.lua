
local oldCreate = Create
function Create(parent)
    oldCreate(parent)
    
    local View = import('/lua/ui/game/unitviewDetail.lua').View
    -- Capacitor stat
    if not View.CapacitorStat then
        View.CapacitorStat = CreateStatGroup( View.BG, UIUtil.UIFile('/game/unit_view_icons/capacitor.dds') )
    end
end

local oldSetLayout = SetLayout
function SetLayout()
    oldSetLayout()
    
    local control = import('/lua/ui/game/unitviewDetail.lua').View
    -- Capacitor stat
    LayoutHelpers.RightOf( control.CapacitorStat, control.UpkeepGroup, -2 )
    LayoutHelpers.AtTopIn( control.CapacitorStat, control.UpkeepGroup, 42 )
    control.CapacitorStat.Height:Set(control.CapacitorStat.Label.Height)
    LayoutStatGroup( control.CapacitorStat )
end