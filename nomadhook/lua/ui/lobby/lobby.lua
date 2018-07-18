
for k, v in FactionData.Factions do
    if not table.find( FACTION_NAMES, v.Key ) then
        table.insert( FACTION_NAMES, table.getn(FACTION_NAMES), v.Key )
    end
end



-- Faction selector
function CreateUI_Faction_Selector(lastFaction)
    -- Build a list of button objects from the list of defined factions. Each faction will use the
    -- faction key as its RadioButton texture path offset.
    local buttons = {}
    for i, faction in FactionData.Factions do
        buttons[i] = {
            texturePath = faction.Key
        }
    end

    -- Special-snowflaking for the random faction.
    table.insert(buttons, {
        texturePath = "random"
    })

    local factionSelector = RadioButton(GUI.panel, "/factionselector/", buttons, lastFaction, true)
    GUI.factionSelector = factionSelector
    LayoutHelpers.AtLeftTopIn(factionSelector, GUI.panel, 383, 20)
    factionSelector.OnChoose = function(self, targetFaction, key)
        local localSlot = FindSlotForID(localPlayerID)
        local slotFactionIndex = GetSlotFactionIndex(targetFaction)
        Prefs.SetToCurrentProfile('LastFaction', targetFaction)
        GUI.slots[localSlot].faction:SetItem(slotFactionIndex)
        SetPlayerOption(localSlot, 'Faction', slotFactionIndex)
        gameInfo.PlayerOptions[localSlot].Faction = slotFactionIndex

        RefreshLobbyBackground(targetFaction)
        UIUtil.SetCurrentSkin(FACTION_NAMES[targetFaction])
    end

    -- Only enable all buttons incase all the buttons are disabled, to avoid overriding partially disabling of the buttons
    factionSelector.Enable = function(self)
        for k, v in self.mButtons do
            if v._controlState == "up" then
                return
            end
        end
        for k, v in self.mButtons do
            v:Enable()
        end
    end

    factionSelector.SetCheck = function(self, index)
        for i,button in self.mButtons do
            if index ==i then
                button:SetCheck(true)
            else
                button:SetCheck(false)
            end
        end
        self.mCurSelection = index
    end

    factionSelector.EnableSpecificButtons = function(self, specificButtons)
        for i,button in self.mButtons do
            if specificButtons[i] then
                button:Enable()
            else
                button:Disable()
            end
        end
    end
end

function UpdateFactionSelectorForPlayer(playerInfo)
    if playerInfo.OwnerID == localPlayerID then
        UpdateFactionSelector()
    end
end

function UpdateFactionSelector()
    local playerSlotID = FindSlotForID(localPlayerID)
    local playerSlot = GUI.slots[playerSlotID]
    if not playerSlot or not playerSlot.AvailableFactions or gameInfo.PlayerOptions[playerSlotID].Ready then
        UIUtil.setEnabled(GUI.factionSelector, false)
        return
    end
    local enabledList = {}
    for index,button in GUI.factionSelector.mButtons do
        enabledList[index] = false
        for i,value in playerSlot.AvailableFactions do
            if value == allAvailableFactionsList[index] then
                if gameInfo.PlayerOptions[playerSlotID].Faction == i then
                    GUI.factionSelector:SetCheck(index)
                end
                enabledList[index] = true
                break
            end
        end
    end
    GUI.factionSelector:EnableSpecificButtons(enabledList)
end