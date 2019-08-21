-- The surface support vehicle that's in orbit

local NOrbitUnit = import('/lua/nomadsunits.lua').NOrbitUnit
local NIFOrbitalBombardmentWeapon = import('/lua/nomadsweapons.lua').NIFOrbitalBombardmentWeapon


xno0001 = Class(NOrbitUnit) {
    Weapons = {
        OrbitalMissileLauncher = Class(NIFOrbitalBombardmentWeapon) {},
        OrbitalMissileLauncherHeavy = Class(NIFOrbitalBombardmentWeapon) {},
    },

    ConstructionArmAnimManip = nil,
    BuildBones = { 0, },
    BuildEffectsBag = nil,
    ThrusterEffectsBag = nil,

    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        self.EngineEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()

        NOrbitUnit.OnCreate(self)

        --self:SetupRotators()
        local bp = self:GetBlueprint()
        if bp.Display.AnimationBuildArm then
            self.ConstructionArmAnimManip = CreateAnimator( self ):PlayAnim( bp.Display.AnimationBuildArm ):SetRate(0)
        end

        self.OrbitalStrikeCurWepTarget = {}
        self.OrbitalStrikeDbKey = {}
        self.OrbitalSpawnQueue = {}
        --self.returnposition = Vector(self:GetPosition()[1], self:GetPosition()[2], self:GetPosition()[3]) --why is this like this
        self:Landing(false)
    end,

-- =========================================================================================
-- Rotators

    SetupRotators = function(self)
        local bp = self:GetBlueprint().Rotators
        if not self.RotatorOuter then
            self.RotatorOuter = CreateRotator( self, 'Deflector Edge', 'z' )
            self.RotatorOuter:SetAccel( bp.OuterAcceleration )
            self.RotatorOuter:SetTargetSpeed( bp.OuterSpeed )
            self.RotatorOuter:SetSpeed( bp.OuterSpeed )
            self.Trash:Add( self.RotatorOuter )
        end
        if not self.RotatorInner then
            self.RotatorInner = CreateRotator( self, 'Deflector Centre', 'z' )
            self.RotatorInner:SetAccel( bp.InnerAcceleration )
            self.RotatorInner:SetTargetSpeed( bp.InnerSpeed )
            self.RotatorInner:SetSpeed( bp.InnerSpeed )
            self.Trash:Add( self.RotatorInner )
        end
    end,

    StopRotators = function(self)
        if self.RotatorOuter then
            self.RotatorOuter:SetTargetSpeed( 0 )
        end
        if self.RotatorInner then
            self.RotatorInner:SetTargetSpeed( 0 )
        end      
    end,
    
    StartRotators = function(self)
        local bp = self:GetBlueprint().Rotators
        if self.RotatorOuter then
            self.RotatorOuter:SetTargetSpeed( bp.OuterSpeed )
        end
        if self.RotatorInner then
            self.RotatorInner:SetTargetSpeed( bp.InnerSpeed )
        end
    end,

-- =========================================================================================
-- Probes

    LaunchProbe = function(self, location, projBp, data)
        if not location or not projBp or not data then
            WARN('Nomads: LaunchProbe missing information. Location = '..repr(location)..' projBp = '..repr(projBp)..' data = '..repr(data))
            return nil
        end

        local bone = 'MissilePort08'
        local dx, dy, dz = self:GetBoneDirection( bone )
        local pos = self:GetPosition( bone )
        local proj = self:CreateProjectile( projBp, pos.x, pos.y, pos.z, dx, dy, dz )
        proj:PassData( data )
        Warp( proj, pos )
        local projBp = proj:GetBlueprint()
        proj:SetVelocity( dx, dy, dz )
        proj:SetVelocity( data.FlightSpeed or projBp.InitialSpeed or projBp.Speed or projBp.MaxSpeed or 5 )
        proj:SetNewTargetGround( location )
        proj:TrackTarget(true)
        return proj
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

    --this worked perfectly so long as there was only one weapon to fire, now its obsolete
    OnGivenNewTargetOld = function(self, targetPosition)
        IssueTactical( {self}, targetPosition )
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
-- engines
    EngineExhaustBones = {'Engine Exhaust01', 'Engine Exhaust02', 'Engine Exhaust03', 'Engine Exhaust04', 'Engine Exhaust05', },
    ThrusterExhaustBones = { 'ThrusterPort01', 'ThrusterPort02', 'ThrusterPort03', 'ThrusterPort04', 'ThrusterPort05', 'ThrusterPort06', },
    EngineFireEffects = { --for when the engine is on full power
        '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',--smoke
        '/effects/emitters/nomads_orbital_frigate_thruster05_emit.bp',--smoke
        '/effects/emitters/nomads_orbital_frigate_thruster01_emit.bp',--fire
        '/effects/emitters/nomads_orbital_frigate_thruster02_emit.bp',--fire
    },
    EnginePartialEffects = { --hot air effects only
        --'/effects/emitters/nomads_orbital_frigate_thruster03_emit.bp', --this one looks dumb
        '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',
    },
    ThrusterEffects = { --hot air effects only
        --'/effects/emitters/nomads_orbital_frigate_thruster03_emit.bp', --this one looks dumb
        '/effects/emitters/aeon_t1eng_groundfx01_emit.bp',
    },

    StopEngines = function(self)
        self.EngineEffectsBag:Destroy()
        self:AddEffects(self.EnginePartialEffects, self.EngineExhaustBones, self.EngineEffectsBag)
        WaitSeconds(4.5)
        self.EngineEffectsBag:Destroy()
    end,
    
    Landing = function (self, EnableThrusters)
        self:HideBone(0, true)
        --start rotators
        self:SetupRotators()
        self:StopRotators() --start slowing them down
        
        self:AddEffects(self.EngineFireEffects, self.EngineExhaustBones, self.EngineEffectsBag)
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/xno0001/xno0001_entry01.sca')
        --self.LaunchAnim:SetAnimationFraction(0.3)
        self.LaunchAnim:SetRate(0.1)
        self.Trash:Add(self.LaunchAnim)
        
        self:ForkThread(function(self, EnableThrusters)
            WaitSeconds(0.1)
            self:ShowBone(0, true)
            WaitSeconds(3.5)
            if EnableThrusters then
                self:AddEffects(self.ThrusterEffects, self.ThrusterExhaustBones, self.ThrusterEffectsBag)
            end
            WaitSeconds(1)
            self:StopEngines()
            --self.MoveAway(self)
            self.MovementThread(self)
        end, EnableThrusters)
    end,

    AddEffects = function (self, effects, bones, bag, delay)
        local army, emit = self:GetArmy()
        for _, effect in effects do
            for _, bone in bones do
                emit = CreateAttachedEmitter(self, bone, army, effect)
                bag:Add(emit)
                self.Trash:Add(emit)
                if delay then --you need to fork the thread for that!
                    WaitSeconds(delay)
                end
            end
        end
    end,

-- =========================================================================================
-- movement behavior

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