-- T1 tank destroyer

local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local AddAnchorAbilty = import('/lua/nomadutils.lua').AddAnchorAbilty
local NLandUnit = import('/lua/nomadunits.lua').NLandUnit
local KineticCannon1 = import('/lua/nomadweapons.lua').KineticCannon1

NLandUnit = AddAnchorAbilty(NLandUnit)

INU1008 = Class(NLandUnit) {
    Weapons = {
        MainGun = Class(KineticCannon1) {
            OnWeaponFired = function(self)
                KineticCannon1.OnWeaponFired(self)
                self.unit:PlayWeaponFiredEffects()
            end,

            SetMovingAccuracy = function(self, bool)
                local bp = self:GetBlueprint()
                if bool then
                    --LOG('Setting accuracy to moving')
                    self:SetFiringRandomness( bp.FiringRandomnessWhileMoving or (math.max(0, bp.FiringRandomness) * 4) )
                    self:ChangeFiringTolerance( bp.FiringToleranceWhileMoving or (math.max(0, bp.FiringTolerance) * 5) )
                else
                    --LOG('Setting accuracy to stopped')
                    self:SetFiringRandomness( bp.FiringRandomness )
                    self:ChangeFiringTolerance( bp.FiringTolerance )
                end
            end,
        },
    },

    ExhaustAnimDelay = 1,

    OnCreate = function(self)
        NLandUnit.OnCreate(self)
        self.WeaponFiredEffectsBag = TrashBag()
        local bp = self:GetBlueprint()
        if bp.Display.WeaponExhaustAnimation then
            self.AnimManip = CreateAnimator(self):PlayAnim(bp.Display.WeaponExhaustAnimation):SetRate(0)
            self.Trash:Add(self.AnimManip)
            local rof = self:GetWeaponByLabel('MainGun'):GetBlueprint().RateOfFire or 1
            self.ExhaustAnimDelay = math.min( self.ExhaustAnimDelay, (0.8 / rof) )  -- making sure the exhausting happens before next shot (at least 80% before)
        end
    end,

    OnDestroy = function(self)
        self:DestroyWeaponFiredEffects()
        NLandUnit.OnDestroy(self)
    end,

    OnMotionHorzEventChange = function( self, new, old )
        -- the engine already supports BP values ...WhileMoving but it does this when the unit is "Stopped". We want it when
        -- the unit is "Stopping" to make the first shot of the unit count already (the first shot happens before "Stopped").
        --LOG('*DEBUG: OnMotionHorzEventChange new = '..repr(new)..' old = '..repr(old))
        NLandUnit.OnMotionHorzEventChange( self, new, old )
        self:UpdateWeaponAccuracy( (new ~= 'Stopped' and new ~= 'Stopping') )
    end,

    UpdateWeaponAccuracy = function(self, moving)
        if not self:IsDead() then
            self:GetWeapon(1):SetMovingAccuracy(moving)
        end
    end,

    EnableSpecialToggle = function(self)
        self:EnableAnchor(self)
    end,

    DisableSpecialToggle = function(self)
        self:DisableAnchor(self)
    end,

    PlayWeaponFiredEffects = function(self)
        if self.AnimManip then
            local fn = function(self)
                WaitSeconds( self.ExhaustAnimDelay or 1 )
                local army, emit = self:GetArmy()
                for k, v in NomadEffectTemplate.TankBusterWeaponFired do
                    emit = CreateEmitterAtBone(self, 'turret_ExhaustFX', army, v)
                    self.WeaponFiredEffectsBag:Add(emit)
                    self.Trash:Add(emit)
                end
                self.AnimManip:SetRate(1)
                WaitFor(self.AnimManip)
                self.AnimManip:SetRate(0):SetAnimationFraction(0)
            end
            self.WeaponFiredEffectsBag:Add( self:ForkThread(fn) )
        end
    end,

    DestroyWeaponFiredEffects = function(self)
        self.WeaponFiredEffectsBag:Destroy()
    end,
}

TypeClass = INU1008