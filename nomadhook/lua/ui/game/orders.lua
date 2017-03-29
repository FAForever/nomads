do


function AddAbilityButtons(standardOrdersTable, availableOrders, units)
    --Look for units in the selection that have special ability buttons
    --If any are found, add the ability information to the standard order table
    if units and categories.ABILITYBUTTON and EntityCategoryFilterDown(categories.ABILITYBUTTON, units) then
        for index, unit in units do
            local tempBP = UnitData[unit:GetEntityId()]
            if tempBP.Abilities then
                for abilityIndex, ability in tempBP.Abilities do
                    if ability.Active ~= false then
                        table.insert(availableOrders, abilityIndex)
                        standardOrdersTable[abilityIndex] = table.merged(ability, import('/lua/abilitydefinition.lua').abilities[abilityIndex])
                        standardOrdersTable[abilityIndex].behavior = AbilityButtonBehavior
                    end
                end
            end
        end
    end
end

-- creates the buttons for the alt orders, placing them as possible
local function CreateAltOrders(availableOrders, availableToggles, units)
-- TODO? it would indeed be easier if the alt orders slot was in the blueprint, but for now try
-- to determine where they go by using preferred slots
    AddAbilityButtons(standardOrdersTable, availableOrders, units)

    local assitingUnitList = {}
    local podUnits = {}
    if table.getn(units) > 0 and (EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units) or EntityCategoryFilterDown(categories.POD, units)) then
        local PodStagingPlatforms = EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units)
        local Pods = EntityCategoryFilterDown(categories.POD, units)
        local assistingUnits = {}
        if table.getn(PodStagingPlatforms) == 0 and table.getn(Pods) == 1 then
            assistingUnits[1] = Pods[1]:GetCreator()
            podUnits['DroneL'] = Pods[1]
            podUnits['DroneR'] = Pods[2]
        elseif table.getn(PodStagingPlatforms) == 1 then
            assistingUnits = GetAssistingUnitsList(PodStagingPlatforms)
            podUnits['DroneL'] = assistingUnits[1]
            podUnits['DroneR'] = assistingUnits[2]
        end
        if assistingUnits[1] then
            table.insert(availableOrders, 'DroneL')
            assitingUnitList['DroneL'] = assistingUnits[1]
        end
        if assistingUnits[2] then
            table.insert(availableOrders, 'DroneR')
            assitingUnitList['DroneR'] = assistingUnits[2]
        end
    end

    -- determine what slots to put alt orders
    -- we first want a table of slots we want to fill, and what orders want to fill them
    local desiredSlot = {}
    local usedSpecials = {}
    for index, availOrder in availableOrders do
        if standardOrdersTable[availOrder] then
            local preferredSlot = standardOrdersTable[availOrder].preferredSlot
            if not desiredSlot[preferredSlot] then
                desiredSlot[preferredSlot] = {}
            end
            table.insert(desiredSlot[preferredSlot], availOrder)
        else
            if specialOrdersTable[availOrder] ~= nil then
                specialOrdersTable[availOrder].behavior()
                usedSpecials[availOrder] = true
            end
        end
    end

    for index, availToggle in availableToggles do
        if standardOrdersTable[availToggle] then
            local preferredSlot = standardOrdersTable[availToggle].preferredSlot
            if not desiredSlot[preferredSlot] then
                desiredSlot[preferredSlot] = {}
            end
            table.insert(desiredSlot[preferredSlot], availToggle)
        else
            if specialOrdersTable[availToggle] ~= nil then
                specialOrdersTable[availToggle].behavior()
                usedSpecials[availToggle] = true
            end
        end
    end

    for i, specialOrder in specialOrdersTable do
        if not usedSpecials[i] and specialOrder.notAvailableBehavior then
            specialOrder.notAvailableBehavior()
        end
    end

    -- now go through that table and determine what doesn't fit and look for slots that are empty
    -- since this is only alt orders, just deal with slots 7-12
    local orderInSlot = {}

    -- go through first time and add all the first entries to their preferred slot
    for slot = firstAltSlot,numSlots do
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
    --LOG(repr(availableOrders), repr(orderInSlot), repr(slotForOrder))

    -- create the alt order buttons
    for index, availOrder in availableOrders do
        if not standardOrdersTable[availOrder] then continue end   -- skip any orders we don't have in our table
        if not commonOrders[availOrder] then
            local orderInfo = standardOrdersTable[availOrder] or AbilityInformation[availOrder]
            local orderCheckbox = AddOrder(orderInfo, slotForOrder[availOrder], true)

            orderCheckbox._order = availOrder

            if standardOrdersTable[availOrder].script then
                orderCheckbox._script = standardOrdersTable[availOrder].script
            end

            if assitingUnitList[availOrder] then
                orderCheckbox._unit = assitingUnitList[availOrder]
            end

            if podUnits[availOrder] then
                orderCheckbox._pod = podUnits[availOrder]
            end

            if orderInfo.initialStateFunc then
                orderInfo.initialStateFunc(orderCheckbox, currentSelection)
            end

            orderCheckboxMap[availOrder] = orderCheckbox
        end
    end

    for index, availToggle in availableToggles do
        if not standardOrdersTable[availToggle] then continue end   -- skip any orders we don't have in our table
        if not commonOrders[availToggle] then
            local orderInfo = standardOrdersTable[availToggle] or AbilityInformation[availToggle]
            local orderCheckbox = AddOrder(orderInfo, slotForOrder[availToggle], true)

            orderCheckbox._order = availToggle

            if standardOrdersTable[availToggle].script then
                orderCheckbox._script = standardOrdersTable[availToggle].script
            end

            if assitingUnitList[availToggle] then
                orderCheckbox._unit = assitingUnitList[availToggle]
            end

            if orderInfo.initialStateFunc then
                orderInfo.initialStateFunc(orderCheckbox, currentSelection)
            end

            orderCheckboxMap[availToggle] = orderCheckbox
        end
    end
end




end
