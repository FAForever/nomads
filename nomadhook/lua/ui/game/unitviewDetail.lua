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


--Credit where credit is due, they did fuck the dps code again, but at least the rest of it is slightly nicer.
--I would remove some of the useless info there like the armour type which is normal for 95% of units and doesnt tell us anything
--But aside from too much info, and duplicate info such as the intel being in 2 places, its not that bad.
--Still needs refactoring though, and I dont have the time to do it, nor the inclination to argue with people about it.
function WrapAndPlaceText(bp, builder, descID, control)
    local lines = {}
    local blocks = {}
    --Unit description
    local text = LOC(UnitDescriptions[descID])
    if text and text ~='' then
        table.insert(blocks, {color = UIUtil.fontColor,
            lines = WrapText(text, control.Value[1].Width(), function(text)
                return control.Value[1]:GetStringAdvance(text)
            end)})
        table.insert(blocks, {color = UIUtil.bodyColor, lines = {''}})
    end

    if builder and bp.EnhancementPresetAssigned then
        table.insert(lines, LOC('<LOC uvd_upgrades>')..':')
        for _, v in bp.EnhancementPresetAssigned.Enhancements do
            table.insert(lines, '    '..LOC(bp.Enhancements[v].Name))
        end
        table.insert(blocks, {color = 'FFB0FFB0', lines = lines})
    elseif bp then
        --Get not autodetected abilities
        if bp.Display.Abilities then
            for _, id in bp.Display.Abilities do
                local ability = ExtractAbilityFromString(id)
                if not IsAbilityExist[ability] then
                    table.insert(lines, LOC(id))
                end
            end
        end
        --Autodetect abilities exclude engineering
        for id, func in IsAbilityExist do
            if (id ~= 'ability_engineeringsuite') and (id ~= 'ability_building') and
               (id ~= 'ability_repairs') and (id ~= 'ability_reclaim') and (id ~= 'ability_capture') and func(bp) then
                local ability = LOC('<LOC '..id..'>')
                if GetAbilityDesc[id] then
                    local desc = GetAbilityDesc[id](bp)
                    if desc ~= '' then
                        desc = ' - '..desc
                    end
                    ability = ability..desc
                end
                table.insert(lines, ability)
            end
        end
        if table.getsize(lines) > 0 then
            table.insert(lines, '')
        end
        table.insert(blocks, {color = 'FF7FCFCF', lines = lines})
        --Autodetect engineering abilities
        if IsAbilityExist.ability_engineeringsuite(bp) then
            lines = {}
            table.insert(lines, LOC('<LOC '..'ability_engineeringsuite'..'>')
                ..' - '..LOCF('<LOC uvd_BuildRate>', bp.Economy.BuildRate)
                ..', '..LOCF('<LOC uvd_Radius>', bp.Economy.MaxBuildDistance))
            local orders = LOC('<LOC order_0011>')
            if IsAbilityExist.ability_building(bp) then
                orders = orders..', '..LOC('<LOC order_0001>')
            end
            if IsAbilityExist.ability_repairs(bp) then
                orders = orders..', '..LOC('<LOC order_0005>')
            end
            if IsAbilityExist.ability_reclaim(bp) then
                orders = orders..', '..LOC('<LOC order_0006>')
            end
            if IsAbilityExist.ability_capture(bp) then
                orders = orders..', '..LOC('<LOC order_0007>')
            end
            table.insert(lines, orders)
            table.insert(lines, '')
            table.insert(blocks, {color = 'FFFFFFB0', lines = lines})
        end

        if options.gui_render_armament_detail == 1 then
            --Armor values
            lines = {}
            local armorType = bp.Defense.ArmorType
            if armorType and armorType ~= '' then
                local spaceWidth = control.Value[1]:GetStringAdvance(' ')
                local str = LOC('<LOC uvd_ArmorType>')..LOC('<LOC at_'..armorType..'>')
                local spaceCount = (195 - control.Value[1]:GetStringAdvance(str)) / spaceWidth
                str = str..string.rep(' ', spaceCount)..LOC('<LOC uvd_DamageTaken>')
                table.insert(lines, str)
                for _, armor in armorDefinition do
                    if armor[1] == armorType then
                        local row = 0
                        local armorDetails = ''
                        local elemCount = table.getsize(armor)
                        for i = 2, elemCount do
                            --if string.find(armor[i], '1.0') > 0 then continue end
                            local armorName = armor[i]
                            armorName = string.sub(armorName, 1, string.find(armorName, ' ') - 1)
                            armorName = LOC('<LOC an_'..armorName..'>')..' - '..string.format('%0.1f', tonumber(armor[i]:sub(armorName:len() + 2, armor[i]:len())) * 100)
                            if row < 1 then
                                armorDetails = armorName
                                row = 1
                            else
                                local spaceCount = (195 - control.Value[1]:GetStringAdvance(armorDetails)) / spaceWidth
                                armorDetails = armorDetails..string.rep(' ', spaceCount)..armorName
                                table.insert(lines, armorDetails)
                                armorDetails = ''
                                row = 0
                            end
                        end
                        if armorDetails ~= '' then
                            table.insert(lines, armorDetails)
                        end
                    end
                end
                table.insert(lines, '')
                table.insert(blocks, {color = 'FF7FCFCF', lines = lines})
            end
            --Weapons
            if table.getsize(bp.Weapon) > 0 then
                local weapons = {upgrades = {normal = {}, death = {}},
                                    basic = {normal = {}, death = {}}}
                for _, weapon in bp.Weapon do
                    if not weapon.WeaponCategory then continue end
                    local dest = weapons.basic
                    if weapon.EnabledByEnhancement then
                        dest = weapons.upgrades
                    end
                    if (weapon.FireOnDeath) or (weapon.WeaponCategory == 'Death') then
                        dest = dest.death
                    else
                        dest = dest.normal
                    end
                    if dest[weapon.DisplayName] then
                        dest[weapon.DisplayName].count = dest[weapon.DisplayName].count + 1
                    else
                        dest[weapon.DisplayName] = {info = weapon, count = 1}
                    end
                end
                for k, v in weapons do
                    if table.getsize(v.normal) > 0 or table.getsize(v.death) > 0 then
                        table.insert(blocks, {color = UIUtil.fontColor, lines = {LOC('<LOC uvd_'..k..'>')..':'}})
                    end
                    for name, weapon in v.normal do
                        local info = weapon.info
                        local weaponDetails1 = LOCStr(name)..' ('..LOCStr(info.WeaponCategory)..') '
                        if info.ManualFire then
                            weaponDetails1 = weaponDetails1..LOC('<LOC uvd_ManualFire>')
                        end
                        local weaponDetails2
                        if info.NukeInnerRingDamage then
                            weaponDetails2 = string.format(LOC('<LOC uvd_0014>Damage: %d - %d, Splash: %d - %d')..', '..LOC('<LOC uvd_Range>'),
                                info.NukeInnerRingDamage + info.NukeOuterRingDamage, info.NukeOuterRingDamage,
                                info.NukeInnerRingRadius, info.NukeOuterRingRadius, info.MinRadius, info.MaxRadius)
                        else
                            local MuzzleBones = 0
                            if info.MuzzleSalvoDelay > 0 then
                                MuzzleBones = info.MuzzleSalvoSize
                            elseif info.RackBones then
                                for _, v in info.RackBones do
                                    MuzzleBones = MuzzleBones + table.getsize(v.MuzzleBones)
                                end
                                if not info.RackFireTogether then
                                    MuzzleBones = MuzzleBones / table.getsize(info.RackBones)
                                end
                            else
                                MuzzleBones = 1
                            end

                            local Damage = info.Damage
                            if info.DamageToShields then
                                Damage = math.max(Damage, info.DamageToShields)
                            end
                            Damage = Damage * (info.DoTPulses or 1)
                            local ProjectilePhysics = __blueprints[info.ProjectileId].Physics
                            while ProjectilePhysics do
                                Damage = Damage * (ProjectilePhysics.Fragments or 1)
                                ProjectilePhysics = __blueprints[string.lower(ProjectilePhysics.FragmentId or '')].Physics
                            end
                            
                            --EQ/Nomads: Rate of fire is still wrong in the code, had to change it again. Would be great if this function wasnt part of a huge long other function.
                            --In general UI code is a mess and needs a huge rewrite
                            
                            local ReloadTime = math.max(0.1*math.floor((10 / info.RateOfFire) + 0.5), 0.1) --the rof is rounded to the nearest tick since the game runs in ticks.
                            --some weapons also have separate charge and reload times which results in them firing less often. yeah.
                            --in theory if your total MuzzleSalvoDelay is longer than the reload time your weapon waits for the reload time twice, but thats pretty much a bug so not taken into account here
                            ReloadTime = math.max((info.RackSalvoChargeTime or 0) + (info.RackSalvoReloadTime or 0) + (info.MuzzleSalvoDelay or 0)*((info.MuzzleSalvoSize or 1)-1), ReloadTime)

                            if not info.ManualFire and info.WeaponCategory ~= 'Kamikaze' then
                                local DPS = Damage * MuzzleBones
                                if info.BeamLifetime > 0 then
                                    DPS = DPS * info.BeamLifetime * 10
                                end
                                DPS = DPS / ReloadTime + (info.InitialDamage or 0)
                                weaponDetails1 = weaponDetails1..LOCF('<LOC uvd_DPS>', DPS)
                            end

                            weaponDetails2 = string.format(LOC('<LOC uvd_0010>Damage: %d, Splash: %d')..', '..LOC('<LOC uvd_Range>')..', '..LOC('<LOC uvd_Reload>'),
                                Damage, info.DamageRadius, info.MinRadius, info.MaxRadius, ReloadTime)
                        end
                        if weapon.count > 1 then
                            weaponDetails1 = weaponDetails1..' x'..weapon.count
                        end
                        table.insert(blocks, {color = UIUtil.fontColor, lines = {weaponDetails1}})
                        table.insert(blocks, {color = 'FFFFB0B0', lines = {weaponDetails2}})
                    end
                    lines = {}
                    for name, weapon in v.death do
                        local info = weapon.info
                        local weaponDetails = LOCStr(name)..' ('..LOCStr(info.WeaponCategory)..') '
                        if info.NukeInnerRingDamage then
                            weaponDetails = weaponDetails..LOCF('<LOC uvd_0014>Damage: %d - %d, Splash: %d - %d',
                                info.NukeInnerRingDamage + info.NukeOuterRingDamage, info.NukeOuterRingDamage,
                                info.NukeInnerRingRadius, info.NukeOuterRingRadius)
                        else
                            weaponDetails = weaponDetails..LOCF('<LOC uvd_0010>Damage: %d, Splash: %d',
                                info.Damage, info.DamageRadius)
                        end
                        if weapon.count > 1 then
                            weaponDetails = weaponDetails..' x'..weapon.count
                        end
                        table.insert(lines, weaponDetails)
                    end
                    if table.getsize(v.normal) > 0 or table.getsize(v.death) > 0 then
                        table.insert(lines, '')
                    end
                    table.insert(blocks, {color = 'FFFF0000', lines = lines})
                end
            end
        end
        --Other parameters
        lines = {}
        table.insert(lines, LOCF("<LOC uvd_0013>Vision: %d, Underwater Vision: %d, Regen: %0.1f, Cap Cost: %0.1f",
            bp.Intel.VisionRadius, bp.Intel.WaterVisionRadius, bp.Defense.RegenRate, bp.General.CapCost))

        if (bp.Physics.MotionType ~= 'RULEUMT_Air' and bp.Physics.MotionType ~= 'RULEUMT_None')
        or (bp.Physics.AltMotionType ~= 'RULEUMT_Air' and bp.Physics.AltMotionType ~= 'RULEUMT_None') then
            table.insert(lines, LOCF("<LOC uvd_0012>Speed: %0.1f, Reverse: %0.1f, Acceleration: %0.1f, Turning: %d",
                bp.Physics.MaxSpeed, bp.Physics.MaxSpeedReverse, bp.Physics.MaxAcceleration, bp.Physics.TurnRate))
        end

        table.insert(blocks, {color = 'FFB0FFB0', lines = lines})
    end
    CreateLines(control, blocks)
end