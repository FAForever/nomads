do


local oldModBlueprints = ModBlueprints
function ModBlueprints(all_bps)

    LOG('NOMADS: Modding unit blueprints for FAF compatibility')

    for _, bp in all_bps.Unit do
        if bp.RemoveAnimationDeath and bp.Display.AnimationDeath then
            bp.Display.AnimationDeath = nil
            LOG( repr(bp.BlueprintId)..': removed animation death blueprint info')
        end
        bp.RemoveAnimationDeath = nil

        # Code below injects wreckage info for naval untis that don't have it. Surprisingly this seems to be all non-Nomads naval units
        local code = string.lower(string.sub(bp.BlueprintId, 1, 3))
        if   code == 'ues' or code == 'uas' or code == 'urs' or code == 'xss' or code == 'ins' or
             code == 'xes' or code == 'xas' or code == 'xrs'
        then

            local isok = true
            if not bp.Wreckage then
                bp.Wreckage = {
                    Blueprint = '/props/DefaultWreckage/DefaultWreckage_prop.bp',
                    EnergyMult = 0,
                    HealthMult = 0.9,
                    MassMult = 0.9,
                    ReclaimTimeMultiplier = 1,
                    WreckageLayers = {
                        Air = false,
                        Land = false,
                        Seabed = true,
                        Sub = true,
                        Water = true,
                    },
                }
                isok = false
            end

            if not bp.Wreckage.WreckageLayers then
                bp.Wreckage.WreckageLayers = {
                    Air = false,
                    Land = false,
                    Seabed = true,
                    Sub = true,
                    Water = true,
                }
                isok = false
            end

            if not bp.Wreckage.WreckageLayers.Seabed then
                bp.Wreckage.WreckageLayers.Seabed = true
                isok = false
            end

            if not bp.Wreckage.WreckageLayers.Sub then
                bp.Wreckage.WreckageLayers.Sub = true
                isok = false
            end

            if not bp.Wreckage.WreckageLayers.Water then
                bp.Wreckage.WreckageLayers.Water = true
                isok = false
            end

            if not isok then
                LOG('Injected missing wreckage info: '..repr(bp.BlueprintId))
            end
        end
    end


    oldModBlueprints(all_bps)
end

local oldGetNewUnitLocations = GetNewUnitLocations
function GetNewUnitLocations()
    local t = oldGetNewUnitLocations()
    t = table.cat( t, {
        # adding all Nomad support factories to the game
        '/units/INB0211',
        '/units/INB0212',
        '/units/INB0213',
        '/units/INB0311',
        '/units/INB0312',
        '/units/INB0313',
    })
    return t
end


end
