-- The surface support vehicle that's in orbit

local NOrbitUnit = import('/lua/nomadunits.lua').NOrbitUnit
local OrbitalMissileWeapon = import('/lua/nomadweapons.lua').OrbitalMissileWeapon
local CreateNomadBuildSliceBeams = import('/lua/nomadeffectutilities.lua').CreateNomadBuildSliceBeams

INO0001 = Class(NOrbitUnit) {
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

    OnPreCreate = function(self)
        --yes i know this is disgusting but it has to be done since the nomad orbital ship crashes the game
        --so it needs an exception FIXME: refactor nomads orbital frigate so its not so crazy.
        
        self.ColourIndex = 5 --default nomads colour apparently. This makes it not call the DetermineColourIndex later on.
        
        NOrbitUnit.OnPreCreate(self)
    end,
    
    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        NOrbitUnit.OnCreate(self)

        self:CreateSpinners()
		
        local bp = self:GetBlueprint()
        if bp.Display.AnimationBuildArm then
            self.ConstructionArmAnimManip = CreateAnimator( self ):PlayAnim( bp.Display.AnimationBuildArm ):SetRate(0)
        end

        self.OrbitalStrikeCurWepTarget = {}
        self.OrbitalStrikeDbKey = {}
    end,

    CreateSpinners = function(self)
        -- spinner 1
        if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'Primary_Spinner', 'z' )
            self.RotatorManipulator1:SetAccel( 5 )
            self.RotatorManipulator1:SetTargetSpeed( 30 )
            self.Trash:Add( self.RotatorManipulator1 )
        end

        -- spinner 2
        if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'Secondary_Spinner', 'z' )
            self.RotatorManipulator2:SetAccel( -5 )
            self.RotatorManipulator2:SetTargetSpeed( -60 )
            self.Trash:Add( self.RotatorManipulator2 )
        end
    end,

-- =========================================================================================
-- Probes

    LaunchProbe = function(self, location, projBp, data)
        if not location or not projBp or not data then
            WARN('*DEBUG: LaunchProbe missing information. Location = '..repr(location)..' projBp = '..repr(projBp)..' data = '..repr(data))
            return nil
        end

        local bone = 'turret_muzzle02'
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
                --LOG('Mothership weapon '..repr(w)..' is firing')
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
                WARN('INO0001: AddToConstructionQueue(): Passed callback is not a function! Ignoring it.')
                cb = nil
            end
            table.insert( self.BuildQueue, { unitType = unitType, cb = cb, attachBone = attachBone, } )
            self:MaybeStartConstruction()
            return true
        else
            WARN('INO0001: AddToConstructionQueue(): Passed unit type is not a string.')
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
        local effectThread = ForkThread( CreateNomadBuildSliceBeams, self, unit, self.BuildBones, self.BuildEffectsBag )

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
}

TypeClass = INO0001