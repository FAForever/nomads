-- The surface support vehicle that's in orbit

local NCivilianStructureUnit = import('/lua/nomadsunits.lua').NCivilianStructureUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local CreateNomadsBuildSliceBeams = import('/lua/nomadseffectutilities.lua').CreateNomadsBuildSliceBeams

xnc0001 = Class(NCivilianStructureUnit) {

    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()

        NCivilianStructureUnit.OnCreate(self)

        self:SetupRotators()
        
        -- ForkThread(function()
            -- WaitSeconds(2)
            -- self:Landing()
            -- WaitSeconds(12)
            -- self:TakeOff()
        -- end)
    end,
    
    --rotators
    
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

    --engines
    
    EngineBurnBones = {'Engine Exhaust01', 'Engine Exhaust02', 'Engine Exhaust03', 'Engine Exhaust04', 'Engine Exhaust05', },
    --ThrusterBurnBones = {'ThrusterFrontLeft', 'ThrusterFrontRight', 'ThrusterBackLeft', 'ThrusterBackRight'},
    ThrusterBurnBones = {0}, --why is this here?
    ThrusterFireEffects = { --for when the engine is on full power
            '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',--smoke
            '/effects/emitters/nomads_orbital_frigate_thruster05_emit.bp',--smoke
            '/effects/emitters/nomads_orbital_frigate_thruster01_emit.bp',--fire
            '/effects/emitters/nomads_orbital_frigate_thruster02_emit.bp',--fire
        },
    ThrusterPartialEffects = { --hot air effects only
            --'/effects/emitters/nomads_orbital_frigate_thruster03_emit.bp', --this one looks dumb
            '/effects/emitters/nomads_orbital_frigate_thruster04_emit.bp',
        },

    BurnEngines = function(self)
        self:AddEffects(self.ThrusterFireEffects, self.EngineBurnBones, self.ThrusterEffectsBag, 0.3)
    end,

    StopEngines = function(self)
        self.ThrusterEffectsBag:Destroy()
        self:AddEffects(self.ThrusterPartialEffects, self.EngineBurnBones, self.ThrusterEffectsBag)
        WaitSeconds(6)
        self.ThrusterEffectsBag:Destroy()
    end,

    TakeOff = function (self)
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/xno0001/xno0001_launch.sca')
        self.LaunchAnim:SetAnimationFraction(0)
        self.LaunchAnim:SetRate(0.1)
        self.Trash:Add(self.LaunchAnim)
        ForkThread(function()
            WaitSeconds(0.3)
            self:BurnEngines()
        end)
    end,

    Landing = function (self)
        self:AddEffects(self.ThrusterFireEffects, self.EngineBurnBones, self.ThrusterEffectsBag)
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/xno0001/xno0001_land.sca')
        self.LaunchAnim:SetAnimationFraction(0.3)
        self.LaunchAnim:SetRate(0.1)
        self.Trash:Add(self.LaunchAnim)
        
        ForkThread(function()
            WaitSeconds(5.3)
            self:StopEngines()
        end)
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
}

TypeClass = xnc0001