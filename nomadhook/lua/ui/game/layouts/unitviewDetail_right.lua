do


function Create(parent)
    if not import('/lua/ui/game/unitviewDetail.lua').View then
        import('/lua/ui/game/unitviewDetail.lua').View = Group(parent)
    end
    
    local View = import('/lua/ui/game/unitviewDetail.lua').View
    
    if not View.BG then
        View.BG = Bitmap(View)
    end
    View.BG:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/unit-over-back_bmp.dds'))
    View.BG.Depth:Set(200)
    
    if not View.Bracket then
        View.Bracket = Bitmap(View)
    end
    View.Bracket:DisableHitTest()
    View.Bracket:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/bracket-unit_bmp.dds'))
    
    # Unit icon
    if false then
        View.UnitIcon = Bitmap(View)
    end
    
    if not View.UnitImg then
        View.UnitImg = Bitmap( View.BG )
    end
    
    # Unit Description
    if not View.UnitShortDesc then
        View.UnitShortDesc = UIUtil.CreateText( View.BG, "", 10, UIUtil.bodyFont )
    end
    View.UnitShortDesc:SetColor("FFFF9E06")

    # Cost
    if not View.BuildCostGroup then
        View.BuildCostGroup = CreateResourceGroup(View.BG, "<LOC uvd_0000>Build Cost (Rate)")
    end

    # Upkeep
    if not View.UpkeepGroup then
        View.UpkeepGroup = CreateResourceGroup(View.BG, "<LOC uvd_0002>Yield")
    end
    
    # Health stat
    if not View.HealthStat then
        View.HealthStat = CreateStatGroup( View.BG, UIUtil.UIFile('/game/unit_view_icons/redcross.dds') )
    end
    
    if not View.ShieldStat then
        View.ShieldStat = CreateStatGroup( View.BG, UIUtil.UIFile('/game/unit_view_icons/shield.dds') )
    end

    if not View.CapacitorStat then
        View.CapacitorStat = CreateStatGroup( View.BG, UIUtil.UIFile('/game/unit_view_icons/capacitor.dds') )
    end

    # Tme stat
    if not View.TimeStat then
        View.TimeStat = CreateStatGroup( View.BG, UIUtil.UIFile('/game/unit-over/icon-clock_bmp.dds') )
    end
    
    if not View.TechLevel then
        View.TechLevel = UIUtil.CreateText(View.BG, '', 10, UIUtil.bodyFont)
    end
    View.TechLevel:SetColor("FFFF9E06")
    
    if Prefs.GetOption('uvd_format') == 'full' then
        # Description  "<LOC uvd_0003>Description"
        if not View.Description then
            View.Description = CreateTextbox(View.BG, nil, true)
        end
    else
        if View.Description then View.Description:Destroy() View.Description = false end
    end
    
    View.BG:DisableHitTest(true)
end

function SetLayout()
    local mapGroup = import('/lua/ui/game/unitviewDetail.lua').MapView
    import('/lua/ui/game/unitviewDetail.lua').ViewState = Prefs.GetOption('uvd_format')
    
    Create(mapGroup)
    
    local control = import('/lua/ui/game/unitviewDetail.lua').View

    local OrderGroup = false
    if not SessionIsReplay() then
        OrderGroup = import('/lua/ui/game/orders.lua').controls.bg
    end

    if OrderGroup then
        LayoutHelpers.AtBottomIn(control, control:GetParent(), 140)
        LayoutHelpers.AtLeftIn(control, control:GetParent(), 18)
    else
        LayoutHelpers.AtBottomIn(control, control:GetParent(), 140)
        LayoutHelpers.AtLeftIn(control, control:GetParent(), 18)
    end
    control.Width:Set( control.BG.Width )
    control.Height:Set( control.BG.Height )
    
    # Main window background
    LayoutHelpers.AtLeftTopIn( control.BG, control )
    
    LayoutHelpers.AtLeftTopIn(control.Bracket, control.BG, -19, -2)
    control.Bracket:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/bracket-unit_bmp.dds'))
    
    if control.bracketMid then
        control.bracketMid:Destroy()
        control.bracketMid = false
    end
    if control.bracketMax then
        control.bracketMax:Destroy()
        control.bracketMax = false
    end
    
    # Unit Image
    LayoutHelpers.AtLeftTopIn( control.UnitImg, control.BG, 12, 36 )
    control.UnitImg.Height:Set(46)
    control.UnitImg.Width:Set(48)
    
    # Tech Level Text
    LayoutHelpers.CenteredBelow(control.TechLevel, control.UnitImg)
    
    # Unit Description
    LayoutHelpers.AtLeftTopIn( control.UnitShortDesc, control.BG, 20, 13 )
    control.UnitShortDesc:SetClipToWidth(true)
    control.UnitShortDesc.Right:Set(function() return control.BG.Right() - 15 end)

    # Time stat
    LayoutHelpers.Below( control.TimeStat, control.UnitImg, 4 )
    LayoutHelpers.AtLeftIn(control.TimeStat, control.UnitImg, -2)
    control.TimeStat.Height:Set(control.TimeStat.Label.Height)
    LayoutStatGroup( control.TimeStat )
    
    # Build Resource Group
    LayoutHelpers.AtLeftTopIn( control.BuildCostGroup, control.BG, 70, 34 )
    control.BuildCostGroup.Width:Set( 115 )
    LayoutResourceGroup( control.BuildCostGroup )
    control.BuildCostGroup.Bottom:Set( function() return control.BuildCostGroup.MassValue.Bottom() + 1 end )

    # Upkeep Resource Group
    LayoutHelpers.RightOf( control.UpkeepGroup, control.BuildCostGroup )
    control.UpkeepGroup.Width:Set( 55 )
    control.UpkeepGroup.Bottom:Set( control.BuildCostGroup.Bottom )
    LayoutResourceGroup( control.UpkeepGroup )
    
    # health stat
    LayoutHelpers.RightOf( control.HealthStat, control.UpkeepGroup )
    LayoutHelpers.AtTopIn( control.HealthStat, control.UpkeepGroup, 22 )
    control.HealthStat.Height:Set(control.HealthStat.Label.Height)
    LayoutStatGroup( control.HealthStat )
    
    # shield stat
    LayoutHelpers.RightOf( control.ShieldStat, control.UpkeepGroup, -2 )
    LayoutHelpers.AtTopIn( control.ShieldStat, control.UpkeepGroup, 42 )
    control.ShieldStat.Height:Set(control.ShieldStat.Label.Height)
    LayoutStatGroup( control.ShieldStat )

    # Capacitor stat
    LayoutHelpers.RightOf( control.CapacitorStat, control.UpkeepGroup, -2 )
    LayoutHelpers.AtTopIn( control.CapacitorStat, control.UpkeepGroup, 42 )
    control.CapacitorStat.Height:Set(control.CapacitorStat.Label.Height)
    LayoutStatGroup( control.CapacitorStat )
    
    if control.Description then
        # Description
        control.Description.Left:Set(function() return control.BG.Right() - 2 end)
        control.Description.Bottom:Set(function() return control.BG.Bottom() - 2 end)
        control.Description.Width:Set(400)
        control.Description.Height:Set(20)
        LayoutTextbox(control.Description)
    end
end


end