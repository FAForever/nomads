-- The surface support vehicle that's in orbit

local NOrbitUnit = import('/lua/nomadsunits.lua').NOrbitUnit
local OrbitalMissileWeapon = import('/lua/nomadsweapons.lua').OrbitalMissileWeapon
local CreateNomadsBuildSliceBeams = import('/lua/nomadseffectutilities.lua').CreateNomadsBuildSliceBeams
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

xno0001 = Class(NOrbitUnit) {
    Weapons = {
        OrbitalGun1 = Class(OrbitalMissileWeapon) {},
        OrbitalGun2 = Class(OrbitalMissileWeapon) {},
        OrbitalGun3 = Class(OrbitalMissileWeapon) {},
        OrbitalGun4 = Class(OrbitalMissileWeapon) {},
        OrbitalGun5 = Class(OrbitalMissileWeapon) {},
        OrbitalGun6 = Class(OrbitalMissileWeapon) {},
        OrbitalGun7 = Class(OrbitalMissileWeapon) {},
        OrbitalGun8 = Class(OrbitalMissileWeapon) {},
        OrbitalGun9 = Class(OrbitalMissileWeapon) {},
        OrbitalGun10 = Class(OrbitalMissileWeapon) {},
    },

    ConstructionArmAnimManip = nil,
    BuildBones = { 0, },
    BuildEffectsBag = nil,
    ThrusterEffectsBag = nil,
    returnposition = nil,
    targetCoordinates = nil,

    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
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
        self.returnposition = Vector(self:GetPosition()[1], self:GetPosition()[2], self:GetPosition()[3]) --why is this like this
        self.MoveAway(self)
    end,

-- =========================================================================================
-- Rotators

    SetupRotators = function(self)
        local bp = self:GetBlueprint().Rotators
        if not self.RotatorOuter then
            self.RotatorOuter = CreateRotator( self, 'Deflector Edge', 'z' )
            self.RotatorOuter:SetAccel( bp.OuterAcceleration )
            self.RotatorOuter:SetTargetSpeed( bp.OuterSpeed )
            self.Trash:Add( self.RotatorOuter )
        end
        if not self.RotatorInner then
            self.RotatorInner = CreateRotator( self, 'Deflector Centre', 'z' )
            self.RotatorInner:SetAccel( bp.InnerAcceleration )
            self.RotatorInner:SetTargetSpeed( bp.InnerSpeed )
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
            WARN('*DEBUG: LaunchProbe missing information. Location = '..repr(location)..' projBp = '..repr(projBp)..' data = '..repr(data))
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

    OnGivenNewTarget = function(self, targetPosition)
        local wep
        local c = self:GetWeaponCount()
        for w=1, c do
            wep = self:GetWeapon(w)
            if wep:ReadyToFire() then
                wep:AssignTarget( targetPosition )
                return true
            end
        end
        LOG('*DEBUG: Couldnt fire orbital strike, all weapons are busy')
        return false
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

-- engines
    --ThrusterBurnBones = {'ExhaustBig', 'ExhaustSmallRight', 'ExhaustSmallLeft', 'ExhaustSmallTop'},
    ThrusterBurnBones = {'Engine Exhaust01', 'Engine Exhaust02', 'Engine Exhaust03', 'Engine Exhaust04', 'Engine Exhaust05', }, --rename to EngineBones ?

    BurnEngines = function(self)
        local army, emit = self:GetArmy()
        local ThrusterEffects = {
            '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster05_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster01_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster02_emit.bp',
        }
        ForkThread( function()
            for i = 1, 4 do
                for _, bone in self.ThrusterBurnBones do
                    emit = CreateAttachedEmitter( self, bone, army, ThrusterEffects[i] )
                    self.ThrusterEffectsBag:Add( emit )
                    self.Trash:Add( emit )
                    WaitSeconds(0.2)
                end
                WaitSeconds(1.5)
            end
        end)
    end,

    StopEngines = function(self)
        self.ThrusterEffectsBag:Destroy()
        local army, emit = self:GetArmy()
        local ThrusterEffects = {
            '/effects/emitters/nomads_orbital_frigate_thruster03_emit.bp',
            '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',
        }
        ForkThread( function()
            for i = 1, 2 do
                for _, bone in self.ThrusterBurnBones do
                    emit = CreateAttachedEmitter( self, bone, army, ThrusterEffects[i] )
                    self.ThrusterEffectsBag:Add( emit )
                    self.Trash:Add( emit )
                end
            end
            WaitSeconds(1)
            self.ThrusterEffectsBag:Destroy()
            for _, bone in self.ThrusterBurnBones do
                emit = CreateAttachedEmitter( self, bone, army, ThrusterEffects[2] )
                self.ThrusterEffectsBag:Add( emit )
                self.Trash:Add( emit )
            end
            WaitSeconds(5)
            self.ThrusterEffectsBag:Destroy()
        end)
    end,



-- movement behavior
    MoveAway = function(self)
        local positionX, positionZ, positionY = unpack(self:GetPosition())
        local mapsizeX, mapsizeY = GetMapSize()
        local distanceX = mapsizeX/2 - positionX
        local distanceY = mapsizeY/2 - positionY

        if math.abs(distanceX) < math.abs(distanceY) then
            if distanceY < 0 then
                self.targetCoordinates = Vector(positionX + Random(mapsizeX/5)-mapsizeX/10, positionZ, mapsizeY - 2)
            else
                self.targetCoordinates = Vector(positionX + Random(mapsizeX/5)-mapsizeX/10, positionZ, 2)
            end
        else
            if distanceX < 0 then
                self.targetCoordinates = Vector(mapsizeX - 2, positionZ, positionY + Random(mapsizeY/5)-mapsizeY/10)
            else
                self.targetCoordinates = Vector(2, positionZ, positionY + Random(mapsizeY/5)-mapsizeY/10)
            end
        end

        self.MoveCommand = IssueMove({self}, self.targetCoordinates)
        self:BurnEngines()

        self:CheckIfAtTarget()
    end,

    ReturnToStartLocation = function(self)
        if self:GetPosition() == self.returnposition then return end
        self.MoveCommand = IssueMove({self}, self.returnposition)
        self:BurnEngines()
        self:CheckIfAtTarget(self.returnposition)
    end,

    CheckIfAtTarget = function(self)
        ForkThread(function()
            local arrivedAtTarget = false
            WaitSeconds(3)

            while not arrivedAtTarget do
                if (self:GetPosition()[1]-self.targetCoordinates[1])^2 + (self:GetPosition()[3]-self.targetCoordinates[3])^2 < 10 then
                    arrivedAtTarget = true
                    self:StopEngines()
                    self.MoveCommand = nil
                end
                WaitSeconds(1)
            end
        end)
    end,

}

TypeClass = xno0001