-- T1 tank destroyer

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local NLandUnit = import('/lua/nomadsunits.lua').NLandUnit
local KineticCannon1 = import('/lua/nomadsweapons.lua').KineticCannon1

XNL0107 = Class(NLandUnit) {
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

    ExhaustAnimDelay = 0.2,

    OnCreate = function(self)
        NLandUnit.OnCreate(self)
        self.WeaponFiredEffectsBag = TrashBag()
    end,

    OnDestroy = function(self)
        self.WeaponFiredEffectsBag:Destroy()
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
        if not self.Dead then
            self:GetWeapon(1):SetMovingAccuracy(moving)
        end
    end,

    PlayWeaponFiredEffects = function(self)
        local fn = function(self)
            WaitSeconds( self.ExhaustAnimDelay or 1 )
            local army, emit = self:GetArmy()
            for k, v in NomadsEffectTemplate.TankBusterWeaponFired do
                emit = CreateEmitterAtBone(self, 'Exhaust', army, v)
                self.WeaponFiredEffectsBag:Add(emit)
                self.Trash:Add(emit)
            end
        end
        self.WeaponFiredEffectsBag:Add( self:ForkThread(fn) )
    end,
}

TypeClass = XNL0107