
function GetUpkeep(bp)
    -- check for UI unitview overrides
    local plusEnergyRate = bp.Display.UIUnitViewOverrides.ProductionPerSecondEnergy
                            or bp.Economy.ProductionPerSecondEnergy
                            or bp.ProductionPerSecondEnergy
    local negEnergyRate = bp.Display.UIUnitViewOverrides.MaintenanceConsumptionPerSecondEnergy
                            or bp.Economy.MaintenanceConsumptionPerSecondEnergy
                            or bp.MaintenanceConsumptionPerSecondEnergy
    local plusMassRate = bp.Display.UIUnitViewOverrides.ProductionPerSecondMass
                            or bp.Economy.ProductionPerSecondMass
                            or bp.ProductionPerSecondMass
    local negMassRate = bp.Display.UIUnitViewOverrides.MaintenanceConsumptionPerSecondMass
                            or bp.Economy.MaintenanceConsumptionPerSecondMass
                            or bp.MaintenanceConsumptionPerSecondMass

    local upkeepEnergy = GetYield(negEnergyRate, plusEnergyRate)
    local upkeepMass = GetYield(negMassRate, plusMassRate)

    return upkeepEnergy, upkeepMass
end

--hooked to show/hide capacitor
local oldShowView = ShowView
function ShowView(showUpKeep, enhancement, showecon, showShield, showCapacitor)
    oldShowView(showUpKeep, enhancement, showecon, showShield)

    --Can only have capacitor or shield, right?
    if showCapacitor then
        View.ShieldStat:SetHidden(true)
    end

    View.CapacitorStat:SetHidden(not showCapacitor)

end


--hooked to show/hide capacitor
local oldShowEnhancement = ShowEnhancement
function ShowEnhancement(bp, bpID, iconID, iconPrefix, userUnit)
    oldShowEnhancement(bp, bpID, iconID, iconPrefix, userUnit)

    local showShield = true
    local showCapacitor = false
    if bp.CapacitorNewChargeTime or bp.CapacitorNewDuration or bp.CapacitorNewEnergyDrainPerSecond then
        showCapacitor = true
        showShield = false

        local text = ''
        if bp.CapacitorNewDuration then
            text = text .. tostring(bp.CapacitorNewDuration)
        else
            text = text .. '-'
        end
        text = text .. '/'
        if bp.CapacitorNewChargeTime then
            text = text .. tostring(bp.CapacitorNewChargeTime)
        else
            text = text .. '-'
        end
        text = text .. '/'
        if bp.CapacitorNewEnergyDrainPerSecond then
            text = text .. tostring(bp.CapacitorNewEnergyDrainPerSecond)
        else
            text = text .. '-'
        end

        View.CapacitorStat.Value:SetText(text)
    end

    if not showShield then
        View.ShieldStat:SetHidden(true)
    end
    View.CapacitorStat:SetHidden(not showCapacitor)
end

--hooked to show/hide capacitor
local oldShow = Show
function Show(bp, buildingUnit, bpID)
    oldShow(bp, buildingUnit, bpID)

    local showCapacitor = false
    if (bp.Display.UIUnitViewOverrides and bp.Display.UIUnitViewOverrides.CapacitorDuration) or (bp.Abilities.Capacitor and bp.Abilities.Capacitor.Duration) then
        showCapacitor = true
        showShield = false
        local text = ''
        if bp.Display.UIUnitViewOverrides and bp.Display.UIUnitViewOverrides.CapacitorDuration then
            text = tostring(bp.Display.UIUnitViewOverrides.CapacitorDuration)
        else
            text = tostring(bp.Abilities.Capacitor.Duration)
        end
        View.CapacitorStat.Value:SetText(text)
    end


    View.CapacitorStat:SetHidden(not showCapacitor)
end


-- Had to grab this from EQ code since people keep trying to look up stats using the ingame view, and those stats are totally absolutely and completely wrong in FAF.

function WrapAndPlaceText(air, physics, weapons, abilities, text, control)
    local lines = {}
    -- Used to set the line colour correctly.
    local physics_line = -1
    local weapon_start = -1
    if text then
        lines = import('/lua/maui/text.lua').WrapText(text, control.Value[1].Width(),
                function(text) return control.Value[1]:GetStringAdvance(text) end)
    end
    local abilityLines = 0
    if abilities then
        local i = table.getn(abilities)
        while abilities[i] do
            table.insert(lines, 1, LOC(abilities[i]))
            i = i - 1
        end
        abilityLines = table.getsize(abilities)
    end

    if options.gui_render_armament_detail == 1 then
        weapon_start = table.getsize(lines)
        if weapons then
            if table.getn(weapons) > 0 then
                table.insert(lines, "")
            end

            -- Used to count up duplicate weapons.
            local mflag = 0
            for i, weapon in weapons do
                if weapon.WeaponCategory and weapon.WeaponCategory ~= 'Death' then
                    if weapon.DisplayName == weapons[i+1].DisplayName then
                        --EQ: doing it like this fixes the bug where the first set of weapons didn't show correctly in multiples
                        mflag = mflag + 1
                    else
                        if mflag ~= 0 then
                            table.insert(lines, string.format("%s (%s) x%d",
                                weapon.DisplayName,
                                weapon.WeaponCategory,
                                mflag + 1))
                        else
                            table.insert(lines, string.format("%s (%s)", weapon.DisplayName, weapon.WeaponCategory)
                            )
                        end
                        
                        --EQ: this was all SO wrong, had to rewrite the whole thing pretty much
                        
                        if not weapon.NukeWeapon == true then --we might as well have a different type of line for nukes because they are special
                            local trueReload = math.max(0.1*math.floor((10 / weapon.RateOfFire) + 0.5), 0.1) --the rof is rounded to the nearest tick since the game runs in ticks.
                            --some weapons also have separate charge and reload times which results in them firing less often. yeah.
                            --in theory if your total MuzzleSalvoDelay is longer than the reload time your weapon waits for the reload time twice, but thats pretty much a bug so not taken into account here
                            trueReload = math.max((weapon.RackSalvoChargeTime or 0) + (weapon.RackSalvoReloadTime or 0) + (weapon.MuzzleSalvoDelay or 0)*((weapon.MuzzleSalvoSize or 1)-1), trueReload)
                            
                            local trueSalvoSize = 1
                            if weapon.ProjectileUIStatsOverride then
                                trueSalvoSize = weapon.ProjectileUIStatsOverride --This should only be used if there is a projectile script that messes with the number of projectiles.
                            elseif (weapon.MuzzleSalvoDelay or 0) > 0 then --if theres no muzzle delay, all muzzles fire at the same time. yeah.
                                trueSalvoSize = (weapon.MuzzleSalvoSize or 1)
                            elseif weapon.RackBones then --dummy weapons dont have racks
                                if weapon.RackFireTogether == true then
                                    trueSalvoSize = table.getn(weapon.RackBones) * table.getn(weapon.RackBones[1].MuzzleBones)
                                else
                                    trueSalvoSize = table.getn(weapon.RackBones[1].MuzzleBones)
                                end
                            end
                            
                            local trueDamage = weapon.Damage*(weapon.DoTPulses or 1) + (weapon.InitialDamage or 0)
                            --beam weapons are a thing and do their own thing. yeah good luck working out that.
                            trueDamage = math.max((math.floor((weapon.BeamLifetime or 0) / ((weapon.BeamCollisionDelay or 0)+0.1))+1)*weapon.Damage, trueDamage)
                            local salvoDamage = trueSalvoSize * trueDamage
                            local trueDPS = (salvoDamage / trueReload)
                            
                            table.insert(lines, LOCF("<LOC gameui_0001>Damage: %d, Reload time: %0.1f (DPS: %d)  Range: %d",
                                salvoDamage,
                                trueReload,
                                trueDPS,
                                weapon.MaxRadius))
                            
                        else
                            --Nukes have a damage listed as 0 so we do this to make them have real stats.
                            
                            local innerDamage = (weapon.NukeInnerRingDamage or 0) + (weapon.NukeOuterRingDamage or 0)
                            
                            --not localized because this is a mod and its hard to make things compatible incase that string key is changed :<
                            table.insert(lines, LOCF("Damage(Outer): %d(%d), Radius(Outer): %d(%d)",
                                innerDamage,
                                weapon.NukeOuterRingDamage,
                                weapon.NukeInnerRingRadius,
                                weapon.NukeOuterRingRadius))
                            
                        end
                        mflag = 0
                        
                    end
                end
            end
            
        end

        if air and air.MaxAirspeed and air.MaxAirspeed ~=0 then
            table.insert(lines, "")
            table.insert(lines, LOCF("<LOC gameui_0002>Speed: %0.2f, Turning: %0.2f",
                air.MaxAirspeed,
                air.TurnSpeed))
            physics_line = table.getn(lines)
        elseif physics and physics.MaxSpeed and physics.MaxSpeed ~=0 then
            table.insert(lines, "")
            table.insert(lines, LOCF("<LOC gameui_0003>Speed: %0.2f, Acceleration: %0.2f, Turning: %d",
                physics.MaxSpeed,
                physics.MaxBrake,
                physics.TurnRate))
            physics_line = table.getn(lines)
        end

        weapon_start = weapon_start + 1
    end

    for i, v in lines do
        local index = i
        if control.Value[index] then
            control.Value[index]:SetText(v)
        else
            control.Value[index] = UIUtil.CreateText(control, v, 12, UIUtil.bodyFont)
            LayoutHelpers.Below(control.Value[index], control.Value[index-1])
            control.Value[index].Right:Set(function() return control.Right() - 7 end)
            control.Value[index].Width:Set(function() return control.Right() - control.Left() - 14 end)
            control.Value[index]:SetClipToWidth(true)
            control.Value[index]:DisableHitTest()
        end
        if index <= abilityLines then
            control.Value[index]:SetColor(UIUtil.bodyColor)
        elseif index == physics_line then
            control.Value[index]:SetColor('FFb0ffb0')
        elseif index == weapon_start then
            control.Value[index]:SetColor('ffff9999')
            weapon_start = weapon_start + 2
        else
            control.Value[index]:SetColor(UIUtil.fontColor)
        end
        control.Height:Set(function() return (math.max(table.getsize(lines), 4) * control.Value[1].Height()) + 30 end)
    end
    for i, v in control.Value do
        local index = i
        if index > table.getsize(lines) then
            v:SetText("")
        end
    end
end
