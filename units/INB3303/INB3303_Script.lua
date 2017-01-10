-- T3 rocket artillery

local Entity = import('/lua/sim/Entity.lua').Entity
local SupportedArtilleryWeapon = import('/lua/nomadutils.lua').SupportedArtilleryWeapon
local NStructureUnit = import('/lua/nomadunits.lua').NStructureUnit
local TacticalMissileWeapon1 = import('/lua/nomadweapons.lua').TacticalMissileWeapon1

TacticalMissileWeapon1 = SupportedArtilleryWeapon( TacticalMissileWeapon1 )

INB3303 = Class(NStructureUnit) {
    Weapons = {
        MainGun = Class(TacticalMissileWeapon1) {

            -- the keys in the table below should match the MuzzleBones in the weapon blueprint.
            MissileBones = { MissileC4 = { 'MissileC1', 'MissileC2', 'MissileC3', 'MissileC4', },
                             MissileC8 = { 'MissileC5', 'MissileC6', 'MissileC7', 'MissileC8', }, },
            NumMissiles = 8,

            OnCreate = function(self)
                TacticalMissileWeapon1.OnCreate(self)

                -- TODO: if 8 is final, remove this
                self.NumMissiles = 0
                for k, bones in self.MissileBones do
                    self.NumMissiles = self.NumMissiles + table.getsize(bones)
                end
                self.OrgFR = self:GetFiringRandomness()
            end,

            CreateProjectileAtMuzzle = function(self, muzzle)
                -- since we're launching multiple missiles at the same time it doesn't make sense to do checks for supported artillery
                -- weap. So I'm avoiding that by manually making the weapon supported for the last 2 missiles if we are supported with
                -- the first missile.

                self.Supported = false
                local firstBone, secondSalvo = true, false

                for k, bones in self.MissileBones do

                    if k == muzzle then

                        -- create first missile at muzzle, then see if we're supported. If yes, set supporting for the remaining missiles.
                        for k, bone in bones do
                            TacticalMissileWeapon1.CreateProjectileAtMuzzle(self, bone)
                            if firstBone and not secondSalvo and self.Supported then
                                self.ArtillerySupportEnabled = false    -- prevents checking for supporting units
                                self.OrgFR = self:MakeSupported()
                            end
                            firstBone = false
                            self.unit:DoShowMissile(bone, false) -- hide missile on model
                        end

                        if not secondSalvo then
                            self.unit:ForkThread( self.unit.DoRotateAnim )
                        else
                            self.unit:ForkThread( self.unit.DoReloadAnim )
                        end

                        return
                    end

                    secondSalvo = true
                end

                LOG('*DEBUG: INB3303 MissileBones set in script do not match MuzzleBones in weapon BP')
            end,

            MakeSupported = function(self)
                self.Supported = true  -- flag that we're supported
                return TacticalMissileWeapon1.MakeSupported(self)
            end,

            OnWeaponFired = function(self)
                if self.Supported then
                    self:MakeUnsupported( self.OrgFR )
                    self.ArtillerySupportEnabled = true
                end
                TacticalMissileWeapon1.OnWeaponFired(self)
            end,

            ChangeRateOfFire = function(self, newROF)
                TacticalMissileWeapon1.ChangeRateOfFire(self, newROF)
                self._CurROF = newROF
            end,

            GetRateOfFire = function(self)
                return self._CurROF or self:GetBlueprint().RateOfFire or 1
            end,
        },
    },

    ElevatorRate = 2,
    ReloadWaitTime = 0.5,
    RotatePreDelay = 0.5,

    OnCreate = function(self)
        NStructureUnit.OnCreate(self)

        local wep = self:GetWeaponByLabel('MainGun')
        local bpw = wep:GetBlueprint()
        local bpp = wep:GetProjectileBlueprint()

        -- create the missiles in the racks
        local meshBp = bpp.Display.Mesh.BlueprintId or string.sub( bpw.ProjectileId, 1, string.len( bpw.ProjectileId )-8)  .. '_mesh'
        local meshScale = bpp.Display.UniformScale or 1
        self.MissilesOnRack = {}   -- fixes a nasty bug where units share the same missile entities.
        local pos = self:GetPosition()
        for i=1, wep.NumMissiles do
            local bone = 'MissileC'..tostring(i)
--            if i > (wep.NumMissiles/2) then bone = bone .. 'R' end
            local missile = Entity()
            missile:SetPosition( Vector(pos[1], pos[2]-20, pos[3]), true )
            missile:SetMesh( meshBp, false )
            missile:SetDrawScale( meshScale )
            self.MissilesOnRack[ bone ] = missile
            self.Trash:Add( missile )
--            LOG('bone = '..repr(bone))
        end

        -- create animation manipulators
        self.ElevatorManip = CreateAnimator(self):PlayAnim('/units/INB3303/INB3303_Elevator.sca' ):SetRate(1 * self.ElevatorRate)
        self.ElevatorManip:SetPrecedence(2):SetRate(0):SetAnimationFraction(1)
        self.Trash:Add(self.ElevatorManip)
        self.RotateManip = CreateRotator(self, 'MissileRack', 'x'):SetSpeed( bpw.TurretPitchSpeed ):SetPrecedence(30)
        self.Trash:Add(self.RotateManip)

        self:CalcReloadAnimParams()
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        NStructureUnit.OnStopBeingBuilt(self,builder,layer)
        local bp = self:GetBlueprint()
        if bp.Audio.Activate then
            self:PlaySound(bp.Audio.Activate)
        end

        self:SetWeaponEnabledByLabel('MainGun', false)
        local fn = function(self)
            self:DoReloadAnim()
            self:SetWeaponEnabledByLabel('MainGun', true)
        end
        self:ForkThread( fn )
    end,

    OnAfterBeingBuffed = function( self, buffName, instigator, AOEtarget, beforeData )
        self:CalcReloadAnimParams()
    end,

    DoShowMissile = function(self, AtBone, show)
        -- hide and show bone would be nice here but the missile entity doesn't have these functions. So instead I'm just putting them
        -- under the surface.
--        LOG('AtBone = '..repr(AtBone))
        local missile = self.MissilesOnRack[ AtBone ]
        if show then
            missile:AttachBoneTo( -1, self, AtBone )
        else
            local pos = self:GetPosition()
            missile:DetachFrom()
            missile:SetPosition( Vector(pos[1], pos[2]-20, pos[3]), true )
        end
    end,

    DoRotateAnim = function(self)
        -- rotate rack
        if self.RotatePreDelay > 0 then
            WaitSeconds( self.RotatePreDelay )
        end
        self.RotateManip:SetGoal( 0 )
        WaitFor( self.RotateManip )
    end,

    DoReloadAnim = function(self)

-- note: sometimes when the model is exported from blender the missile bones are reversed and the unit is firing into the ground
-- instead of in the air. To fix this change add 180 degrees in the rotation everywhere, or decrease 180 degrees.

-- TODO: just before going down the rack is rotated for 270 degrees instead of 90. Fix it so the rack only rotates 90 degreed each reload cycle.
--       this will mean the rack will have to be flipped every reload cycle.

        local wep = self:GetWeaponByLabel('MainGun')
        local hnm = wep.NumMissiles / 2

        if self.RotatePreDelay > 0 then
            WaitSeconds( self.RotatePreDelay )
        end

        local yaw, pitch = wep.AimControl:GetHeadingPitch()
        local angle = pitch * (180 / math.pi)

        -- rotate missile rack so that it's horizontal
        self.RotateManip:SetCurrentAngle( 0 ):SetGoal( angle )
        WaitFor(self.RotateManip)

        -- lower missile rack
        self.ElevatorManip:SetRate( -1 * self.ElevatorRate )
        WaitFor( self.ElevatorManip )

        -- put the missiles in the racks and wait a while
        for i=1, hnm do
            self:DoShowMissile('MissileC'..tostring(i), true)
        end
        if self.ReloadWaitTime > 0 then
            WaitSeconds(self.ReloadWaitTime)
        end

        -- raise missile rack
        self.ElevatorManip:SetRate( 1 * self.ElevatorRate )
        WaitFor( self.ElevatorManip )

        -- rotate rack    - first to + 90 degrees to make the unit always rotate in the same direction. Without this the rack rotates...
        self.RotateManip:SetGoal( angle + 90 )          -- ... 180 degrees, either forward or backward. Now it's always forward.
        WaitFor( self.RotateManip )
        self.RotateManip:SetGoal( angle + 180 )
        WaitFor( self.RotateManip )

        -- lower missile rack
        self.ElevatorManip:SetRate( -1 * self.ElevatorRate )
        WaitFor( self.ElevatorManip )

        -- put the missiles in the racks and wait a while
        for i=hnm+1, wep.NumMissiles do
            self:DoShowMissile('MissileC'..tostring(i), true)
        end
        if self.ReloadWaitTime > 0 then
            WaitSeconds(self.ReloadWaitTime)
        end

        -- raise missile rack
        self.ElevatorManip:SetRate( 1 * self.ElevatorRate )
        WaitFor( self.ElevatorManip )

        -- return to original position
        self.RotateManip:SetGoal( 180 )
    end,

    CalcReloadAnimParams = function(self)

        local wep = self:GetWeaponByLabel('MainGun')
        local bpw = wep:GetBlueprint()
        local RateOfFire = wep:GetRateOfFire()

        -- rotation speed checking and animation calculations
        local PitchSpeed = bpw.TurretPitchSpeed
        local MuzzleDelay = bpw.MuzzleSalvoDelay
        if MuzzleDelay > 0 then
            local FreeTime = MuzzleDelay - (math.ceil(10 * 180 / PitchSpeed) / 10)
            if FreeTime > 0 then
                self.RotatePreDelay = FreeTime * 0.75    -- by not using up all free time there is a short delay after the rotation aswell
            elseif FreeTime < 0 then
                WARN('INB3303: MuzzleDelay defined in blueprint is to short or the pitch speed is to slow')
            end
        end
        local Interval = math.ceil( 10 / RateOfFire ) / 10
        local SalvoTime = math.ceil( 10 * MuzzleDelay * (bpw.MuzzleSalvoSize - 1) ) / 10
        local ElevatorTime = math.ceil( (10 * 1.6 * 4) / self.ElevatorRate ) / 10   -- the anim plays 4 times, it takes max 1.6 seconds each time
        local RotatorTime = math.ceil( (10 * 180) / PitchSpeed ) / 10
        local GoHorzTime = math.ceil( (10 * self.RotatePreDelay) + (10 * (90 / PitchSpeed) * 3)) / 10 -- time for getting the rack from vertical to horizontal. the rack is max 90 degrees rotated. times three cause we rotate it three times in the reload anim
        self.ReloadWaitTime = math.floor( 10 * (Interval - SalvoTime - ElevatorTime - RotatorTime - GoHorzTime) / 2) / 10

        if self.ReloadWaitTime <= 0 then
            WARN('INB3303: need more time for the reload animation, decrease the rate of fire.')
            WARN('INB3303: Interval = '..repr(Interval)..' SalvoTime = '..repr(SalvoTime)..' ElevatorTime = '..repr(ElevatorTime))
            WARN('INB3303: RotatorTime = '..repr(RotatorTime)..' GoHorzTime = '..repr(GoHorzTime)..' ReloadWaitTime = '..repr(self.ReloadWaitTime))
        end
        if math.ceil( bpw.EnergyRequired / bpw.EnergyDrainPerSecond ) > Interval then
            WARN('INB3303: Energy consumption prevents reaching the ROF. Energy: '..repr(math.ceil( bpw.EnergyRequired / bpw.EnergyDrainPerSecond ))..' seconds, ROF '..repr(Interval)..' seconds.')
        end

        -- bug in the engine: the weapon bar that fills up after each shot to show it's readyness doesn't go to 100% with the ROF bonus, the unit fires
        -- before the bar is filled.
    end,
}

TypeClass = INB3303