
do


local oldBuffAffectUnit = BuffAffectUnit
function BuffAffectUnit(unit, buffName, instigator, afterRemove)

    local buffDef = Buffs[buffName]
    local buffAffects = buffDef.Affects

    local beforeData = unit:OnBeforeBeingBuffed( buffName, instigator, nil )

    if buffDef.OnBuffAffect and not afterRemove then
        buffDef:OnBuffAffect(unit, instigator)
    end

    for atype, vals in buffAffects do

        -------- NEW AFFECTS

        if atype == 'Immobilize' then

            local val, bool, actDelay, deaDelay = BuffCalculate(unit, buffName, 'Immobilize', 1)

            if not afterRemove then
                RememberDeactivationDelay(unit, buffName, 'Immobilize', deaDelay)
            else
                deaDelay = GetDeactivationDelay(unit, buffName, 'Immobilize')
            end

            if unit.BuffActivationThreads[atype] then KillThread(unit.BuffActivationThreads[atype]) end
            if unit.BuffDeactivationThreads[atype] then KillThread(unit.BuffDeactivationThreads[atype]) end
            
            if (not afterRemove and actDelay > 0) or (afterRemove and deaDelay > 0) then
                -- activate or deactivate immobility after a delay
                local fn = function(unit, delay, bool)
                    WaitSeconds(delay)
                    if unit and not unit:IsDead() then
                        unit:SetImmobile(bool)
                    end
                end
                if not afterRemove then
                    if not unit.BuffActivationThreads then unit.BuffActivationThreads = {} end
                    unit.BuffActivationThreads[atype] = unit:ForkThread(fn, actDelay, true)
                else
                    if not unit.BuffDeactivationThreads then unit.BuffDeactivationThreads = {} end
                    unit.BuffDeactivationThreads[atype] = unit:ForkThread(fn, deaDelay, false)
                end
            else
                -- activate or deactivate immobility immediately
                unit:SetImmobile( not (afterRemove == true) )
            end

        elseif atype == 'SonarRadius' then

            local sonarrad = unit:GetBlueprint().Intel.SonarRadius or 0
            local val = BuffCalculate(unit, buffName, 'SonarRadius', sonarrad)
            if val > 0 then
                if not unit:IsIntelEnabled('Sonar') then
                    unit:InitIntel(unit:GetArmy(),'Sonar', val)
                    unit:EnableIntel('Sonar')
                else
                    unit:SetIntelRadius('Sonar', val)
                    unit:EnableIntel('Sonar')
                end
            else
                unit:DisableIntel('Sonar')
            end

        elseif atype == 'FiringRandomness'
            or atype == 'BombardFiringRandomness' then

            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                local FR = wepbp.FiringRandomness or 0
                local val = BuffCalculate(unit, buffName, 'FiringRandomness', FR)
                if wepbp.BombardParticipant then
                    local BFR = BuffCalculate(unit, buffName, 'BombardFiringRandomness', FR) - FR
                    val = math.max(0, val + BFR )
                end

                wep:SetFiringRandomness(val)
            end

        -------- EXISTING AFFECTS (but modified)

        elseif atype == 'MaxRadius'
            or atype == 'MaxRadiusSpecifiedWeapons'
            or atype == 'BombardMaxRadius' then

            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                local weprad = wepbp.MaxRadius
                local val = BuffCalculate(unit, buffName, 'MaxRadius', weprad)
                if wepbp.ReceiveMaxRadiusBuff then
                    local mr = BuffCalculate(unit, buffName, 'MaxRadiusSpecifiedWeapons', weprad) - weprad
                    val = val + mr
                end
                if wepbp.BombardParticipant then
                    local BMR = BuffCalculate(unit, buffName, 'BombardMaxRadius', weprad) - weprad
                    val = math.max(0, val + BMR)
                end

                wep:ChangeMaxRadius(val)

                --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max radius to ', repr(val))
            end

        elseif atype == 'RateOfFire'
            or atype == 'RateOfFireSpecifiedWeapons'
            or atype == 'RateOfFireSpecifiedWeapons2'
            or atype == 'RateOfFireSpecifiedWeapons3'
            or atype == 'BombardRateOfFire' then

            for i = 1, unit:GetWeaponCount() do

                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                local weprof = wepbp.RateOfFire or 1
                local val = BuffCalculate(unit, buffName, 'RateOfFire', 1)
                if wepbp.ReceiveROFBuff then
                    local RF = BuffCalculate(unit, buffName, 'RateOfFireSpecifiedWeapons', 1) - 1
                    val = val + RF
                end
                if wepbp.ReceiveROF2Buff then
                    local RF = BuffCalculate(unit, buffName, 'RateOfFireSpecifiedWeapons2', 1) - 1
                    val = val + RF
                end
                if wepbp.ReceiveROF3Buff then
                    local RF = BuffCalculate(unit, buffName, 'RateOfFireSpecifiedWeapons3', 1) - 1
                    val = val + RF
                end
                if wepbp.BombardParticipant then
                    local BRF = BuffCalculate(unit, buffName, 'BombardRateOfFire', 1) - 1
                    val = val + BRF
                end

                local delay = 1 / weprof                    -- these calculations result in having to use "weird" buff values. A mult of 0.5
                wep:ChangeRateOfFire( 1 / ( val * delay ) ) -- actually double the ROF. Adding a positive value actually decreases ROF...

                --LOG('*BUFF: RateOfFire = ' ..  (1 / ( val * delay )) )
            end

        elseif atype == 'RadarRadius' then

            -- checking for a value > 0 to avoid erroring out
            local radarrad = unit:GetBlueprint().Intel.RadarRadius or 0
            local val = BuffCalculate(unit, buffName, 'RadarRadius', radarrad)
            if val > 0 then
                if not unit:IsIntelEnabled('Radar') then
                    unit:InitIntel(unit:GetArmy(), 'Radar', val)
                    unit:EnableIntel('Radar')
                else
                    unit:SetIntelRadius('Radar', val)
                    unit:EnableIntel('Radar')
                end
            else
                unit:DisableIntel('Radar')
            end
        
        elseif atype == 'OmniRadius' then

            -- checking for a value > 0 to avoid erroring out
            local omnirad = unit:GetBlueprint().Intel.RadarRadius or 0
            local val = BuffCalculate(unit, buffName, 'OmniRadius', omnirad)
            if val > 0 then
                if not unit:IsIntelEnabled('Omni') then
                    unit:InitIntel(unit:GetArmy(), 'Omni', val)
                    unit:EnableIntel('Omni')
                else
                    unit:SetIntelRadius('Omni', val)
                    unit:EnableIntel('Omni')
                end
            else
                unit:DisableIntel('Omni')
            end

        end
    end

    -- the original BuffAffectedUnit produces an error in the log when a buff unknown to the script is generated. To prevent that, remove
    -- the new affect types from the affects table first, then run the function and then restore the table.
-- FAF integration: perhaps something can be done about this problem, to make it more mod friendly?
    local OrgAffectsTable = table.deepcopy(Buffs[buffName].Affects)
    Buffs[buffName].Affects['Immobilize'] = nil
    Buffs[buffName].Affects['RadarRadius'] = nil
    Buffs[buffName].Affects['SonarRadius'] = nil
    Buffs[buffName].Affects['OmniRadius'] = nil
    Buffs[buffName].Affects['FiringRandomness'] = nil
    Buffs[buffName].Affects['BombardFiringRandomness'] = nil
    Buffs[buffName].Affects['MaxRadius'] = nil
    Buffs[buffName].Affects['MaxRadiusSpecifiedWeapons'] = nil
    Buffs[buffName].Affects['BombardMaxRadius'] = nil
    Buffs[buffName].Affects['RateOfFire'] = nil
    Buffs[buffName].Affects['BombardRateOfFire'] = nil
    Buffs[buffName].Affects['RateOfFireSpecifiedWeapons'] = nil
    Buffs[buffName].Affects['RateOfFireSpecifiedWeapons2'] = nil
    Buffs[buffName].Affects['RateOfFireSpecifiedWeapons3'] = nil
    oldBuffAffectUnit(unit, buffName, instigator, afterRemove)
    Buffs[buffName].Affects = OrgAffectsTable

    if unit and not unit:BeenDestroyed() and not unit:IsDead() then
        unit:OnAfterBeingBuffed( buffName, instigator, nil, beforeData )
    end
end

-- Modding in activation and deactivation delays. Only used in the function above, support for other affects should be added in above aswell.
function BuffCalculate(unit, buffName, affectType, initialVal, initialBool, initialActivateDelay, initialDeactivateDelay)
    local adds = 0
    local mults = 1.0
    local actDelay = initialActivateDelay or 0
    local deaDelay = initialDeactivateDelay or 0
    local bool = initialBool or false
    local returnVal = initialVal

    local highestCeil = false
    local lowestFloor = false
    
    if unit.Buffs.Affects[affectType] then
        for k, v in unit.Buffs.Affects[affectType] do
            if v.Add and v.Add ~= 0 then
                adds = adds + (v.Add * v.Count)
            end
            if v.Mult then
                for i=1,v.Count do
                    mults = mults * v.Mult
                end
            end
            if not v.Bool then
                bool = false
            else
                bool = true
            end
            if v.ActivateDelay then
                actDelay = math.max(actDelay, v.ActivateDelay)
            end
            if v.DeactivateDelay then
                deaDelay = math.max(deaDelay, v.DeactivateDelay)
            end
            if v.Ceil and (not highestCeil or highestCeil < v.Ceil) then
                highestCeil = v.Ceil
            end
            if v.Floor and (not lowestFloor or lowestFloor > v.Floor) then
                lowestFloor = v.Floor
            end
        end

        returnVal = (initialVal + adds) * mults
        if lowestFloor and returnVal < lowestFloor then returnVal = lowestFloor end
        if highestCeil and returnVal > highestCeil then returnVal = highestCeil end
    end

    return returnVal, bool, actDelay, deaDelay
end


-- The RemoveBuff script should check whether it has the specified buff and if not, don't throw an error.
local oldRemoveBuff = RemoveBuff
function RemoveBuff(unit, buffName, removeAllCounts, instigator)
    if HasBuff(unit, buffName) then
        oldRemoveBuff(unit, buffName, removeAllCounts, instigator)
    end
end


-- if a buff is deactivated it is not possible to get the deactivation delay through BuffCalculate and it will always return 0. So we'll
-- need to remember what the value is when it is set. We do that using this function and retrieve the value using another function below.
function RememberDeactivationDelay(unit, buffName, affectType, value)
    if not unit.BuffDeactivationDelays then
        unit.BuffDeactivationDelays = {}
    end
    unit.BuffDeactivationDelays[affectType] = value
end

function GetDeactivationDelay(unit, buffName, affectType)
    if unit.BuffDeactivationDelays then
        return unit.BuffDeactivationDelays[affectType]
    end
    return 0
end


end