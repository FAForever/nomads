local Tasks = import('/lua/user/tasks/Tasks.lua')


function MapReticulesToUnitIdsScript( TaskName, ReticulePositions, Units, UnitIds )

    # We'll want to use sonars first when the position is on water, radar if on land. If we can't do that then use the nearest.

    local RadarCapList = {}  # lists keys to the Units table. Can contain the same key more than once if that unit has the capacity to
    local SonarCapList = {}  # handle more than one reticule at the same time.

    # compile CapList tables. Unit keys are added according to their capacity and type
    local bp, cap, isradar, issonar
    local MaxRanges = {}
    local MinRanges = {}
    for k, unit in Units do

        bp = unit:GetBlueprint()
        if bp.SpecialAbilities and bp.SpecialAbilities[TaskName] and bp.SpecialAbilities[TaskName].WantNumTargets then
            cap = bp.SpecialAbilities[TaskName].WantNumTargets
        else
            cap = 1
        end

        isradar = (bp.Intel.OverchargeType == 'Radar' or bp.Intel.OverchargeType == 'Omni')
        issonar = (bp.Intel.OverchargeType == 'Sonar' or bp.Intel.OverchargeType == 'Omni')

        for i=1, cap do
            if isradar then
                table.insert(RadarCapList, k)
            end
            if issonar then
                table.insert(SonarCapList, k)
            end
        end
    end

    # for every reticule determine the best unassigned unit. If reticule is in water then use sonar first. On land use radar first
    local ClosestUnitKeys = {}
    local ClosestUnitKey, sonar
    for RetKey, RetPos in ReticulePositions do

        if PosIsInWater(RetPos) then
            ClosestUnitKey = FindBestUnitKeyForReticulePosition(TaskName, SonarCapList, Units, RetPos)
            if not ClosestUnitKey then
                ClosestUnitKey = FindBestUnitKeyForReticulePosition(TaskName, RadarCapList, Units, RetPos)
            end
        else
            ClosestUnitKey = FindBestUnitKeyForReticulePosition(TaskName, RadarCapList, Units, RetPos)
            if not ClosestUnitKey then
                ClosestUnitKey = FindBestUnitKeyForReticulePosition(TaskName, SonarCapList, Units, RetPos)
            end
        end

        if ClosestUnitKey then
            ClosestUnitKeys[RetKey] = ClosestUnitKey
            table.removeByValue(RadarCapList, ClosestUnitKey)  # remove from both cap lists because it might be a unit that can do both
            table.removeByValue(SonarCapList, ClosestUnitKey)  # radar and sonar, in that case it will be in both lists.
        else
            WARN('*DEBUG: MapReticulesToUnitIdsScript: couldnt map a unit to reticule '..repr(RetKey)..' for task '..repr(TaskName))
        end
    end

    # Find unit Ids. We need to return unit Ids, not keys of the Units table.
    local map = {}
    for RetKey, UnitKey in ClosestUnitKeys do
        map[RetKey] = Units[UnitKey]:GetEntityId()
    end

    return map
end

function FindBestUnitKeyForReticulePosition(TaskName, UnitCapList, Units, RetPos)
    local ClosestDist, ClosestUnitKey
    for _, UnitKey in UnitCapList do
        if UnitCanIntelOverchargeToPos(TaskName, Units[UnitKey], RetPos) then
            pos = Units[UnitKey]:GetPosition()
            dist = VDist2(pos[1], pos[3], RetPos[1], RetPos[3])
            if not ClosestDist or dist < ClosestDist then
                ClosestDist = dist
                ClosestUnitKey = UnitKey
            end
        end
    end
    return ClosestUnitKey
end

function PosIsInWater(pos)
# TODO: make this work. Find a way to determine if a position is in water or not.
#    if pos and pos[1] and pos[3] then
#        local surface = GetSurfaceHeight(pos[1], pos[3]
#        local terrain = GetTerrainHeight(pos[1], pos[3]
#        return (surface > terrain)
#    end
    return false
end

function UnitCanIntelOverchargeToPos(TaskName, unit, pos)
    return Tasks.UnitCanFireAtPos(TaskName, unit, pos)
end
