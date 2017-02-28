-- The surface support vehicle that's in orbit

local NCivilianStructureUnit = import('/lua/nomadsunits.lua').NCivilianStructureUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local CreateNomadsBuildSliceBeams = import('/lua/nomadseffectutilities.lua').CreateNomadsBuildSliceBeams

INC0001 = Class(NCivilianStructureUnit) {
    
    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()
        
        NCivilianStructureUnit.OnCreate(self)
        
        if self:GetBlueprint().Physics.Elevation then
            self:Hover()
        end
        if self:GetBlueprint().Rotators.Stationary then
            self:StationaryAngle()
        else
            self:RotatingAngle()
        end
        
        self:TakeOff()
        
       -- self:Landing()
        --self:BurnEngines()
        
        --[[for _, army in ListArmies() do
            if not IsEnemy(army, self:GetArmy()) then
                self:AddToConstructionQueue('inu1001', army)
            end
        end]]
    end,
    
    Hover = function(self)
        local pos = self:GetPosition()
        local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
        local elevation = self:GetBlueprint().Physics.Elevation
        pos[2] = surface + elevation
        self:SetPosition( pos, true)
    end,
    
    RotatingAngle = function(self)
        -- spinner 1
        if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'Primary_Spinner', 'z' )
            self.RotatorManipulator1:SetAccel( self:GetBlueprint().Rotators.PrimaryAccel ) 
            self.RotatorManipulator1:SetTargetSpeed( self:GetBlueprint().Rotators.PrimarySpeed ) 
            self.Trash:Add( self.RotatorManipulator1 )
        end

        -- spinner 2
        if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'Secondary_Spinner', 'z' )
            self.RotatorManipulator2:SetAccel( self:GetBlueprint().Rotators.SecondaryAccel ) 
            self.RotatorManipulator2:SetTargetSpeed( self:GetBlueprint().Rotators.SecondarySpeed ) 
            self.Trash:Add( self.RotatorManipulator2 )
        end
        
    end,
    
    StationaryAngle = function(self)
        -- spinner 1
        if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'Primary_Spinner', 'z' )
            self.RotatorManipulator1:SetCurrentAngle( self:GetBlueprint().Rotators.PrimaryAngle )
            self.Trash:Add( self.RotatorManipulator1 )
        end

        -- spinner 2
        if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'Secondary_Spinner', 'z' )
            self.RotatorManipulator2:SetCurrentAngle( self:GetBlueprint().Rotators.SecondaryAngle )
            self.Trash:Add( self.RotatorManipulator2 )
        end
    end,
    
    
    
    ThrusterBurnBones = {'Exhaust_Centre', 'Exhaust_Top', 'Exhaust_Bottom'},
    
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
                    WaitSeconds(0.3)
                end
                WaitSeconds(2)
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
                    WaitSeconds(0.2)
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
    
    TakeOff = function (self)
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/INO0001/INO0001_Launch.sca')
        self.LaunchAnim:SetAnimationFraction(1)
        self.LaunchAnim:SetRate(-0.05)
        self.Trash:Add(self.LaunchAnim)
        ForkThread(
            function()
                WaitSeconds(1.4)
                self:BurnEngines()
            end
        )
    end,
    
    Landing = function (self)
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/INO0001/INO0001_Launch.sca')
        self.LaunchAnim:SetAnimationFraction(0)
        self.LaunchAnim:SetRate(0.05)
        self.Trash:Add(self.LaunchAnim)
    end,    
    
    
    
    BuildQueue = {
    --   { unitType = 'xxx', },
    },
    ConstructingThreadHandle = nil,
    BuildBones ={0},
    AddToConstructionQueue = function(self, unitType , army)
        if unitType and type(unitType) == 'string' then
            table.insert( self.BuildQueue, { unitType = unitType, army = army} )
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
        if table.getn( self.BuildQueue ) > 0 then
            local keys = table.keys( self.BuildQueue )
            local queueKey = keys[1]
            self.ConstructingThreadHandle = self:ForkThread( self.StartConstruction, queueKey)
            self.Trash:Add( self.ConstructingThreadHandle )
        end
    end,
    

    StartConstruction = function( self, queueKey)
        local attachBone = 0
        local unitBp = self.BuildQueue[ queueKey ].unitType
        local army = self.BuildQueue[ queueKey ].army
        table.remove( self.BuildQueue, queueKey )

        if self.ConstructionArmAnimManip then
            self.ConstructionArmAnimManip:SetRate(1)
            WaitFor( self.ConstructionArmAnimManip )
        end

        local x, y, z =  unpack(self:GetPosition( attachBone ))
        local unit = CreateUnitHPR( unitBp, army, x + 5+ Random(3), y, z+ Random(3), 0, 0, 0 )

        self.UnitBeingBuilt = unit
        unit:SetIsValidTarget(false)
        unit:SetImmobile(true)

        -- build effects
        if unit:GetBlueprint().Display.BuildMeshBlueprint then
            unit:SetMesh(unit:GetBlueprint().Display.BuildMeshBlueprint, true)
        end
        local layer = self:GetCurrentLayer()
        unit:StartBeingBuiltEffects( self, layer)
        local effectThread = ForkThread( CreateNomadsBuildSliceBeams, self, unit, self.BuildBones, self.BuildEffectsBag )

        WaitTicks(math.ceil( unit:GetBlueprint().Economy.BuildTime or 10000 ) / 10)

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
    end,
}

TypeClass = INC0001