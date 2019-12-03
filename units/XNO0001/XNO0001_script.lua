-- The surface support vehicle that's in orbit

local NOrbitUnit = import('/lua/nomadsunits.lua').NOrbitUnit
local NCommandFrigateUnit = import('/lua/nomadsunits.lua').NCommandFrigateUnit
local NIFOrbitalBombardmentWeapon = import('/lua/nomadsweapons.lua').NIFOrbitalBombardmentWeapon


xno0001 = Class(NOrbitUnit, NCommandFrigateUnit) {
    Weapons = {
        OrbitalMissileLauncher = Class(NIFOrbitalBombardmentWeapon) {},
        OrbitalMissileLauncherHeavy = Class(NIFOrbitalBombardmentWeapon) {},
    },

    ConstructionArmAnimManip = nil,
    BuildBones = { 0, },
    BuildEffectsBag = nil,
    ThrusterEffectsBag = nil,
    
    OnCreate = function(self)
        self.EngineEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()
        self.BuildEffectsBag = TrashBag()
        NOrbitUnit.OnCreate(self)
        
        local bp = self:GetBlueprint()
        if bp.Display.AnimationBuildArm then
            self.ConstructionArmAnimManip = CreateAnimator( self ):PlayAnim( bp.Display.AnimationBuildArm ):SetRate(0)
        end

        self.OrbitalStrikeCurWepTarget = {}
        self.OrbitalStrikeDbKey = {}
        self.OrbitalSpawnQueue = {}
        self:Landing(false)
    end,

    LandingThread = function(self, EnableThrusters)
        NCommandFrigateUnit.LandingThread(self, EnableThrusters)
        self.MovementThread(self) --after landing enable following its target
    end,

-- =========================================================================================
-- Probes

    LaunchProbe = function(self, location, probeType, data)
        if not location or not probeType or not data then
            WARN('Nomads: LaunchProbe missing information. Location = '..repr(location)..' Probe type = '..repr(probeType)..' data = '..repr(data))
            return nil
        end
        local projectileBpID = '/projectiles/NIntelProbe1/NIntelProbe1_proj.bp'
        local bone = 'MissilePort08'
        local dx, dy, dz = self:GetBoneDirection( bone )
        local pos = self:GetPosition( bone )
        local proj = self:CreateProjectile( projectileBpID, pos.x, pos.y, pos.z, dx, dy, dz )
        Warp( proj, pos )
        local projBp = proj:GetBlueprint()
        proj:SetVelocity( dx, dy, dz )
        proj:SetVelocity( projBp.InitialSpeed or projBp.Speed or projBp.MaxSpeed or 5 )
        proj:SetNewTargetGround( location )
        proj:TrackTarget(true)
        
        local probeUnit = proj:AddProbeUnit(probeType)
        probeUnit.Lifetime = data.Lifetime
        return probeUnit
    end,

-- =========================================================================================
-- Orbital striking
-- We create a queue in case multiple units order orbital strikes, so that they all get processed.
-- The weapon scripts then remove their entry from the queue after firing.
    OrbitalBombardmentQueue = {},
    
    OnGivenNewTarget = function(self, targetPosition, HeavyBombardment)
        table.insert(self.OrbitalBombardmentQueue,{targetPosition, HeavyBombardment})
        if not self.BombardmentThread then
            self.BombardmentThread = self:ForkThread( self.OrbitalBombardmentThread )
        end
    end,
    
    OrbitalBombardmentThread = function(self)
        while table.getn(self.OrbitalBombardmentQueue) > 0 do
            self:LaunchOrbitalStrike(self.OrbitalBombardmentQueue[1][1], self.OrbitalBombardmentQueue[1][2])
            WaitSeconds(0.1)
        end
        self.BombardmentThread = nil
    end,
    
    LaunchOrbitalStrike = function(self, targetPosition, HeavyBombardment)
        local weaponLabel = 'OrbitalMissileLauncher'
        if HeavyBombardment then weaponLabel = 'OrbitalMissileLauncherHeavy' end
        
        local weapon = self:GetWeaponByLabel(weaponLabel)
        weapon:SetTargetGround( targetPosition )
        weapon:OnFire()
    end,

-- =========================================================================================
-- Spawning Orbital Units (not called constructing to avoid confusion)

-- scripted construction, so not via the engine and regular engineer methods. This is for animations really.
    SpawningThreadHandle = nil,

    AddToSpawnQueue = function(self, unitType, parentUnit, attachBone )
        -- puts on the build queue to create a unit of the given type. If a callback is passed it will be run when the unit is
        -- constructed.
        if unitType and type(unitType) == 'string' then
            if parentUnit and parentUnit:GetEntityId() then
                self.OrbitalSpawnQueue[parentUnit:GetEntityId()] = { unitType = unitType, parentUnit = parentUnit or false, attachBone = attachBone or 0, }
            else
                WARN('Nomads: parent unit is missing or misformated when requesting orbital spawn! Attempting to spawn unit without parent.')
                --normally the entity ID is unique. with no parent, we create a unique identifier for this table
                --"a" suffix differentiates from entity IDs. the rest loops through incase there are more unparented entries in the table
                local IDSalt = 1
                while self.OrbitalSpawnQueue["a" .. IDSalt] and IDSalt < 100 do
                    IDSalt = IDSalt + 1
                end
                self.OrbitalSpawnQueue["a" .. IDSalt] = { unitType = unitType, parentUnit = parentUnit or false, attachBone = attachBone or 0, }
            end
            self:CheckSpawnQueue()
        else
            WARN('Nomads: Unit type missing or not a string when requesting orbital spawn. Aborting attempt.')
        end
    end,

    CheckSpawnQueue = function(self)
        if not self.UnitBeingBuilt and table.getn(table.keys(self.OrbitalSpawnQueue)) > 0 then
            self.UnitBeingBuilt = true --in case of multiple calls in the same tick since forkthread has a tick delay
            self.SpawningThreadHandle = self:ForkThread( self.SpawnUnitInOrbit )
            self.Trash:Add( self.SpawningThreadHandle )
        end
    end,

    SpawnUnitInOrbit = function(self)
        --find an entry in the table. if its empty then do nothing.
        local key = table.keys(self.OrbitalSpawnQueue)[1]
        
        if not key then WARN('Nomads: called SpawnUnitInOrbit without valid queue format. Something is quite wrong. Aborting spawn.') return end
        
        --local attachBone = self.OrbitalSpawnQueue[1].attachBone or 0
        local attachBone = 0
        local unitBp = self.OrbitalSpawnQueue[key].unitType

        if self.ConstructionArmAnimManip then
            self.ConstructionArmAnimManip:SetRate(1)
            WaitFor( self.ConstructionArmAnimManip )
        end

        -- TODO: When the unit is ready and it has proper bones then uncomment these 2 lines and remove the createUnitHPR line with x + 5 in it
        local x, y, z =  unpack(self:GetPosition( attachBone ))
        -- local unit = CreateUnitHPR( unitBp, self:GetArmy(), x, y, z, 0, 0, 0 )
        local unit = CreateUnitHPR( unitBp, self:GetArmy(), x + 5, y, z, 0, 0, 0 )
        self.UnitBeingBuilt = unit
        unit:SetIsValidTarget(false)
        unit:SetImmobile(true)
        -- unit:AttachBoneTo( self.OrbitalSpawnQueue[key].attachBone or 0, self, attachBone )

        -- animation goes here

        WaitTicks(20)
        
        -- construction done
        unit:DetachFrom()
        unit:SetIsValidTarget(true)
        unit:SetImmobile(false)

        -- move the unit out of the way
        self:RollOffUnit()

        -- let the unit know its spawned. it should figure out the rest from there.
        if unit.OnSpawnedInOrbit then
            unit:OnSpawnedInOrbit(self.OrbitalSpawnQueue[key].parentUnit)
        end

        -- clean up spawning mechanism & flags
        self.UnitBeingBuilt = false
        self.OrbitalSpawnQueue[key] = nil --remove item in the list

        -- wait a short while for the new unit to clear the spawn area
        if self.ConstructionArmAnimManip then
            self.ConstructionArmAnimManip:SetRate(-1)
            WaitFor(self.ConstructionArmAnimManip)
        else
            WaitSeconds(2)
        end

        -- see if there's more to build
        self:CheckSpawnQueue()
    end,

    RollOffUnit = function(self)
        local spin, x, y, z = self:CalculateRollOffPoint()
        local units = { self.UnitBeingBuilt }
        self.MoveCommand = IssueMove(units, Vector(x, y, z))
    end,

    CalculateRollOffPoint = function(self)
        local bp = self:GetBlueprint().Physics.RollOffPoints
        local px, py, pz = unpack(self:GetPosition())

        if not bp then
            return 0, px, py, pz
        end

        local bpP = bp[1]
        local fx, fy, fz, spin
        fx = bpP.X + px
        fy = bpP.Y + py
        fz = bpP.Z + pz
        return spin, fx, fy, fz
    end,    



-- =========================================================================================
-- movement behaviour

    MovementThread = function(self)
        while self and not self:BeenDestroyed() do
            if self.UnitToFollow then
                self.MovementLocation = self.UnitToFollow:GetPosition()
            elseif not self.MovementLocation then
                self.MovementLocation = self:GetPosition()
            end
            
            local position = self:GetPosition()
            local dist = VDist2(position[1], position[3], self.MovementLocation[1], self.MovementLocation[3])
            if dist > 25 and not self.CurrentlyMoving then
                self.MoveCommand = IssueMove({self}, self.MovementLocation)
            else
                self.MoveCommand = nil
            end
            
            WaitSeconds(3)
        end
    end,

    --accepts either a unit to follow, a target location, or false to stay still
    SetMovementTarget = function(self, Target)
        if Target and IsUnit(Target) then
            self.UnitToFollow = Target
        else
            self.UnitToFollow = nil
            if Target == false then
                self.MovementLocation = self:GetPosition()
            else
                self.MovementLocation = Target
            end
        end
    end,

    OnMotionHorzEventChange = function(self, new, old)
        if new == 'Stopped' then
            self:ForkThread(function()
                self:StopEngines()
            end)
            self.CurrentlyMoving = false --this is needed because IsMoving gives weird results - the unit thinks its moving for a while after it stopped.
        end

        if old == 'Stopped' then
            self:ForkThread(function()
                self:AddEffects(self.EngineFireEffects, self.EngineExhaustBones, self.EngineEffectsBag, 0.3)
            end)
            self.CurrentlyMoving = true
        end

        NOrbitUnit.OnMotionHorzEventChange(self, new, old)
    end,

}

TypeClass = xno0001