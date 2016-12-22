do

local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')



local oldPlayTeleportChargingEffects = PlayTeleportChargingEffects

function PlayTeleportChargingEffects( unit, TeleportDestination, EffectsBag )

# TODO: Nomads teleport charging effect
#    if unit then
#        local bp = unit:GetBlueprint()
#        local faction = bp.General.FactionName
#
#        if faction == 'Nomads' then                                                                    #### NOMAD ####
#            local army = unit:GetArmy()
#            local Yoffset = TeleportGetUnitYOffset(unit)
#
#            if bp.Display.TeleportEffects.PlayChargeFxAtUnit != false then                            # FX AT UNIT
#            end
#
#            if bp.Display.TeleportEffects.PlayChargeFxAtDestination != false then                     # FX AT DESTINATION
#            end
#        end
#
#        return
#    end

    oldPlayTeleportChargingEffects( unit, TeleportDestination, EffectsBag )
end


local oldTeleportChargingProgress = TeleportChargingProgress

function TeleportChargingProgress(unit, fraction)
# TODO: Nomads teleport charge progressing
#    local bp = unit:GetBlueprint()
#    local faction = bp.General.FactionName
#    if faction == 'Nomads' then
#        if bp.Display.TeleportEffects.PlayChargeFxAtDestination != false then
#        end
#    else
        oldTeleportChargingProgress(unit, fraction)
#    end
end


local oldPlayTeleportOutEffects = PlayTeleportOutEffects

function PlayTeleportOutEffects(unit, EffectsBag)
# TODO: Nomads teleport out effect
#    local bp = unit:GetBlueprint()
#    local faction = bp.General.FactionName
#
#    if faction == 'Nomads' then
#
#        local army = unit:GetArmy()
#        local Yoffset = TeleportGetUnitYOffset(unit)
#
#        if bp.Display.TeleportEffects.PlayTeleportOutFx != false then
#            unit:PlayUnitSound('TeleportOut')
#        end
#    else
        oldPlayTeleportOutEffects(unit, EffectsBag)
#    end
end


local oldDoTeleportInDamage = DoTeleportInDamage

function DoTeleportInDamage(unit)
    # injecting Nomads effect
    if unit and not unit.TeleportInWeaponFxOverride then
# TODO: Nomads teleport damage effect
#        unit.TeleportInWeaponFxOverride = NomadEffectTemplate.NomadTeleportInWeapon01
    end
    oldDoTeleportInDamage(unit)
end


local oldPlayTeleportInEffects = PlayTeleportInEffects

function PlayTeleportInEffects(unit, EffectsBag)
# TODO: NOmads teleport in effect
#    local bp = unit:GetBlueprint()
#    local faction = bp.General.FactionName
#
#    if faction == 'Nomads' then
#
#        local army = unit:GetArmy()
#        local Yoffset = TeleportGetUnitYOffset(unit)
#
#        DoTeleportInDamage(unit)
#
#        if bp.Display.TeleportEffects.PlayTeleportInFx != false then
#            unit:PlayUnitSound('TeleportIn')
#        end
#    else
        oldPlayTeleportInEffects(unit, EffectsBag)
#    end
end



end