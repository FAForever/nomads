do

statFuncs[6] = function(info, bp)
    if not bp.Abilities.Capacitor and info.shieldRatio > 0 then
        return string.format('%d%%', math.floor(info.shieldRatio*100))
    else
        return false
    end
end
table.insert(statFuncs, function(info, bp)
    if bp.Abilities.Capacitor and info.shieldRatio > 0 then
        return string.format('%d%%', math.floor(info.shieldRatio*100))
    else
        return false
    end
end)

local oldUpdateWindow = UpdateWindow
function UpdateWindow(info)
    oldUpdateWindow(info)
    
    
    controls.capacitorBar:Hide()
    if info.blueprintId ~= 'unknown' then
        local bp = __blueprints[info.blueprintId]
        controls.shieldBar:Hide()
        if info.shieldRatio > 0 then
            if bp.Abilities.Capacitor then
                controls.capacitorBar:Show()
                controls.capacitorBar:SetValue(info.shieldRatio)
            else
                controls.shieldBar:Show()
                controls.shieldBar:SetValue(info.shieldRatio)
            end
        end
    end
end



local oldCreateUI = CreateUI
function CreateUI()
    oldCreateUI()
    controls.capacitorBar = StatusBar(controls.bg, 0, 1, false, false, nil, nil, true)
    
    
    controls.abilityBG = {}
    controls.abilityBG.TL = Bitmap(controls.abilities)
    controls.abilityBG.TR = Bitmap(controls.abilities)
    controls.abilityBG.TM = Bitmap(controls.abilities)
    controls.abilityBG.ML = Bitmap(controls.abilities)
    controls.abilityBG.MR = Bitmap(controls.abilities)
    controls.abilityBG.M = Bitmap(controls.abilities)
    controls.abilityBG.BL = Bitmap(controls.abilities)
    controls.abilityBG.BR = Bitmap(controls.abilities)
    controls.abilityBG.BM = Bitmap(controls.abilities)
end

end