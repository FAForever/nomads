do

local oldCreateUI = CreateUI
function CreateUI(isReplay)
    oldCreateUI(isReplay)
    if not isReplay then
        import('/lua/ui/ability_panel/abilities.lua').SetupOrdersControl(gameParent)
    end
end

end
