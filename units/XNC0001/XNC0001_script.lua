-- The surface support vehicle that's in orbit

local NCivilianStructureUnit = import('/lua/nomadsunits.lua').NCivilianStructureUnit
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')

xnc0001 = Class(NCivilianStructureUnit) {

    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        self.EngineEffectsBag = TrashBag()
        self.ThrusterEffectsBag = TrashBag()
        NCivilianStructureUnit.OnCreate(self)
        self:Landing(true) --landing animation
    end,
    
    --rotators
    
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

    --engines
    
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

    StartEngines = function(self)
        self:AddEffects(self.EngineFireEffects, self.EngineExhaustBones, self.EngineEffectsBag, 0.3)
    end,

    StopEngines = function(self)
        self.EngineEffectsBag:Destroy()
        self:AddEffects(self.EnginePartialEffects, self.EngineExhaustBones, self.EngineEffectsBag)
        WaitSeconds(4.5)
        self.EngineEffectsBag:Destroy()
    end,

    TakeOff = function (self)
        self.LaunchAnim = CreateAnimator(self):PlayAnim('/units/xno0001/xno0001_launch.sca')
        self.LaunchAnim:SetAnimationFraction(0)
        self.LaunchAnim:SetRate(0.1)
        self.Trash:Add(self.LaunchAnim)
        ForkThread(function()
            WaitSeconds(0.3)
            self:StartEngines()
        end)
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
}

TypeClass = xnc0001