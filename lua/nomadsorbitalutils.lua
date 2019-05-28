local Factions = import('/lua/factions.lua').Factions


-- contains all kinds of code for stuff that happens on a nomads spaceship in orbit.


-- =================================================================================================================
-- PUBLIC FUNCTIONS       (call these from anywhere)
-- =================================================================================================================

function RequestStrikeToDestroyWreckage( brain, prop )
    -- Called to make a wreckage a target for the mothership
    --LOG('NomadsOrbitalUtils -> RequestStrikeToDestroyWreckage: called')

    local IsNomads = CheckBrainIsNomadsFaction( brain )

    if IsNomads and prop then
        AddTarget( brain, prop ) -- add wreck to target list with lowest prio

    elseif not IsNomads then
        WARN('RequestStrikeToDestroyWreckage: brain is not NOMADS faction!')
    end
end

function OnBrainDefeated( brain )
    -- when a brain is defeated the mothership is not dead and should continue to bombard targets until none are left.
    -- the mothership should then leave (??)

-- TODO (also hooking this in the aibrain file)
end

function CreateOrbitalUnit( brain )
    LOG('*DEBUG: Creating orbital unit')
    local bp = 'xno0001'
    local army = brain:GetArmyIndex()
    local x, z = brain:GetArmyStartPos()
    local y = GetSurfaceHeight(x,z)
    local unit = CreateUnitHPR( bp, army, x, y, z, 0, 0, 0)
    return unit
end

-- =================================================================================================================
-- PRIVATE FUNCTIONS
-- =================================================================================================================

local ArmyTargetList = {}
local ArmyHandleTargetThreads = {}

function CheckBrainIsNomadsFaction( brain )
    -- Says true if we're Nomads, false otherwise
    local factionIndex = brain:GetFactionIndex()
    return ( Factions[factionIndex].Category == 'NOMADS' )
end

function AddTarget( brain, targetEntity, prio, numAttacks )
    -- Do not directly call from somewhere else. All uses should go through public functions in this file (this one is private)
    -- Adds a target entity to the list of targets for the mothership. The prio is a number between 0 and 3 where 0 is lowest
    -- priority and 3 is highest. numAttacks indicates how many projectiles (most likely) to fire at the target. If nil or
    -- -1 the mothership will keep firing on it until it is destroyed (one way or the other).

    -- validate parameters
    if not prio then
        prio = 0     -- lowest prio
    end
    if not numAttacks then
        numAttacks = -1
    end

    -- prepare database entry
    local army = brain:GetArmyIndex()
    local data = { entity = targetEntity, num = numAttacks, assigned = false, }

    -- add entry to targets database
    if not ArmyTargetList then
        ArmyTargetList = {}
    end
    if not ArmyTargetList[army] then
        ArmyTargetList[army] = {}
    end
    if not ArmyTargetList[army][prio] then
        ArmyTargetList[army][prio] = {}
    end
    table.insert( ArmyTargetList[army][prio], data )

    -- start handling items on the target list
--    FindTargetsForAllGuns( brain )
end

function FindTargetsForAllGuns( brain )

-- TODO: this. kinda hard with to handle all targets, especially if we want 1 or more guns targetting the same target.

    -- finds the highest prio targets and attacks them until database runs dry
    local army = brain:GetArmyIndex()

    local NumGuns = GetNumGuns()
    local TargetForGun = {}

    local gun = 1
    local prio = 3
    while gun <= NumGuns do

        while prio >= 0 do

            for k, TargetData in ArmyTargetList[army][prio] do

                -- check if the target was not previously assigned to a gun(s)
                if not TargetData.assigned then


                    ArmyTargetList[army][prio][k].assigned = true
                end
            end
        end
    end
end

function GetNumGuns()
    -- says how many targets the mothership can attack at any one time
    return 10
end

function GetNumGunsForPrio( prio )
    -- given the priority of a target this says how many guns to aim at the target
    local max = GetNumGuns()
    if prio >= 3 then
        return max
    elseif prio >= 2 then
        return Math.ceil( max / 2 )
    elseif prio >= 1 then
        return Math.ceil( max / 4 )
    end
    return 1
end