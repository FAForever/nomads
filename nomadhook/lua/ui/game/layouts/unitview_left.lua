local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

table.insert(iconPositions, {Left = 130, Top = 80}) -- position capacitor icon at shield position
table.insert(iconTextures, UIUtil.UIFile('/game/unit_view_icons/capacitor.dds'))

local oldSetLayout = SetLayout
function SetLayout()
    oldSetLayout()
    
    local controls = import('/lua/ui/game/unitview.lua').controls
    LayoutHelpers.Below(controls.capacitorBar, controls.fuelBar)
    controls.capacitorBar.Width:Set(188)
    controls.capacitorBar.Height:Set(2)
    controls.capacitorBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.capacitorBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/capacitorbar.dds'))
end

function SetBG(controls)
    controls.abilityBG.TL:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ul.dds'))
    controls.abilityBG.TL.Right:Set(controls.abilities.Left)
    controls.abilityBG.TL.Bottom:Set(controls.abilities.Top)
    LayoutHelpers.DepthUnderParent(controls.abilityBG.TL, controls.abilities)
    
    controls.abilityBG.TM:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_horz_um.dds'))
    controls.abilityBG.TM.Right:Set(controls.abilityBG.TL.Right)
    controls.abilityBG.TM.Bottom:Set(function() return controls.abilities.Top() end)
    controls.abilityBG.TM.Left:Set(controls.abilityBG.TR.Left)
    LayoutHelpers.DepthUnderParent(controls.abilityBG.TM, controls.abilities)
    
    controls.abilityBG.TR:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ur.dds'))
    controls.abilityBG.TR.Left:Set(controls.abilities.Right)
    controls.abilityBG.TR.Bottom:Set(controls.abilities.Top)
    LayoutHelpers.DepthUnderParent(controls.abilityBG.TR, controls.abilities)
    
    controls.abilityBG.ML:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_vert_l.dds'))
    controls.abilityBG.ML.Right:Set(controls.abilities.Left)
    controls.abilityBG.ML.Top:Set(controls.abilityBG.TL.Bottom)
    controls.abilityBG.ML.Bottom:Set(controls.abilityBG.BL.Top)
    LayoutHelpers.DepthUnderParent(controls.abilityBG.ML, controls.abilities)
    
    controls.abilityBG.M:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_m.dds'))
    controls.abilityBG.M.Top:Set(controls.abilityBG.TM.Bottom)
    controls.abilityBG.M.Left:Set(controls.abilityBG.ML.Right)
    controls.abilityBG.M.Right:Set(controls.abilityBG.MR.Left)
    controls.abilityBG.M.Bottom:Set(controls.abilityBG.BM.Top)
    LayoutHelpers.DepthUnderParent(controls.abilityBG.M, controls.abilities)
    
    controls.abilityBG.MR:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_vert_r.dds'))
    controls.abilityBG.MR.Left:Set(controls.abilities.Right)
    controls.abilityBG.MR.Top:Set(controls.abilityBG.TR.Bottom)
    controls.abilityBG.MR.Bottom:Set(controls.abilityBG.BR.Top)
    LayoutHelpers.DepthUnderParent(controls.abilityBG.MR, controls.abilities)
    
    controls.abilityBG.BL:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ll.dds'))
    controls.abilityBG.BL.Right:Set(controls.abilities.Left)
    controls.abilityBG.BL.Top:Set(controls.abilities.Bottom)
    LayoutHelpers.DepthUnderParent(controls.abilityBG.BL, controls.abilities)
    
    controls.abilityBG.BM:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_lm.dds'))
    controls.abilityBG.BM.Right:Set(controls.abilityBG.BL.Right)
    controls.abilityBG.BM.Top:Set(function() return controls.abilities.Bottom() end)
    controls.abilityBG.BM.Left:Set(controls.abilityBG.BR.Left)
    LayoutHelpers.DepthUnderParent(controls.abilityBG.BM, controls.abilities)
    
    controls.abilityBG.BR:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_lr.dds'))
    controls.abilityBG.BR.Left:Set(controls.abilities.Right)
    controls.abilityBG.BR.Top:Set(controls.abilities.Bottom)
    LayoutHelpers.DepthUnderParent(controls.abilityBG.BR, controls.abilities)
end