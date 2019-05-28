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
        if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'Spinner1', 'z' )
            self.RotatorManipulator1:SetAccel( bp.PrimaryAccel )
            self.RotatorManipulator1:SetTargetSpeed( bp.PrimarySpeed )
            self.Trash:Add( self.RotatorManipulator1 )
        end
        if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'Spinner2', 'z' )
            self.RotatorManipulator2:SetAccel( bp.SecondaryAccel )
            self.RotatorManipulator2:SetTargetSpeed( bp.SecondarySpeed )
            self.Trash:Add( self.RotatorManipulator2 )
        end
        if not self.RotatorManipulator3 then
            self.RotatorManipulator3 = CreateRotator( self, 'Spinner3', 'z' )
            self.RotatorManipulator3:SetAccel( bp.PrimaryAccel )
            self.RotatorManipulator3:SetTargetSpeed( bp.PrimarySpeed )
            self.Trash:Add( self.RotatorManipulator3 )
        end
    end,

    StopRotators = function(self)
        if self.RotatorManipulator1 then
            self.RotatorManipulator1:SetTargetSpeed( 0 )
        end
        if self.RotatorManipulator2 then
            self.RotatorManipulator2:SetTargetSpeed( 0 )
        end
        if self.RotatorManipulator3 then
            self.RotatorManipulator3:SetTargetSpeed( 0 )
        end        
    end,
    
    StartRotators = function(self)
        local bp = self:GetBlueprint().Rotators
        if self.RotatorManipulator1 then
            self.RotatorManipulator1:SetTargetSpeed( bp.PrimarySpeed )
        end
        if self.RotatorManipulator2 then
            self.RotatorManipulator2:SetTargetSpeed( bp.SecondarySpeed )
        end
        if self.RotatorManipulator3 then
            self.RotatorManipulator3:SetTargetSpeed( bp.PrimarySpeed )
        end
    end,

    --engines
    
    EngineBurnBones = {'ExhaustBig', 'ExhaustSmallRight', 'ExhaustSmallLeft', 'ExhaustSmallTop'},
    ThrusterBurnBones = {'ThrusterFrontLeft', 'ThrusterFrontRight', 'ThrusterBackLeft', 'ThrusterBackRight'},
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