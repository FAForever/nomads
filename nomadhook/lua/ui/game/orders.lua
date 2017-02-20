function GetCurrentSelection()
    return currentSelection
end


local oldAddAbilityButtons = AddAbilityButtons
function AddAbilityButtons(standardOrdersTable, availableOrders, units)
    oldAddAbilityButtons(standardOrdersTable, availableOrders, units)
    
    
    if units and categories.ABILITYBUTTON and EntityCategoryFilterDown(categories.ABILITYBUTTON, units) then
        for index, unit in units do
            local tempBP = UnitData[unit:GetEntityId()]
            if tempBP.Abilities then
                for abilityIndex, ability in tempBP.Abilities do
                    if not standardOrdersTable[abilityIndex] then
                        continue
                    end
                    local merge = table.merged(ability, import('/lua/abilitydefinition.lua').abilities[abilityIndex])
                    if merge.behavior then
                        standardOrdersTable[abilityIndex].behavior = merge.behavior
                    end
                        
                    if standardOrdersTable[abilityIndex].AbilityRequirement and not standardOrdersTable[abilityIndex].AbilityRequirement(unit) then
                        standardOrdersTable[abilityIndex] = nil
                    end
                end
            end
        end
    end
end