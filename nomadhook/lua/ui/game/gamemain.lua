do

local oldCreateUI = CreateUI
function CreateUI(isReplay)
    oldCreateUI(isReplay)
	if not isReplay then
        import('/lua/ui/ability_panel/abilities.lua').SetupOrdersControl(gameParent)
    end
end

-- if game is paused then pause all special ability cooldown timers on buttons
local oldOnPause = OnPause
function OnPause(pausedBy, timeoutsRemaining)
    oldOnPause(pausedBy, timeoutsRemaining)
    import('/lua/ui/ability_panel/abilities.lua').KillTimers()
end

-- if game is resumed then start the timers again
local oldOnResume = OnResume
function OnResume()
    oldOnResume()
    import('/lua/ui/ability_panel/abilities.lua').RestartTimers()
end

end
