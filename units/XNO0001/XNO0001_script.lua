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

    OnPreCreate = function(self)
        --yes i know this is disgusting but it has to be done since the nomads orbital ship crashes the game
        --so it needs an exception FIXME: refactor nomads orbital frigate so its not so crazy.

        self.ColourIndex = 5 --default nomads colour apparently. This makes it not call the DetermineColourIndex later on.

        NOrbitUnit.OnPreCreate(self)
    end,

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
        self.returnposition = Vector(self:GetPosition()[1], self:GetPosition()[2], self:GetPosition()[3])
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
-- Constructing

-- scripted construction, so not via the engine and regular engineer methods. This is for animations really.

    BuildQueue = {
    --   { unitType = 'xxx', cb = yyy, attachBone = zzz, },
    },
    Constructing = false,
    ConstructingThreadHandle = nil,

    AddToConstructionQueue = function(self, unitType, cb, attachBone )
        -- puts on the build queue to create a unit of the given type. If a callback is passed it will be run when the unit is
        -- constructed.

        if unitType and type(unitType) == 'string' then
            if cb and type(cb) ~= 'function' then
                WARN('xno0001: AddToConstructionQueue(): Passed callback is not a function! Ignoring it.')
                cb = nil
            end
            table.insert( self.BuildQueue, { unitType = unitType, cb = cb, attachBone = attachBone, } )
            self:MaybeStartConstruction()
            return true
        else
            WARN('xno0001: AddToConstructionQueue(): Passed unit type is not a string.')
        end
        return false
    end,

    OnConstructionFinished = function(self, unit)
    end,

    MaybeStartConstruction = function(self)
        if not self.Constructing and table.getn( self.BuildQueue ) > 0 then
            local keys = table.keys( self.BuildQueue )
            local queueKey = keys[1]
            self.ConstructingThreadHandle = self:ForkThread( self.StartConstruction, queueKey )
            self.Trash:Add( self.ConstructingThreadHandle )
        end
    end,

    StartConstruction = function( self, queueKey )

        self.Constructing = true

        local attachBone = 0
        local unitBp = self.BuildQueue[ queueKey ].unitType

        if self.ConstructionArmAnimManip then
            self.ConstructionArmAnimManip:SetRate(1)
            WaitFor( self.ConstructionArmAnimManip )
        end

-- TODO: When the unit is ready and it has proper bones then uncomment these 2 lines and remove the createUnitHPR line with x + 5 in it
        local x, y, z =  unpack(self:GetPosition( attachBone ))
--        local unit = CreateUnitHPR( unitBp, self:GetArmy(), x, y, z, 0, 0, 0 )
        local unit = CreateUnitHPR( unitBp, self:GetArmy(), x + 5, y, z, 0, 0, 0 )
        self.UnitBeingBuilt = unit
        unit:SetIsValidTarget(false)
        unit:SetImmobile(true)
--        unit:AttachBoneTo( self.BuildQueue[ queueKey ].attachBone or 0, self, attachBone )

        -- build effects
        if unit:GetBlueprint().Display.BuildMeshBlueprint then
            unit:SetMesh(unit:GetBlueprint().Display.BuildMeshBlueprint, true)
        end
        local layer = self:GetCurrentLayer()
        unit:StartBeingBuiltEffects( self, layer)
        local effectThread = ForkThread( CreateNomadsBuildSliceBeams, self, unit, self.BuildBones, self.BuildEffectsBag )

        -- build process
        local Ticks = math.ceil( unit:GetBlueprint().Economy.BuildTime or 10000 ) / 100
        local tick = 0
        local progress = 0

        -- building the unit
        while not self:IsDead() and progress < 1 do
            progress = tick / Ticks
            unit:SetHealth( nil, progress * unit:GetMaxHealth() )
            self:SetWorkProgress( progress )
            WaitTicks(1)
            tick = tick + 1
        end

        -- construction done!
        unit:DetachFrom()
        unit:SetIsValidTarget(true)
        unit:SetImmobile(false)

        -- remove building effects
        if unit:GetBlueprint().Display.BuildMeshBlueprint then
            unit:SetMesh(unit:GetBlueprint().Display.MeshBlueprint, true)
        end
        KillThread(effectThread)
        self:StopBuildingEffects()

        -- move the unit out of the way
        self:RollOffUnit()

        -- say we're done construction a unit
        self:OnConstructionFinished( unit, queueKey)

        -- do callback if available
        local cb = self.BuildQueue[ queueKey ].cb
        if cb then
            cb( unit )
        end

        -- some last things
        self.UnitBeingBuilt = nil
        self.Constructing = false
        table.remove( self.BuildQueue, queueKey )

        -- wait a short while for the new unit to clear the construction area
        if self.ConstructionArmAnimManip then
            self.ConstructionArmAnimManip:SetRate(-1)
            WaitFor(self.ConstructionArmAnimManip)
        else
            WaitSeconds(2)
        end

        -- see if there's more to build
        self:MaybeStartConstruction()
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