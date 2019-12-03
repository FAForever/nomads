local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local NomadsEffectUtil = import('/lua/nomadseffectutilities.lua')
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AIUtils = import('/lua/ai/aiutilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local Utils = import('/lua/utilities.lua')
local Entity = import('/lua/sim/Entity.lua').Entity


-- ================================================================================================================
-- Orbital units
-- ================================================================================================================

--orbital units are spawned on request from parent units
--self.OrbitalUnit = self:CreateOrbitalUnit()
--CreateOrbitalUnit = function(self, offsetAmount, blueprint, unitArmy, pos)
function CreateOrbitalUnit(self, offsetAmount, blueprint, unitArmy, pos)
    local bp = blueprint or 'xno0001'
    local army = unitArmy or self:GetArmy()
    local position = pos or self:GetPosition()
    local heading = self:GetHeading()
    
    --calculate offset distance based on parent unit orientation
    local offsetDistance = offsetAmount or -15 --negative puts it behind the unit
    local offset = {offsetDistance * (math.sin(heading)), 0, offsetDistance * (math.cos(heading))}
    position = VAdd(position,offset)
    
    --set the height, taking terrain into account
    local initialHeight =__blueprints[bp].Physics.Elevation or 100
    position[2] = GetTerrainHeight(position[1],position[3]) + initialHeight

    return CreateUnitHPR( bp, army, position[1], position[2], position[3], 0, heading, 0)
end

--a thread for spawning the orbital frigate, requesting a build from it, and then despawning the frigate.
--self:ForkThread( RequestOrbitalSpawnThread, constructedBP, offsetAmount, blueprint, unitArmy, pos )
function RequestOrbitalSpawnThread(parent, constructedBP, offsetAmount, blueprint, unitArmy, pos)
    local OrbitalUnit = CreateOrbitalUnit(parent, offsetAmount, blueprint, unitArmy, pos)
    WaitSeconds(2)
    WaitFor(OrbitalUnit.LaunchAnim)
    
    OrbitalUnit:AddToSpawnQueue( constructedBP, parent ) --request the construction of the unit
    WaitSeconds(2)
    while OrbitalUnit.UnitBeingBuilt or table.getn(table.keys(OrbitalUnit.OrbitalSpawnQueue)) > 0 do
        WaitSeconds(0.5)
    end
    
    --once the queue is empty, we lock down the building queue so no other units try to add anything before takeoff.
    OrbitalUnit.UnitBeingBuilt = true
    OrbitalUnit.OrbitalSpawnQueue = {1,1,1,1}
    
    OrbitalUnit:TakeOff()
    WaitFor(OrbitalUnit.LaunchAnim)
    
    OrbitalUnit:Destroy()
end

FindOrbitalUnit = function(self, cats, range)
    local position = self:GetPosition()
    local unitCats = cats or categories.xno0001
    local searchRange = range or 500
    local units = Utils.GetOwnUnitsInSphere(position, searchRange, self:GetArmy(), unitCats)
    local ChosenUnit = false
    
    local ShortestQueueLength = 4 --if the queues get too long for some absurd reason, spawn a new frigate instead of clogging up the rest
    for _,unit in units do
        local queueLength = table.getn(table.keys(unit.OrbitalSpawnQueue or {1,1,1,1}))
        
        if queueLength == 0 then
            return unit
        elseif ShortestQueueLength > queueLength then
            ShortestQueueLength = queueLength
            ChosenUnit = unit
        end
    end
    return ChosenUnit or false
end

-- ================================================================================================================
-- Colour Index / Recolouring emitters
-- ================================================================================================================

DetermineColourIndex = function(hex)
    --we work out the hue of our team colour, which will then be sent to the shader for applying shader magic.
    if not hex then return 23.999 end
    --split the string by channel, supcom gives argb so drop the first channel
    local r,g,b = string.sub(hex,3,4), string.sub(hex,5,6), string.sub(hex,7,8)
    r,g,b = tonumber(r,16), tonumber(g,16), tonumber(b,16)
    local h,s,v = ConvertRGBtoHSV(r,g,b)
    
    --we apply utter madness to allow the value to pass to the shader. This makes it not quite the right hue value.
    if s < 0.25 then
        h = 540.25 -- a pale blue colour that is nicely suited to grey and white colours
    else
        --yeah. we store s in the decimal part of h, just so we can pass it to the shader. thats right, this is insane.
        if s == 1 then s = 0.99 end
        --we add 360 so that all the indeces are the same length, and any shader can easily recognize them as special.
        h = math.ceil(h*360) + s + 360
        --h = 0.01*math.floor(100*h) --round to 2 decimal places
    end
    return h
end

ConvertRGBtoHSV = function(r, g, b, a)
    r, g, b, a = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max

    local d = max - min
    if max == 0 then s = 0 else s = d / max end

    if max == min then
        h = 0 -- achromatic
    else
        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end

    return h, s, v, a or 255
end

ConvertRGBtoHSL = function(r, g, b, a)
    r, g, b = r / 255, g / 255, b / 255

    local maxL, minL = math.max(r, g, b), math.min(r, g, b)
    local h, s, l

    l = (maxL + minL) / 2

    if maxL == minL then
        h, s = 0, 0 -- achromatic
    else
        local d = maxL - minL
        if l > 0.5 then s = d / (2 - maxL - minL) else s = d / (maxL + minL) end
        if maxL == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif maxL == g then
            h = (b - r) / d + 2
        elseif maxL == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return h, s, l, a or 255
end

--[[
--example format: 
BeamsToRecolour = {
    'FxImpactAirUnit',
    'FxImpactLand',
    'FxImpactNone',
    'FxImpactProp',
    'FxImpactShield',
    'FxImpactWater',
    'FxImpactUnderWater',
    'FxImpactUnit',
    'FxImpactProjectile',
    'FxImpactProjectileUnderWater',
    'FxOnKilled',
},
--]]

--TODO: allow even more fine grained control, colouring only some of the emitter templates, ect.
--TODO: allow this to check if the emitter exists in the blueprints list first before setting

SetBeamsToColoured = function(self, BeamsToColour) --Replace specified emitter blueprints with their coloured versions, so every time theyre called we already have everything done!
    if not self.ColourIndex then WARN('Nomads: SetBeamsToColoured could not find ColourIndex. Leaving Emitters uncoloured.') return end
    
    for _, EmitterList in BeamsToColour do
        if self[EmitterList] then
            for k, Emitter in self[EmitterList] do
                self[EmitterList][k] = RenameBeamEmitterToColoured(Emitter, self.ColourIndex)
            end
        end
    end
end

RenameBeamEmitterToColoured = function(BeamName, ArmyColourIndex)
    if string.sub(BeamName,-3) == '.bp' then
        return string.sub(BeamName,1,-4) .. math.floor(100*ArmyColourIndex)
    end
    return string.sub(BeamName,1,-6) .. math.floor(100*ArmyColourIndex)
end

--TODO:Rename self.FactionColour, and set it to allow individual blueprints
--TODO: possibly replace these with blueprint switching instead, so we dont need to call this every time? not sure whats better.

-- Hook the Emitter creation commands, so we can insert our colour changes here.
-- To use, import into target file, and any functions written in that file will use this instead of the engine function. Example:
--local CreateAttachedEmitter = import('/lua/NomadsUtils.lua').CreateAttachedEmitterColoured

CreateAttachedEmitterColoured = function(self, ...)
    local emit = CreateAttachedEmitter(self, unpack(arg))
    if self.ColourIndex and self.FactionColour then
        emit:SetEmitterCurveParam('RAMPSELECTION_CURVE', self.ColourIndex, 0)
    end
    return emit
end

CreateEmitterAtBoneColoured = function(self, ...) -- Hook the engine CreateEmitterAtBone command, so we can insert our colour changes here.
    local emit = CreateEmitterAtBone(self, unpack(arg))
    if self.ColourIndex and self.FactionColour then
        emit:SetEmitterCurveParam('RAMPSELECTION_CURVE', self.ColourIndex, 0)
    end
    return emit
end

CreateEmitterAtEntityColoured = function(self, ...) -- Hook the engine CreateEmitterAtEntity command, so we can insert our colour changes here.
    local emit = CreateEmitterAtEntity(self, unpack(arg))
    if self.ColourIndex and self.FactionColour then
        emit:SetEmitterCurveParam('RAMPSELECTION_CURVE', self.ColourIndex, 0)
    end
    
    return emit
end

CreateEmitterOnEntityColoured = function(self, ...) -- Hook the engine CreateEmitterOnEntity command, so we can insert our colour changes here.
    local emit = CreateEmitterOnEntity(self, unpack(arg))
    if self.ColourIndex and self.FactionColour then
        emit:SetEmitterCurveParam('RAMPSELECTION_CURVE', self.ColourIndex, 0)
    end
    
    return emit
end

-- ================================================================================================================
-- Lights class stuff
-- ================================================================================================================

function AddLights(SuperClass)
    -- a quick way to add four different lighttypes to many bones
    return Class(SuperClass) {

        LightBones = nil,

        OnPreCreate = function(self)
            SuperClass.OnPreCreate(self)
            self.LightsBag = TrashBag()
        end,

        OnStopBeingBuilt = function(self, builder, layer)
            SuperClass.OnStopBeingBuilt(self, builder, layer)
            self:AddLights()
        end,

        OnKilled = function(self, instigator, type, overkillRatio)
            self:RemoveLights()
            SuperClass.OnKilled(self, instigator, type, overkillRatio)
        end,

        AddLights = function(self)
            -- adds light emitters to the light bones
            self:RemoveLights()
            if self.LightBones then
                local army, emit, templ = self:GetArmy(), nil, nil

                for i=1, table.getn(self.LightBones) do
                    if self.LightBones[i] then
                        for _, bone in self.LightBones[i] do
                            templ = self:GetLightTemplate(i)
                            for k, v in templ do
                                emit = CreateAttachedEmitter(self, bone, army, v)
                                self.LightsBag:Add( emit )
                                self.Trash:Add( emit )
                            end
                        end
                    end
                end
            else
                WARN('AddLights: No light emitter bones specified. '..repr(self:GetUnitId()))
            end
        end,

        GetLightTemplate = function(self, n)
            return NomadsEffectTemplate['AntennaeLights'..tostring(n)]
        end,

        RemoveLights = function(self)
            if self.LightsBag then
                self.LightsBag:Destroy()
            end
        end,
    }
end

function AddNavalLights(SuperClass)
    -- a quick way to add lights on two antennae of most naval units
    SuperClass = AddLights(SuperClass)
    return Class(SuperClass) {

        LightBone_Left = nil,
        LightBone_Right = nil,

        OnLayerChange = function(self, new, old)
            SuperClass.OnLayerChange(self, new, old)
            if new == 'Water' or 'Land' then
                self:AddLights()
            elseif new == 'Sub' or 'Seabed' then
            self:RemoveLights()
            end
        end,

        OnMotionVertEventChange = function(self, new, old)
            SuperClass.OnMotionVertEventChange(self, new, old)
            local layer = self:GetCurrentLayer()
            if new == 'Down' and layer == 'Water' then
                self:RemoveLights()
            end
        end,

        AddLights = function(self)
            -- adds light emitters to the antennae bones
            self:RemoveLights()
            if self.LightBone_Left and self.LightBone_Right then
                local army, templ, emit = self:GetArmy(), self:GetLightTemplate(0), nil
                for k, v in templ do
                    emit = CreateAttachedEmitter(self, self.LightBone_Left, army, v)
                    self.Trash:Add( emit )
                    self.LightsBag:Add( emit )
                end
                templ = self:GetLightTemplate(1)
                for k, v in templ do
                    emit = CreateAttachedEmitter(self, self.LightBone_Right, army, v)
                    self.Trash:Add( emit )
                    self.LightsBag:Add( emit )
                end
            else
                WARN('AddLights: No light emitter bones specified. '..repr(self:GetUnitId()))
            end
        end,

        GetLightTemplate = function(self, n)
            if n == 0 then
                return NomadsEffectTemplate.NavalAntennaeLights_Left
            end
            return NomadsEffectTemplate.NavalAntennaeLights_Right
        end,
    }
end

-- ================================================================================================================
-- RAPID REPAIR
-- ================================================================================================================

function AddRapidRepair(SuperClass)
    return Class(SuperClass) {

        OnCreate = function(self)
            SuperClass.OnCreate(self)
            self.RapidRepairFxBag = TrashBag()
            self.RapidRepairParams = {}
            self.RapidRepairCounter = -1
        end,

        DoTakeDamage = function(self, instigator, amount, vector, damageType)
            SuperClass.DoTakeDamage(self, instigator, amount, vector, damageType)
            self:DelayRapidRepair()
        end,

        OnStartRapidRepairing = function(self)
            -- when the unit starts to be repaired
        end,

        OnFinishedRapidRepairing = function(self)
            -- when the unit is fully repaired
        end,

        OnRapidRepairingInterrupted = function(self)
            -- when the unit is being repaired but receives damage or fires a weapon
        end,

        OnRapidRepairingDelayed = function(self)
            -- when the unitis NOT being repaired and receives damage or fires a weapon
        end,

        SetRapidRepairParams = function(self, buffName, repairDelay, WeaponFireInterrupts)
            self.RapidRepairParams = {
                buffName = buffName,
                repairDelay = repairDelay or 30,
            }

            if WeaponFireInterrupts ~= nil then
                local nwep, wep = self:GetWeaponCount()
                for i=1, nwep do
                    wep = self:GetWeapon(i)
                    wep.DelaysRapidRepair = WeaponFireInterrupts
                end
            end
        end,

        RapidRepairIsRepairing = function(self)
            -- says whether we're repairing at this moment
            if self.RapidRepairProcessThreadHandle then
                return true
            end
            return false
        end,

        EnableRapidRepair = function(self, enable)
            -- enables or disables the rapid repair process (this is something else than stopping it)
            if enable then
                self.RapidRepairCounter = 0
                if not self.RapidRepairThreadHandle then
                    self.RapidRepairThreadHandle = self:ForkThread( self.RapidRepairThread )
                end
            else
                self.RapidRepairCounter = -1
                self:RapidRepairProcessStop()
                if self.RapidRepairThreadHandle then
                    KillThread( self.RapidRepairThreadHandle )
                    self.RapidRepairThreadHandle = nil
                end
                local buffName = self:GetRapidRepairParam('buffName')
                Buff.RemoveBuff( self, buffName )
            end
        end,

        GetRapidRepairParam = function(self, param)
            if self.RapidRepairParams[ param ] then
                return self.RapidRepairParams[ param ]
            end
        end,

        DelayRapidRepair = function(self)
            -- used to stop and reset the rapid repair process. Should be called if unit is damaged or fires a weapon.
            --LOG('*DEBUG: DelayRapidRepair')
            local repairing = self:RapidRepairIsRepairing()
            self.RapidRepairCounter = math.min( 0, self.RapidRepairCounter )
            self:RapidRepairProcessStop()
            if not repairing then
                self:OnRapidRepairingDelayed()
            end
        end,

        RapidRepairThread = function(self)
            -- counts up and starts the repair process when enough time passed
            local bp = self:GetBlueprint()
            local delay = self:GetRapidRepairParam('repairDelay')

            while not self.Dead and self.RapidRepairCounter >= 0 do

                -- if the timer isn't expired yet, add one to it
                if self.RapidRepairCounter < delay then
                    self.RapidRepairCounter = self.RapidRepairCounter + 1

                -- if the counter is expired but we're not repairing, start repairing
                elseif not self:RapidRepairIsRepairing() and self:GetHealth() < self:GetMaxHealth() then
                    self.RapidRepairProcessThreadHandle = self:ForkThread( self.RapidRepairProcessThread )

                end
                WaitSeconds(1)
            end
        end,

        RapidRepairProcessThread = function(self)

            local buffName = self:GetRapidRepairParam('buffName')

            -- start self repair effects
            self.RapidRepairFxBag:Add( ForkThread( NomadsEffectUtil.CreateSelfRepairEffects, self, self.RapidRepairFxBag ) )
            Buff.ApplyBuff(self, buffName)

            self:OnStartRapidRepairing()

            -- the buff increases regen. Wait till we're done "repairing"
            while not self.Dead and self:GetHealth() < self:GetMaxHealth() and self.RapidRepairCounter > -1 and self.RapidRepairProcessThreadHandle do
                WaitTicks(1)
            end

            -- stop the repair effects
            if Buff.HasBuff( self, buffName ) then
                Buff.RemoveBuff( self, buffName )
            end
            self.RapidRepairFxBag:Destroy()

            self:OnFinishedRapidRepairing()
        end,

        RapidRepairProcessStop = function(self)
            if self.RapidRepairProcessThreadHandle then
                KillThread( self.RapidRepairProcessThreadHandle )
                self.RapidRepairProcessThreadHandle = nil

                -- since we just killed the thread that (also) remove the buff, do it here: stop the repair effects
                local buffName = self:GetRapidRepairParam('buffName')
                if Buff.HasBuff( self, buffName ) then
                    Buff.RemoveBuff( self, buffName )
                end

                self:OnRapidRepairingInterrupted()
            end
            self.RapidRepairFxBag:Destroy()
        end,
    }
end

function AddRapidRepairToWeapon(SuperClass)
    -- should be used for the units weapon classes
    return Class(SuperClass) {

        OnCreate = function(self)
            DelaysRapidRepair = true
            SuperClass.OnCreate(self)
        end,

        OnWeaponFired = function(self)
            SuperClass.OnWeaponFired(self)
            if self.DelaysRapidRepair then
                self.unit:DelayRapidRepair()
            end
        end,
    }
end

-- ================================================================================================================
-- AKIMBO
-- ================================================================================================================

--TODO: Refactor this, or just remove it.
function AddAkimbo( SuperClass )
    return Class(SuperClass) {

        StopBeingBuiltEffects = function(self, builder, layer)
            SuperClass.StopBeingBuiltEffects(self, builder, layer)
            self.AkimboThreadHandle = self:ForkThread( self.AkimboThread )
        end,

        OnStunned = function(self, duration)
            SuperClass.OnStunned(self, duration)
            if self.TorsoRotManip then
                self.TorsoRotManip:SetGoal( self.TorsoRotManip:GetCurrentAngle() )
            end
            if self.HeadRotManip then
                self.HeadRotManip:SetGoal( self.HeadRotManip:GetCurrentAngle() )
            end
        end,

        AkimboThread = function(self)
            -- Keeps the head and torso rotated to the current target position.
            -- The SCU has 2 arms which can individually target enemies. They each have a limited firing arc (yaw) so it is possible that the
            -- arms have a target that's not within the firing arc. This script makes the torso rotate so that at least 1 arm can fire at it's
            -- target. It does it's best to also accomodate the second weapon (gattling) but if it's not possible, the second weapon is assigned
            -- the target of the first weapon.
            -- The head is rotated to face (1) the target of weapon 1, (2) the target of weapon 2, or (3) the movement destination.

            -- TODO: implement [1] support for weapon HeadingArc parameters, [2] non-zero-based default torso yaw (so that it's relaxed
            -- position is not rotation 0 but something else, specified in bp, [3] further optimizations (remove or combine calculations?),
            -- [4] support for third and fourth weapon???

            -- local functions, used to make the code below more readable
            local GetWepTargetPos = function(wep)
                local wepTarget, wepTargetPos
                local target = wep:GetCurrentTarget()
                if target and target.GetPosition then
                    wepTargetPos = target:GetPosition()
                    wepTarget = target
                else
                    wepTargetPos = wep:GetCurrentTargetPos()
                    wepTarget = nil
                end
                return wepTargetPos, wepTarget
            end
            local GetTargetAngle = function(self, wepTargetPos, torsoDir)
                if wepTargetPos then
                    local unitPos = self:GetPosition()
                    local vect = Utils.NormalizeVector( Vector(wepTargetPos.x - unitPos.x, 0, wepTargetPos.z - unitPos.z) )
                    local angle = ( math.atan2(vect.x, vect.z ) - math.atan2( torsoDir.x, torsoDir.z ) ) * 180 / math.pi

                    if angle > 180 then angle = angle - 360
                    elseif angle < -180 then angle = angle + 360
                    end

                    return angle
                end
            end

            local unitDir, unitX, unitY, unitZ, torsoDir, torsoRot, torsoX, torsoY, torsoZ, headTargetPos, wep1Target, wep1TargetPos, wep2TargetPos, wep1CurTargetAngle, wep2CurTargetAngle, minTorsoRotLimit, maxTorsoRotLimit
            local headIntendRot, torsoIntendRot = 0, 0

            local bp = self:GetBlueprint().Display.AkimboControl
            local doHeadRotation = bp.Head or false
            local headBone = bp.HeadBone
            local headRotSpeed = bp.HeadYawSpeed or 50
            local headRotLimit = bp.HeadYawLimit or 25
            local torsoBone = bp.TorsoBone
            local torsoRotSpeed = bp.TorsoYawSpeed or 50
            local torsoRotLimit = bp.TorsoYawRange or 360
            local allowRetarget = bp.AllowRetargettingSecondWeapon or false

            local yawRangeMarginMulti = 1 - 0.05  -- 5% safety margin, decrease firing arc by this much to make sure we interact on time.

            local weps = {}
            weps[1] = self:GetWeaponByLabel( bp.FirstWeapon )
            weps[2] = self:GetWeaponByLabel( bp.SecondWeapon )
            if bp.ThirdWeapon then weps[3] = self:GetWeaponByLabel( bp.ThirdWeapon ) end
            if bp.FourthWeapon then weps[4] = self:GetWeaponByLabel( bp.FourthWeapon ) end
            if bp.FifthWeapon then weps[5] = self:GetWeaponByLabel( bp.FifthWeapon ) end
            if bp.SixthWeapon then weps[6] = self:GetWeaponByLabel( bp.SixthWeapon ) end

            local wepYawRangeMin = {}
            local wepYawRangeMax = {}
            for k, wep in weps do
                local wepBp = wep:GetBlueprint()
                wepYawRangeMin[k] = wepBp.TurretYaw - (wepBp.TurretYawRange * yawRangeMarginMulti) + math.min(3, wepBp.TurretYawRange * yawRangeMarginMulti) -- second half of this line is also for safety
                wepYawRangeMax[k] = wepBp.TurretYaw + (wepBp.TurretYawRange * yawRangeMarginMulti) - math.min(3, wepBp.TurretYawRange * yawRangeMarginMulti) -- second half of this line is also for safety
            end

            local wepTargetPos = {}
            local wepCurTargetAngle = {}
            local PrimaryWeaponTarget = nil

            local nav = self:GetNavigator()  -- can tell us where the unit is heading

            if doHeadRotation then
                self.HeadRotManip = CreateRotator(self, headBone, 'y', nil):SetCurrentAngle(0)
                self.Trash:Add(self.HeadRotManip)
            end
            self.TorsoRotManip = CreateRotator(self, torsoBone, 'y', nil):SetCurrentAngle(0)
            self.Trash:Add(self.TorsoRotManip)

            while not self.Dead do

                -- if we're EMP-ed then wait till we're no longer EMP-ed
                while self:IsStunned() do
                    WaitSeconds( 0.2 )
                end

                -- get torso orientations
                torsoX, torsoY, torsoZ = self:GetBoneDirection(torsoBone)
                torsoDir = Utils.NormalizeVector( Vector( torsoX, 0, torsoZ) )

                -- find current target for weapon 1. We mainly need the position of the target, but the target unit is stored in case we need to retarget wep 2
                local PrimaryWeaponTarget = nil
                local PrimaryWeaponKey = -1
                for k, wep in weps do
                    local pos, trgt = GetWepTargetPos(wep)
                    wepTargetPos[k] = pos
                    if not PrimaryWeaponTarget then
                        PrimaryWeaponTarget = trgt
                        PrimaryWeaponKey = k
                    end
                end

                -- determine angles of both weapons targets. The function returns nil when no target
                local NumWepWithCurTargetAngle = 0
                local CurTargetAngleSum = 0
                for k, wep in weps do
                    wepCurTargetAngle[k] = GetTargetAngle( self, wepTargetPos[k], torsoDir )
                    if wepCurTargetAngle[k] then
                        CurTargetAngleSum = CurTargetAngleSum + wepCurTargetAngle[k]
                        NumWepWithCurTargetAngle = NumWepWithCurTargetAngle + 1
                    end
                end

                -- now find the best rotation for the torso. Ideally the torso rotates so it's in between both targets. In case this is not
                -- possible because the targets too far apart then weapon 1 is prefered and weapon 2 gets the target of weapon 1. If there's just
                -- 1 target then it's easy, and if there is no target at all then just rotate to normal position.
                if NumWepWithCurTargetAngle == 0 then
                    torsoIntendRot = 0  -- no target means no rotation needed

                else

                    -- get torso and main bone orientations. MOved here for efficiency reason from a few lines up, we only need it here
                    unitX, unitY, unitZ = self:GetBoneDirection(0)
                    unitDir = Utils.NormalizeVector( Vector( unitX, 0, unitZ) )
                    torsoRot = ( math.atan2( torsoDir.x, torsoDir.z ) - math.atan2( unitDir.x, unitDir.z ) ) * 180 / math.pi

                    if CurTargetAngleSum == 0 then  -- avoid dividing by 0 (see the else)
                        torsoIntendRot = 0  -- if the target of both weapons is direct forward then no need for a rotation adjustment

                    else

                        -- calculate current torso rotation limits, the torso cannot rotate beyond these values
                        minTorsoRotLimit = -torsoRotLimit - torsoRot
                        maxTorsoRotLimit = torsoRotLimit - torsoRot

                        -- the best angle is calculated here. Works for 1 target aswell since both have the same angle. The max-ing and min-ing is
                        -- for limiting torso rotation (if so intended)
                        torsoIntendRot = math.max( minTorsoRotLimit, math.min( maxTorsoRotLimit, CurTargetAngleSum / NumWepWithCurTargetAngle ))

                        -- Ok, so now we have determined the best ideal angle for the torso. Now checking if it allows both weapons to hit target. If
                        -- not then adjust the angle.
                        -- First weapon 1. If it can't hit target then wep 2 will have to retarget.

                        for k, wep in weps do
                            if not wepCurTargetAngle[k] then
                                continue
                            end
                            
                            local wepYawRangeType = wepYawRangeMin[PrimaryWeaponKey]
                            local angleDifference = wepCurTargetAngle[k] - torsoIntendRot
                            
                            if angleDifference >= wepYawRangeMax[k] then
                                wepYawRangeType = wepYawRangeMax[PrimaryWeaponKey]
                            end
                            
                            if (angleDifference <= wepYawRangeMin[k]) or (angleDifference >= wepYawRangeMax[k]) then
                                if allowRetarget and PrimaryWeaponTarget then  -- retarget wep 2, only if there is a target
                                    wep:SetTargetEntity( PrimaryWeaponTarget )
                                    torsoIntendRot = wepCurTargetAngle[PrimaryWeaponKey]
                                else  -- no valid target, at least let wep 1 fire. Rotate so target 1 is just in firing arc for wep 1
                                    torsoIntendRot = torsoIntendRot + (wepCurTargetAngle[PrimaryWeaponKey] - torsoIntendRot - wepYawRangeType)
                                end
                                
                                torsoIntendRot = math.max( minTorsoRotLimit, math.min( torsoIntendRot, maxTorsoRotLimit)) -- abide torso rotation limit
                            end
                        end
                    end

                    torsoIntendRot = torsoRot + torsoIntendRot  -- don't forget current torso rotation!
                end

                -- Rotate torso with new found rotation!
                self.TorsoRotManip:SetSpeed( torsoRotSpeed ):SetGoal(torsoIntendRot)

                if doHeadRotation then
                    -- Head rotation is next. The head should "look" at target of wep 1, target of wep2, where it is going, or be in default rotation (in this order).
                    headTargetPos = wep1TargetPos or wep2TargetPos or nav:GetCurrentTargetPos() -- Get the location of interest

                    -- calculate the angle for the head rotation. The rotation of the torso is taken into account. Since the head shouldn't rotate
                    -- 360 degrees also limit the rotation.
                    headIntendRot = math.max( -headRotLimit, math.min( headRotLimit, GetTargetAngle( self, headTargetPos, torsoDir )))

                    -- rotate head
                    self.HeadRotManip:SetSpeed( headRotSpeed ):SetGoal(headIntendRot)
                end

                WaitSeconds(0.3) -- rinse and repeat after this
            end
        end,
    }
end

-- ================================================================================================================
-- CAPACITOR
-- ================================================================================================================

function AddCapacitorAbility( SuperClass )
    -- The capacitor ability boosts the unit for a short time. It doesn't work with shielded units because this
    -- ability uses the shield indicator on the unit for the capacity in the capacitor.
        
    return Class(SuperClass) {
    
        CapFxBones = nil,
        CapFxBeingUsedTemplate = NomadsEffectTemplate.CapacitorBeingUsed,
        CapFxChargingTemplate = NomadsEffectTemplate.CapacitorCharging,
        CapFxEmptyTemplate = NomadsEffectTemplate.CapacitorEmpty,
        CapFxFullTemplate = NomadsEffectTemplate.CapacitorFull,
        
        OnCreate = function(self)
            SuperClass.OnCreate(self)
            self:HasCapacitorAbility(true)
            self.Sync.AutoCapacitor = false
            self.Sync.CapacitorState = 'Unfilled' --'Charging' 'Discharging' 'Filled' 'Unfilled'
            self.CapChargeFraction = 0 --from 0 to 1
            
            local bp = self:GetBlueprint().Abilities.Capacitor
            self.CapacitorDecayTime = bp.DecayTime
            self.ChargeEnergyCost = bp.ChargeEnergyCost
            self.CapDuration = bp.Duration
            self.CapChargeTime = bp.ChargeTime
            self.CapFxBag = TrashBag()
        end,
        
        HasCapacitorAbility = function(self, hasIt)
            self.Sync.HasCapacitorAbility = hasIt
        end,
        
        ResetCapacitor = function(self)
            if self.CapChargeFraction == 1 then
                self.CapChargeFraction = 0.99
            end
            if self.CapDischargeThread then
                KillThread(self.CapDischargeThread)
                self:RemoveCapacitorBuffs()
            end
            self.CapacitorSwitchStates['Charging'](self) --set it to the decay state
        end,
        
        SetAutoCapacitor = function(self, autoCap)
            self.Sync.AutoCapacitor = autoCap
            if autoCap and self.Sync.CapacitorState == 'Unfilled' and self.Sync.HasCapacitorAbility then
                self.CapacitorSwitchStates[self.Sync.CapacitorState](self)
            end
        end,
        
        --runs whenever the fraction changes, so all the UIs know what to do
        UpdateCapacitorFraction = function(self)
            --possible math.max(self.CapChargeFraction,0) needed here
            self:SetShieldRatio( self.CapChargeFraction )
        end,
        
        RemoveCapacitorBuffs = function(self)
            local bp = self:GetBlueprint().Abilities
            local buffs = bp.Capacitor.Buffs or {}
            -- remove buffs
            for k, buffName in buffs do
                Buff.RemoveBuff( self, buffName )
            end

            -- notify weapons again
            for i = 1, self:GetWeaponCount() do
                local wep = self:GetWeapon(i)
                if wep.UseCapacitorBoost then
                    wep:OnCapStopBeingUsed()
                end
            end

            self:UpdateConsumptionValues()
            --end the discharging cycle. the capacitor should be empty when RemoveCapacitorBuffs is called.
            self.CapacitorSwitchStates[self.Sync.CapacitorState](self)
        end,
        
        AddCapacitorBuffs = function(self)
            local bp = self:GetBlueprint().Abilities
            local buffs = bp.Capacitor.Buffs or {}

            -- apply buffs
            for k, buffName in buffs do
                Buff.ApplyBuff( self, buffName )
            end

            -- notify weapons
            for i = 1, self:GetWeaponCount() do
                local wep = self:GetWeapon(i)
                if wep.UseCapacitorBoost then
                    wep:OnCapStartBeingUsed( bp.Duration )
                end
            end

            self:UpdateConsumptionValues()
        end,
        
        --cant use states since they would conflict with anything that actually has states. sigh.
        --'Charging' 'Discharging' 'Filled' 'Unfilled'
        --self.CapacitorSwitchStates[self.Sync.CapacitorState](self)
        CapacitorSwitchStates = {
            -- When the capacitor is not full or charging
            Unfilled = function(self)
                self.Sync.CapacitorState = 'Charging'
                
                self:PlayCapEffects(self.CapFxChargingTemplate)
                self:StopUnitAmbientSound('CapacitorInUseLoop')
                self:PlayUnitSound('CapacitorStartCharging')
                
                --end the decay thread if there is one
                if self.CapDecayThread then
                    KillThread(self.CapDecayThread)
                end
                
                self.CapChargeThread = self:ForkThread( self.CapacitorChargeThread )
            end,
            
            -- When the capacitor is full and ready to discharge
            Filled = function(self)
                self.Sync.CapacitorState = 'Discharging'
            
                self:PlayCapEffects(self.CapFxBeingUsedTemplate)
                self:PlayUnitSound('CapacitorStartBeingUsed')
                self:PlayUnitAmbientSound('CapacitorInUseLoop')
                
                self:AddCapacitorBuffs()
                --start discharge thread
                self.CapDischargeThread = self:ForkThread( self.CapacitorDischargeThread )
            end,
            
            -- When the capacitor is draining energy and charging
            Charging = function(self)
                if self.CapChargeFraction == 1 then
                    self.Sync.CapacitorState = 'Filled'
                    
                    self:PlayCapEffects(self.CapFxFullTemplate)
                    self:StopUnitAmbientSound('CapacitorInUseLoop')
                    self:PlayUnitSound('CapacitorFull')
                    AddVOUnitEvent(self, 'CapacitorFull')
                else
                    self.Sync.CapacitorState = 'Unfilled'
                    --cancel the charging
                    self.Sync.AutoCapacitor = false
                    if self.CapChargeThread then
                        KillThread(self.CapChargeThread)
                        self:SetMaintenanceConsumptionInactive()
                    end
                    
                    self.CapFxBag:Destroy()
                    self:StopUnitAmbientSound('CapacitorInUseLoop')
                    self:PlayUnitSound('CapacitorStopBeingUsed')
                    --start decay thread
                    self.CapDecayThread = self:ForkThread( self.CapacitorDecayThread )
                end
            end,
            
            -- When the capacitor is applying buffs and discharging
            Discharging = function(self)
                --you cant cancel the discharge halfway through
                if self.CapChargeFraction == 0 then
                    self.Sync.CapacitorState = 'Unfilled'
                    
                    self.CapFxBag:Destroy()
                    self:StopUnitAmbientSound('CapacitorInUseLoop')
                    self:PlayUnitSound('CapacitorEmpty')
                    
                    --start charging if we have autocap on.
                    if self.Sync.AutoCapacitor then
                        self.CapacitorSwitchStates[self.Sync.CapacitorState](self)
                    end
                end
            end,
        },
        
        --TODO: add energy stall slowdown to this(?)
        CapacitorChargeThread = function(self)
            self:SetEnergyMaintenanceConsumptionOverride(self.ChargeEnergyCost or 500)
            self:SetMaintenanceConsumptionActive()
            while self.CapChargeFraction < 1 do
                WaitTicks(1)
                self.CapChargeFraction = self.CapChargeFraction + (0.1 / self.CapChargeTime)
                self:UpdateCapacitorFraction()
            end
            self:SetMaintenanceConsumptionInactive()
            --finish charging
            self.CapChargeFraction = 1
            self.CapacitorSwitchStates[self.Sync.CapacitorState](self)
        end,
        
        CapacitorDischargeThread  = function(self)
            while self:IsStunned() do  -- dont waste capacitor time being stunned
                WaitTicks(1)
            end
            while self.CapChargeFraction > 0 do
                self.CapChargeFraction = self.CapChargeFraction - (0.1 / self.CapDuration)
                self:UpdateCapacitorFraction()
                WaitTicks(1)
            end
            self.CapChargeFraction = 0
            self:UpdateCapacitorFraction()
            self:RemoveCapacitorBuffs()
        end,
        
        CapacitorDecayThread  = function(self)
            while self.CapChargeFraction > 0 do
                self.CapChargeFraction = self.CapChargeFraction - (0.1 / self.CapacitorDecayTime)
                self:UpdateCapacitorFraction()
                WaitTicks(1)
            end
            self.CapChargeFraction = 0
            self:UpdateCapacitorFraction()
        end,

        PlayCapEffects = function(self, effects)
            self.CapFxBag:Destroy()
            local ox, oy, oz
            local army, emit = self:GetArmy()
            for bk, bone in self.CapFxBones do
                ox = self.CapFxBonesOffsets[bk][1] or 0
                oy = self.CapFxBonesOffsets[bk][2] or 0
                oz = self.CapFxBonesOffsets[bk][3] or 0
                for k, v in effects do
                    emit = CreateAttachedEmitter(self, bone, army, v)
                    emit:OffsetEmitter(ox, oy, oz)
                    self.CapFxBag:Add(emit)
                end
            end
        end,
        
        -- don't do shield things
        EnableShield = function(self)
            WARN('Nomads: EnableShield: Shields disabled by capacitor ability on unit ['..repr(self:GetUnitId() or "Unknown")..'].!')
        end,

        DisableShield = function(self)
            WARN('Nomads: DisableShield: Shields disabled by capacitor ability on unit ['..repr(self:GetUnitId() or "Unknown")..'].!')
        end,
    }
end


function AddCapacitorAbilityToWeapon( SuperClass )
    -- The capacitor ability code for weapons

    return Class(SuperClass) {

        UseCapacitorBoost = true,

        CapGetWepAffectingEnhancementBP = function(self)
            -- Overwrite on SCUs and ACUs to have support for weapon enhancements. There are requirements to the values in the returned table.
            -- All values in the enhancement should begin with "New". See code below to find all supported bp values.
            return {}
        end,

        OnCapStartBeingUsed = function(self, duration)
            -- Changes several aspects of the weapon. Please note that ROF is handled through a unit buff. It is actually the only weapon
            -- aspect that can be handled this way. Using buffs is needed for compatibility with other features such as bombard.
            --LOG('*DEBUG: wep OnCapStartBeingUsed( duration = '..repr(duration)..')')

            local ebp = self:CapGetWepAffectingEnhancementBP()
            local wbp = self:GetBlueprint()
            local newProjwbp = ebp.NewProjectileIdDuringCapacitor or wbp.ProjectileIdDuringCapacitor or wbp.ProjectileId

            self:ChangeProjectileBlueprint(newProjwbp)
        end,

        OnCapStopBeingUsed = function(self)
            --LOG('*DEBUG: wep OnCapStopBeingUsed()')
            local wbp = self:GetBlueprint()
            local newProjwbp = wbp.ProjectileId

            self:ChangeProjectileBlueprint(newProjwbp)
        end,
    }
end

-- ================================================================================================================
-- ANCHOR
-- ================================================================================================================

function AddAnchorAbilty(SuperClass)
    return Class(SuperClass) {

        EnableAnchor = function(self)
            local bp = self:GetBlueprint().Abilities.Anchor
            local BuffName = bp.Buff or 'AnchorModeImmobilize'
            Buff.ApplyBuff(self, BuffName)
        end,

        DisableAnchor = function(self)
            local bp = self:GetBlueprint().Abilities.Anchor
            local BuffName = bp.Buff or 'AnchorModeImmobilize'
            Buff.RemoveBuff(self, BuffName)
        end,
    }
end
