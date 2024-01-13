local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Grid = import('/lua/maui/grid.lua').Grid
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')
local TooltipInfo = import('/lua/ui/help/tooltips.lua')
local Prefs = import('/lua/user/prefs.lua')
local Keymapping = import('/lua/keymap/defaultKeyMap.lua').defaultKeyMap
local CM = import('/lua/ui/game/commandmode.lua')
local UIMain = import('/lua/ui/uimain.lua')
--TODO: rename the tasks file to something else, or possibly remove it entirely
TasksFile = import( '/lua/user/tasks/Tasks.lua' )

local VoiceOvers = import('/lua/ui/game/voiceovers.lua')
local AbilityDefinition = import('/lua/abilitydefinition.lua').abilities

local oldCheckbox = import('/lua/maui/checkbox.lua').Checkbox
local Checkbox = Class( oldCheckbox ) {

    HandleEvent = function(self, event)
        -- modified to also pass on what button was used and in what way
        if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            self:OnClick(event.Modifiers, event.Type, event.KeyCode)
            if self.mClickCue ~= "NO_SOUND" then
                if self.mClickCue then
                    local sound = Sound({Cue = self.mClickCue, Bank = "Interface",})
                    PlaySound(sound)
                end
            end
            eventHandled = true
        else
            oldCheckbox.HandleEvent(self, event)
        end
    end,
}

controls = {
    mouseoverDisplay = false,
    orderButtonGrid = false,
    bg = false,
    orderGlow = false,
    NewButtonGlows = {},
    parent = false,
}

-- positioning controls, don't belong to file
local layoutVar = false
local glowThread = {}
local NewGlowThread = {}
savedParent = false
Panel_State = 'closed'

-- these variables control the number of slots available for orders
-- though they are fixed, the code is written so they could easily be made soft
local numSlots = 5
local firstAltSlot = 1
local vertRows = 5
local horzRows = 1

local orderCheckboxMap = false
local FlashTime = 2
local availableOrdersTable = {}
local defaultOrdersTable = {}
local ButtonParams = {}

-- called from gamemain to create control
function SetupOrdersControl(parent)
    controls.parent = parent
    savedParent = parent

    -- create our copy of orders table
    standardOrdersTable = table.deepcopy(defaultOrdersTable)

    SetLayout(UIUtil.currentLayout)

    -- setup command mode behaviors
    CM.AddStartBehavior(
        function(commandMode, data)
            local orderCheckbox = orderCheckboxMap[data]
            if orderCheckbox then
                orderCheckbox:SetCheck(true)
            end
        end
    )

local oldSelection = GetSelectedUnits()

    CM.AddEndBehavior(
        function(commandMode, data)
            local orderCheckbox = orderCheckboxMap[data]
            if orderCheckbox then
                orderCheckbox:SetCheck(false)
            end
        end
    )
end

function SetLayout(layout)
    layoutVar = layout

    -- clear existing orders
    orderCheckboxMap = {}
    if controls and controls.orderButtonGrid then
        controls.orderButtonGrid:DeleteAndDestroyAll(true)
    end

    CreateControls()
    import('/lua/ui/ability_panel/layout/abilities_mini.lua').SetLayout()

    --trigger this, just incase an order is added from the ui or sim on game start
    SetAvailableOrders()
end

function CreateControls()
    --clear any mouse displays we have
    if controls.mouseoverDisplay then
        controls.mouseoverDisplay:Destroy()
        controls.mouseoverDisplay = false
    end

    controls.collapseArrow = Checkbox(savedParent)
    Tooltip.AddCheckboxTooltip(controls.collapseArrow, 'mfd_collapse')
    controls.collapseArrow.OnCheck = function(self, checked)
        ToggleAbilityPanel()
    end

    if not controls.bg then
        controls.bg = Group(savedParent)
    end

    controls.bg.panel = Bitmap(controls.bg)
    controls.bg.leftBrace = Bitmap(controls.bg)
    controls.bg.leftGlow = Bitmap(controls.bg)
    controls.bg.rightGlowTop = Bitmap(controls.bg)
    controls.bg.rightGlowMiddle = Bitmap(controls.bg)
    controls.bg.rightGlowBottom = Bitmap(controls.bg)

    --if not controls.orderButtonGrid then
        CreateOrderButtonGrid()
    --end
end

--button grid
function CreateOrderButtonGrid()
    controls.orderButtonGrid = Grid(controls.bg, GameCommon.iconWidth, GameCommon.iconHeight)
    controls.orderButtonGrid:SetName("Orders Grid")
    controls.orderButtonGrid:DeleteAll()
end

function UpdateSpecialAbilityUI(abilitiesTable, unitAbilitiesTable)
    --store the ability units list for use elsewhere
    TasksFile.UpdateArmyUnitsTable(unitAbilitiesTable)
    --note down abilities to remove
    for abilityName, order in availableOrdersTable do
        if not abilitiesTable[abilityName] then
            SetSpecialAbility(abilityName, 'Remove')
        end
    end
    
    --note down abilities to add or change
    for abilityName, ability in abilitiesTable do
        SetSpecialAbility(abilityName, ability.AvailableNow)
    end
end

function SetSpecialAbility(abilityName, condition)
    if condition == 'Remove' then
        RemoveSpecialAbility({AbilityName = abilityName})
    elseif condition == 0 then
        if not availableOrdersTable[abilityName] then
            AddSpecialAbility({AbilityName = abilityName})
        end
        DisableSpecialAbility({AbilityName = abilityName})
    elseif condition > 0 then
        if not availableOrdersTable[abilityName] then
            AddSpecialAbility({AbilityName = abilityName})
        end
        EnableSpecialAbility({AbilityName = abilityName})
    end
end

--add an ability
function AddSpecialAbility(data)
    local AbilityName = data.AbilityName
    local ability = AbilityDefinition[AbilityName] or false
    local AddAbility = true

    if not controls.orderButtonGrid then
        AddAbility = false
    else
        for orderName,order in availableOrdersTable do
            if orderName == AbilityName then
                AddAbility = false
            end
        end
    end

    if AddAbility and ability then
        ability['Name'] = AbilityName
        availableOrdersTable[AbilityName] = true
        defaultOrdersTable[AbilityName] = ability
        defaultOrdersTable[AbilityName].behavior = AbilityButtonBehavior
        ButtonParams[AbilityName] = { Enabled = true }
        SetAvailableOrders()

        if AbilityDefinition[AbilityName] and AbilityDefinition[AbilityName].SoundReady then
            VoiceOvers.VOUIEvent( AbilityDefinition[AbilityName].SoundReady )
        end
    end
end

--remove an ability
function RemoveSpecialAbility(data)
    local AbilityName = data.AbilityName
    local ability = AbilityDefinition[AbilityName] or false
    local RemoveAbility = false
    local id = false

    for orderName,order in availableOrdersTable do
        if orderName == AbilityName then
            RemoveAbility = true
            id = orderName
        end
    end

    if RemoveAbility then
        availableOrdersTable[id] = nil
        defaultOrdersTable[AbilityName] = nil
        ButtonParams[AbilityName] = nil
        SetAvailableOrders()
    end
end

--enable an ability button on ability panel
function EnableSpecialAbility(data)
    local AbilityName = data.AbilityName
    if orderCheckboxMap[AbilityName] and not ButtonParams[AbilityName].Enabled then
        orderCheckboxMap[AbilityName]:Enable()
        ButtonParams[AbilityName].Enabled = true
        ForkThread(newOrderGlow, orderCheckboxMap[AbilityName])

        if AbilityDefinition[AbilityName] and AbilityDefinition[AbilityName].SoundReady then
            VoiceOvers.VOUIEvent( AbilityDefinition[AbilityName].SoundReady )
        end
    end
end

--disable an ability button on ability panel
function DisableSpecialAbility(data)
    local AbilityName = data.AbilityName
    if orderCheckboxMap[AbilityName] and ButtonParams[AbilityName].Enabled then
        orderCheckboxMap[AbilityName]:Disable()
        ButtonParams[AbilityName].Enabled = false

        if glowThread[AbilityName] then
            KillThread(glowThread[AbilityName])
        end

        if controls.NewButtonGlows[AbilityName] then
            controls.NewButtonGlows[AbilityName]:SetNeedsFrameUpdate(false)
            controls.NewButtonGlows[AbilityName]:Destroy()
            controls.NewButtonGlows[AbilityName] = false
        end

        NewGlowThread[AbilityName] = false
    end
end

--set available orders on the abilities panel
function SetAvailableOrders()

    -- clear existing buttons
    orderCheckboxMap = {}
    if controls.orderButtonGrid then
        controls.orderButtonGrid:DestroyAllItems(true)
    end

    -- create our copy of orders table
    standardOrdersTable = table.deepcopy(defaultOrdersTable)

    --count our buttons
    local numValidOrders = 0
    for orderName,order in availableOrdersTable do
        if standardOrdersTable[orderName] then
            numValidOrders = numValidOrders + 1
        end
    end

    if numValidOrders ~= 0 and numValidOrders <= numSlots then
        CreateAltOrders()
    end

    if controls.orderButtonGrid then
        controls.orderButtonGrid:EndBatch()
    end

    --if no buttons on the panel hide it.
    if numValidOrders == 0 and controls.bg.Mini then
       HideAll()
    elseif controls.bg.Mini then
       ShowAll()
    end
end

--creates the buttons for the alt orders, placing them as possible
--THIS IS IMPORTANT TO REMEMBER -- IF 2 ORDERS ARE SENT IN THE SAME GAME TICK THEY WILL BE PLACED ON THE PANEL AS POSSIBLE
--THIS MEANS IF 2 BUTTONS ARE SENT TO THE PANEL AND THEY BOTH HAVE THE SAME SLOT NUMBER THEY WILL BE PLACED IN SLOTS 1 AND 2
--IF THE 2 BUTTONS ARE SENT IN DIFFERENT GAME TICKS AND THEY BOTH WANT TO GO INTO THE SAME SLOT THEN THE BUTTON IN THE SLOT IS REPLACED BY BUTTON 2.
function CreateAltOrders()

    -- determine what slots to put abilities into
    -- we first want a table of slots we want to fill, and what orders want to fill them
    local desiredSlot = {}
    for orderName,order in availableOrdersTable do
        if standardOrdersTable[orderName] then
            local UISlot = standardOrdersTable[orderName].UISlot
            if not desiredSlot[UISlot] then
                desiredSlot[UISlot] = {}
            end
            table.insert(desiredSlot[UISlot], orderName)
        end
    end

    -- now go through that table and determine what doesn't fit and look for slots that are empty
    -- since this is only alt orders, just deal with slots 7-12
    local orderInSlot = {}

    -- go through first time and add all the first entries to their preferred slot
    for slot = firstAltSlot, numSlots do
        if desiredSlot[slot] then
            orderInSlot[slot] = desiredSlot[slot][1]
        end
    end

    -- now put any additional entries wherever they will fit
    for slot = firstAltSlot,numSlots do
        if desiredSlot[slot] and table.getn(desiredSlot[slot]) > 1 then
            for index, item in desiredSlot[slot] do
                if index > 1 then
                    local foundFreeSlot = false
                    for newSlot = firstAltSlot, numSlots do
                        if not orderInSlot[newSlot] then
                            orderInSlot[newSlot] = item
                            foundFreeSlot = true
                            break
                        end
                    end
                    if not foundFreeSlot then
                        WARN("No free slot for order: " .. item)
                        -- could break here, but don't, then you'll know how many extra orders you have
                    end
                end
            end
        end
    end

    -- now map it the other direction so it's order to slot
    local slotForOrder = {}
    for slot, order in orderInSlot do
        slotForOrder[order] = slot
    end

    -- create the alt order buttons
    --for index, availOrder in availableOrdersTable do
    for orderName,order in availableOrdersTable do
        if not standardOrdersTable[orderName] then continue end   -- skip any orders we don't have in our table
        local orderInfo = standardOrdersTable[orderName] or AbilityInformation[orderName]
        local orderCheckbox = AddOrder(orderInfo, slotForOrder[orderName], true)

        orderCheckbox._order = orderName
--        if standardOrdersTable[orderName].script then
        if standardOrdersTable[orderName].Name then
            orderCheckbox._script = standardOrdersTable[orderName].script
            orderCheckbox._Name = standardOrdersTable[orderName].Name
        end

        orderCheckboxMap[orderName] = orderCheckbox
    end
end

--this function adds the order to the slot AND sets up all the events and effects for the button.
function AddOrder(orderInfo, slot, batchMode)
    batchMode = batchMode or false

    local checkbox = Checkbox(controls.orderButtonGrid, GetOrderBitmapNames(orderInfo.UIBitmapId))
--    local button = orderInfo.script
    local button = orderInfo.Name


    -- set the info in to the data member for retrieval
    checkbox._data = orderInfo

    -- set up initial help text
    checkbox._curHelpText = orderInfo.UIHelpText

    -- set up click handler
    checkbox.OnClick = orderInfo.behavior

    if orderInfo.onframe then
        checkbox.EnableEffect = Bitmap(checkbox, UIUtil.UIFile('/game/orders/glow-02_bmp.dds'))
        LayoutHelpers.AtCenterIn(checkbox.EnableEffect, checkbox)
        checkbox.EnableEffect:DisableHitTest()
        checkbox.EnableEffect:SetAlpha(0)
        checkbox.EnableEffect.Incrimenting = false
        checkbox.EnableEffect.OnFrame = function(self, deltatime)
            local alpha
            if self.Incrimenting then
                alpha = self.Alpha + (deltatime * 2)
                if alpha > 1 then
                    alpha = 1
                    self.Incrimenting = false
                end
            else
                alpha = self.Alpha - (deltatime * 2)
                if alpha < 0 then
                    alpha = 0
                    self.Incrimenting = true
                end
            end
            self.Height:Set(function() return checkbox.Height() + (checkbox.Height() * alpha*.5) end)
            self.Width:Set(function() return checkbox.Height() + (checkbox.Height() * alpha*.5) end)
            self.Alpha = alpha
            self:SetAlpha(alpha*.45)
        end
        checkbox:SetNeedsFrameUpdate(true)
        checkbox.OnFrame = orderInfo.onframe
        checkbox.OnEnable = function(self)
            self.EnableEffect:SetNeedsFrameUpdate(true)
            self.EnableEffect.Incrimenting = false
            self.EnableEffect:SetAlpha(1)
            self.EnableEffect.Alpha = 1
            Checkbox.OnEnable(self)
        end
        checkbox.OnDisable = function(self)
            self.EnableEffect:SetNeedsFrameUpdate(false)
            self.EnableEffect:SetAlpha(0)
            Checkbox.OnDisable(self)
        end
    end

    if not ButtonParams[button].Enabled then
        checkbox:Disable()
    end

    --ok if the button fires a counted projectile weapon (silo).. we can use this to update the number of projectiles
    --you will have to add the function to the orderinfo.ButtonTextFunc in this file.
    if orderInfo.ButtonTextFunc then
        checkbox.buttonText = UIUtil.CreateText(checkbox, '', 18, UIUtil.bodyFont)
        checkbox.buttonText:SetText(orderInfo.ButtonTextFunc(checkbox))
        checkbox.buttonText:SetColor('ffffffff')
        checkbox.buttonText:SetDropShadow(true)
        LayoutHelpers.AtBottomIn(checkbox.buttonText, checkbox)
        LayoutHelpers.AtHorizontalCenterIn(checkbox.buttonText, checkbox)
        checkbox.buttonText:DisableHitTest()
        checkbox.buttonText:SetNeedsFrameUpdate(true)
        checkbox.buttonText.OnFrame = function(self, delta)
            self:SetText(orderInfo.ButtonTextFunc(checkbox))
        end
    end

    -- set up tooltips
    checkbox.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            if controls.orderGlow[button] then
                controls.orderGlow[button]:Destroy()
                controls.orderGlow[button] = false
            end
            CreateMouseoverDisplay(self, self._curHelpText, 1)
            glowThread[button] = CreateOrderGlow(self)
        elseif event.Type == 'MouseExit' then
            if controls.mouseoverDisplay then
                controls.mouseoverDisplay:Destroy()
                controls.mouseoverDisplay = false
            end
            if controls.orderGlow[button] then
                controls.orderGlow[button]:Destroy()
                controls.orderGlow[button] = false
                KillThread(glowThread[button])
            end
        end
        Checkbox.HandleEvent(self, event)
    end

    -- calculate row and column, remove old item, add new checkbox
    local cols, rows = controls.orderButtonGrid:GetDimensions()
    local row = math.ceil(slot / cols)
    local col = math.mod(slot - 1, cols) + 1
    controls.orderButtonGrid:DestroyItem(col, row, batchMode)
    controls.orderButtonGrid:SetItem(checkbox, col, row, batchMode)

    if ButtonParams[button].Enabled then
        ForkThread(newOrderGlow, checkbox)
    end

    return checkbox
end

--mouse over glow
function CreateOrderGlow(parent)

--    local button = parent._data.script
    local button = parent._data.Name
    if controls.NewButtonGlows[button] then
        controls.NewButtonGlows[button]:Destroy()
        controls.NewButtonGlows[button] = false
    end

    controls.orderGlow[button] = Bitmap(parent, UIUtil.UIFile('/game/orders/glow-02_bmp.dds'))
    LayoutHelpers.AtCenterIn(controls.orderGlow[button], parent)
    controls.orderGlow[button]:SetAlpha(0.0)
    controls.orderGlow[button]:DisableHitTest()
    controls.orderGlow[button]:SetNeedsFrameUpdate(true)
    local alpha = 0.0
    local incriment = true
    controls.orderGlow[button].OnFrame = function(self, deltaTime)
        if incriment then
            alpha = alpha + (deltaTime * 1.2)
        else
            alpha = alpha - (deltaTime * 1.2)
        end
        if alpha < 0 then
            alpha = 0.0
            incriment = true
        end
        if alpha > .4 then
            alpha = .4
            incriment = false
        end
        if controls.orderGlow[button] and controls.orderGlow[button].SetAlpha then
            controls.orderGlow[button]:SetAlpha(alpha)
        end
    end
end

--when a new button is added OR enabled make it glow for a while..
function CreateNewAbilityGlow(parent)
--    local button = parent._data.script
    local button = parent._data.Name
    controls.NewButtonGlows[button] = Bitmap(parent, UIUtil.UIFile('/game/orders/glow-02_bmp.dds'))
    LayoutHelpers.AtCenterIn(controls.NewButtonGlows[button], parent)
    controls.NewButtonGlows[button]:SetAlpha(0.0)
    controls.NewButtonGlows[button]:DisableHitTest()
    controls.NewButtonGlows[button]:SetNeedsFrameUpdate(true)
    local alpha = 0.0
    local incriment = true
    local StartTime = GetGameTimeSeconds()
    controls.NewButtonGlows[button].OnFrame = function(self, deltaTime)

        if (GetGameTimeSeconds() - StartTime) > FlashTime and controls.NewButtonGlows[button] and controls.NewButtonGlows[button].SetNeedsFrameUpdate then
            controls.NewButtonGlows[button]:SetNeedsFrameUpdate(false)
        end

        if incriment then
            alpha = alpha + (deltaTime * 1.2)
        else
            alpha = alpha - (deltaTime * 1.2)
        end
        if alpha < 0 then
            alpha = 0.0
            incriment = true
        end
        if alpha > .4 then
            alpha = .4
            incriment = false
        end
        if controls.NewButtonGlows[button] and controls.NewButtonGlows[button].SetAlpha then
            controls.NewButtonGlows[button]:SetAlpha(alpha)
        end
    end
end

--when a new button is added to our panel, make it flash for a few seconds..
function newOrderGlow(parent)
--    local button = parent._data.script
    local button = parent._data.Name
    NewGlowThread[button] = CreateNewAbilityGlow(parent)
    WaitSeconds(FlashTime)

    if controls.NewButtonGlows[button] then
        controls.NewButtonGlows[button]:Destroy()
        controls.NewButtonGlows[button] = false
    end

    --KillThread(NewGlowThread[button])
    NewGlowThread[button] = false
end

--mouse over text we can use the loc system or just plain text.
--obviously the loc system is better.. if you use the loc system make sure you add the loc entries to the loc table.
function CreateMouseoverDisplay(parent, ID)
    if controls.mouseoverDisplay then
        controls.mouseoverDisplay:Destroy()
        controls.mouseoverDisplay = false
    end

    if not Prefs.GetOption('tooltips') then return end

    local createDelay = Prefs.GetOption('tooltip_delay') or 0

    local text = TooltipInfo['Tooltips'][ID]['title'] or ID
    local desc = TooltipInfo['Tooltips'][ID]['description'] or ID

    if TooltipInfo['Tooltips'][ID]['keyID'] and TooltipInfo['Tooltips'][ID]['keyID'] ~= "" then
        for i, v in Keymapping do
            if v == TooltipInfo['Tooltips'][ID]['keyID'] then
                local properkeyname = import('/lua/ui/dialogs/keybindings.lua').formatkeyname(i)
                text = LOCF("%s (%s)", text, properkeyname)
                break
            end
        end
    end

    if not text or not desc then
        return
    end

    controls.mouseoverDisplay = Tooltip.CreateExtendedToolTip(parent, text, desc)
    local Frame = GetFrame(0)
    controls.mouseoverDisplay.Bottom:Set(parent.Top)
    if (parent.Left() + (parent.Width() / 2)) - (controls.mouseoverDisplay.Width() / 2) < 0 then
        controls.mouseoverDisplay.Left:Set(4)
    elseif (parent.Right() - (parent.Width() / 2)) + (controls.mouseoverDisplay.Width() / 2) > Frame.Right() then
        controls.mouseoverDisplay.Right:Set(function() return Frame.Right() - 4 end)
    else
        LayoutHelpers.AtHorizontalCenterIn(controls.mouseoverDisplay, parent)
    end

    local alpha = 0.0
    controls.mouseoverDisplay:SetAlpha(alpha, true)
    local mdThread = ForkThread(function()
        WaitSeconds(createDelay)
        while alpha <= 1.0 do
            controls.mouseoverDisplay:SetAlpha(alpha, true)
            alpha = alpha + 0.1
            WaitSeconds(0.01)
        end
    end)

    controls.mouseoverDisplay.OnDestroy = function(self)
        KillThread(mdThread)
    end
end

-- helper function to create order bitmaps
-- note, your bitmaps must be in /game/orders/ and have the standard button naming convention
function GetOrderBitmapNames(bitmapId)
    if bitmapId == nil then
        LOG("Error - nil bitmap passed to GetOrderBitmapNames")
        bitmapId = "basic-empty"    -- TODO do I really want to default it?
    end

    local button_prefix = "/game/orders/" .. bitmapId .. "_btn_"
    return UIUtil.SkinnableFile(button_prefix .. "up.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "up_sel.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "over.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "over_sel.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "dis.dds")
        ,  UIUtil.SkinnableFile(button_prefix .. "dis_sel.dds")
        , "UI_Action_MouseDown", "UI_Action_Rollover"   -- sets click and rollover cues
end

function GetSelectedUnitIds()
    local units = GetSelectedUnits() or {}
    local ids = {}
    for k, unit in units do
        table.insert( ids, unit:GetEntityId() )
    end
    return ids
end

function GetBehaviour(AbilityName, ClickType, MouseButton)
    if AbilityDefinition[AbilityName] then
        local def = AbilityDefinition[AbilityName]

        if MouseButton == 3 then
            if ClickType == 'ButtonDClick' and def.UIBehaviorDoubleClickRight then
                return def.UIBehaviorDoubleClickRight
            elseif def.UIBehaviorSingleClickRight then
                return def.UIBehaviorSingleClickRight
            end
        elseif ClickType == 'ButtonDClick' and def.UIBehaviorDoubleClick then
            return def.UIBehaviorDoubleClick
        end

        return def.UIBehaviorSingleClick or {}
    else
        LOG('*DEBUG: abilities.lua GetBehavior unknown ability '..repr(AbilityName))
    end
end

-- ability button behaviour
--TODO:sort this out.
function AbilityButtonBehavior(self, modifiers, ClickType, MouseButton)

    local behavior = GetBehaviour(self._script, ClickType, MouseButton)

-- TODO: make ActivateImmediately work
--    if behavior.ActivateImmediately then
        -- bypass the command mode and activate ability immediately
            local modeData = {
                name = 'RULEUCC_Script',
                AbilityName = self._data.abilityname,
                Behaviour = behavior,
                cursor = self._data.cursor,
                OrderIcon = self._data.OrderIcon,
                SelectedUnits = GetSelectedUnitIds(),
                TaskName = self._script,
                Usage = self._data.usage,
            }
            CM.StartCommandMode("order", modeData)
            CM.EndCommandMode(false)

--    else
        if self:IsChecked() then
            CM.EndCommandMode(true)
        else
            local modeData = {
                name = 'RULEUCC_Script',
                AbilityName = self._data.abilityname,
                Behaviour = behavior,
                cursor = self._data.cursor,
                OrderIcon = self._data.OrderIcon,
                SelectedUnits = GetSelectedUnitIds(),
                TaskName = self._script,
                Usage = self._data.usage,
            }
            CM.StartCommandMode("order", modeData)
        end
--    end
end


--controls when the user clicks the toggle to show the ability panel.
function ToggleAbilityPanel(state)
    if import('/lua/ui/game/gamemain.lua').gameUIHidden then
        return
    end
    if UIUtil.GetAnimationPrefs() then
        if state or controls.bg:IsHidden() then
            PlaySound(Sound({Cue = "UI_Score_Window_Open", Bank = "Interface"}))
            controls.bg:Show()
            controls.bg:SetNeedsFrameUpdate(true)
            controls.bg.OnFrame = function(self, delta)
                local newLeft = self.Left() + (1000*delta)
                if newLeft > savedParent.Left()+15 then
                    newLeft = savedParent.Left()+15
                    self:SetNeedsFrameUpdate(false)
                end
                self.Left:Set(newLeft)
            end
            controls.collapseArrow:SetCheck(false, true)
        else
            PlaySound(Sound({Cue = "UI_Score_Window_Close", Bank = "Interface"}))
            controls.bg:SetNeedsFrameUpdate(true)
            controls.bg.OnFrame = function(self, delta)
                local newLeft = self.Left() - (1000*delta)
                if newLeft < savedParent.Left()-self.Width() - 10 then
                    newLeft = savedParent.Left()-self.Width() - 10
                    self:SetNeedsFrameUpdate(false)
                    self:Hide()
                end
                self.Left:Set(newLeft)
            end
            controls.collapseArrow:SetCheck(true, true)
        end
    else
        if state or GUI.bg:IsHidden() then
            controls.bg:Show()
            controls.collapseArrow:SetCheck(false, true)
        else
            controls.bg:Hide()
            controls.collapseArrow:SetCheck(true, true)
        end
    end
end

--open the abilities panel directly
function Open_Panel()
    controls.bg:Show()
    controls.bg:SetNeedsFrameUpdate(true)
    controls.bg.OnFrame = function(self, delta)
        local newLeft = self.Left() + (1000*delta)
        if newLeft > savedParent.Left()+15 then
            newLeft = savedParent.Left()+15
            self:SetNeedsFrameUpdate(false)
        end
        self.Left:Set(newLeft)
    end
    controls.collapseArrow:SetCheck(false, true)
    Panel_State = 'open'
end

--close the abilities panel directly
function Close_Panel()
    controls.bg:Show()
    controls.bg:SetNeedsFrameUpdate(true)
    controls.bg.OnFrame = function(self, delta)
        local newLeft = self.Left() - (1000*delta)
        if newLeft < savedParent.Left()-self.Width() - 10 then
            newLeft = savedParent.Left()-self.Width() - 10
            self:SetNeedsFrameUpdate(false)
            self:Hide()
        end
        self.Left:Set(newLeft)
    end

    controls.collapseArrow:SetCheck(true, true)
    Panel_State = 'closed'
end

--helper function to open the panel
function ShowAll()
    ForkThread(ShowAllThread)
end

function ShowAllThread()
    Open_Panel()
    WaitSeconds(0.2)
    controls.collapseArrow:Show()
end

--helper function to hide the panel.
function HideAll()
    ForkThread(HideAllThread)
end

function HideAllThread()
    Close_Panel()
    WaitSeconds(0.2)
    controls.collapseArrow:SetHidden(true)
end

--not used.
function InitialAnimation()
    controls.bg:Show()
    controls.bg.Left:Set(savedParent.Left()-controls.bg.Width())
    controls.bg:SetNeedsFrameUpdate(true)
    controls.bg.OnFrame = function(self, delta)
        local newLeft = self.Left() + (1000*delta)
        if newLeft > savedParent.Left()+15 then
            newLeft = savedParent.Left()+15
            self:SetNeedsFrameUpdate(false)
        end
        self.Left:Set(newLeft)
    end
    controls.collapseArrow:Show()
    controls.collapseArrow:SetCheck(false, true)
    Panel_State = 'open'
end
