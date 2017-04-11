do


local Factions = import('/lua/factions.lua').Factions
local FactionInUnitBpToKey = import('/lua/factions.lua').FactionInUnitBpToKey


function buildActionTemplate(modifier)
  local options = Prefs.GetFromCurrentProfile('options')
  -- Reset everything that could be fading or running  
  -- LOG("BAT")
  hideCycleMap()

  -- find all avaiable templates
  local effectiveTemplates = {}
  local effectiveIcons = {}
  local allTemplates = Templates.GetTemplates()

  if (not allTemplates) or table.getsize(allTemplates) == 0 then
    return
  end
  
  local selection = GetSelectedUnits()
  local availableOrders,  availableToggles, buildableCategories = GetUnitCommandData(selection)
  local buildableUnits = EntityCategoryGetUnitList(buildableCategories)
  --Allow all races to build other races templates
-- Brute51: You wish! Should never hardcode factions like this, ever!

--  local currentFaction = selection[1]:GetBlueprint().General.FactionName
--  if options.gui_all_race_templates ~= 0 and currentFaction then
--    local function ConvertID(BPID)
--      local prefixes = {
--        ["AEON"]     = {"uab", "xab", "dab",},
--        ["UEF"]      = {"ueb", "xeb", "deb",},
--        ["CYBRAN"]   = {"urb", "xrb", "drb",},
--        ["SERAPHIM"] = {"xsb", "usb", "dsb",},
--      }
--      for i, prefix in prefixes[string.upper(currentFaction)] do
--        if table.find(buildableUnits, string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")) then
--          return string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")
--        end
--      end
--      return false
--    end

-- Brute51: this part of the code is pretty much a copy of GAZ-UI construction.lua. Copying the same code to fix the hardcoding in that
-- mod to here, with a minor change to the IF.

                local unitFactionName = selection[1]:GetBlueprint().General.FactionName
                local currentFaction = Factions[ FactionInUnitBpToKey[unitFactionName] ]

                if options.gui_all_race_templates ~= 0 and currentFaction then

                    local function ConvertID(BPID)
                        local prefixes = currentFaction.GAZ_UI_Info.BuildingIdPrefixes or {}
                        for k, prefix in prefixes do
                            if table.find(buildableUnits, string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")) then
                                return string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")
                            end
                        end
                        return false
                    end


    for templateIndex, template in allTemplates do
      local valid = true
      local converted = false
      for _, entry in template.templateData do
        if type(entry) == 'table' then
          if not table.find(buildableUnits, entry[1]) then
            entry[1] = ConvertID(entry[1])
            converted = true
            if not table.find(buildableUnits, entry[1]) then
              valid = false
              break
            end
          end
        end
      end
      if valid then
        if converted then
          template.icon = ConvertID(template.icon)
        end
        template.templateID = templateIndex
        table.insert(effectiveTemplates, template)
		  table.insert(effectiveIcons, template.icon)
      end
    end
  else
    for templateIndex, template in allTemplates do
      local valid = true
      for _, entry in template.templateData do
        if type(entry) == 'table' then
          if not table.find(buildableUnits, entry[1]) then
            valid = false
            break
          end
        end
      end
      if valid then
        template.templateID = templateIndex
        table.insert(effectiveTemplates, template)
		    table.insert(effectiveIcons, template.icon)
      end
    end
  end
  
  local maxPos = table.getsize(effectiveTemplates)
  if (maxPos == 0) then
    return
  end
  
  -- Check if the selection/key has changed
  if ((cycleLastName == '_templates') and (cycleLastMaxPos == maxPos)) then
    cyclePos = cyclePos + 1
    if(cyclePos > maxPos) then
      cyclePos = 1
    end
  else
    initCycleButtons(effectiveIcons)
    cyclePos = 1
    cycleLastName = '_templates'
    cycleLastMaxPos = maxPos
  end
  
  
  if (options.hotbuild_cycle_preview == 1) then
    -- Highlight the active button
    for i, button in cycleButtons do
      if (i == cyclePos) then
        button:SetAlpha(1, true)
      else
        button:SetAlpha(0.4, true)
      end
    end
  
    cycleMap:Show()
    -- Start the fading thread  
    cycleThread = ForkThread(function()
		stayTime = options.hotbuild_cycle_reset_time / 2000.0;
		fadeTime = options.hotbuild_cycle_reset_time / 2000.0;
		
        WaitSeconds(stayTime)
        if (not cycleMap:IsHidden()) then
          Effect.FadeOut(cycleMap, fadeTime, 0.6, 0.1)
        end
        WaitSeconds(fadeTime)
        cyclePos = 0
      end)
  else
      cycleThread = ForkThread(function()
		WaitSeconds(options.hotbuild_cycle_reset_time / 1000.0);
        cyclePos = 0
      end)
  end
    
  local template = effectiveTemplates[cyclePos]
  local cmd = template.templateData[3][1]

  -- LOG("BAT cmd: " .. cmd .. " tplD: " .. repr(template.templateData))

  ClearBuildTemplates()
  CommandMode.StartCommandMode("build", {name = cmd})
  SetActiveBuildTemplate(template.templateData)

  if options.gui_template_rotator ~= 0 then
    -- rotating templates
    local worldview = import('/lua/ui/game/worldview.lua').viewLeft
    local oldHandleEvent = worldview.HandleEvent
    worldview.HandleEvent = function(self, event)
        if event.Type == 'ButtonPress' then
            if event.Modifiers.Middle then
                ClearBuildTemplates()
                local tempTemplate = table.deepcopy(template.templateData)
                for i = 3, table.getn(template.templateData) do
                    local index = i
                    template.templateData[index][3] = 0 - tempTemplate[index][4]
                    template.templateData[index][4] = tempTemplate[index][3]
                end
                SetActiveBuildTemplate(template.templateData)
            elseif event.Modifiers.Shift then
            else
                worldview.HandleEvent = oldHandleEvent
            end
        end
    end
  end

end


end