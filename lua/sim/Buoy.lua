local Entity = import('/lua/sim/Entity.lua').Entity

Buoy = Class(Entity) {

    ActiveFx = {},
    DestroyedFx = {},
    LightsFx = {},

    OnCreate = function(self, spec)

    # Unfortunately I can't use spec.Army here. The underlying mechanics use this to determine whether this entity should be damaged by a
    # projectile, based on this info (and on the damagefriendly flag in unit blueprints).
    # Since I want / need this entity destroyed by all weapon fire (especially the orbital missiles) I have to not use self.spec.Army. Instead
    # I'm passing the army in self.spec.RealArmy. The script creating this entity needs to be aware of that.

        # checking spec table
        if (not spec.Army and not spec.RealArmy) or not spec.Pos then
            if not spec.Army and not spec.RealArmy then WARN('Buoy: No army defined') end
            if not spec.Pos then WARN('Buoy: No position defined') end
            self:Destroy()
            return
        end

        self.Destroyed = false
        self.Trash = TrashBag()
        self.ActiveFxBag = TrashBag()
        self.CanTakeDamage = true
        self.CanBeKilled = true
        self.spec = spec
        Entity.OnCreate( self, spec )

# TODO: fix buoy strategic icons (if possible)
#        if self.spec.StrategicIconName then
#            self:SetStrategicUnderlay( self.spec.StrategicIconName )
#        end

        self.Health = self.spec.Health or 10
        if self.spec.ActiveFx then self.ActiveFx = self.spec.ActiveFx end
        if self.spec.DestroyedFx then self.DestroyedFx = self.spec.DestroyedFx end
        if self.spec.LightsFx then self.LightsFx = self.spec.LightsFx end

        # move to location and perhaps attach to a unit
        Warp( self, spec.Pos )
        if spec.AttachTo then
            self:AttachToUnit( spec.AttachTo )
        end

        self:PlayLightsFx()
        self:SetBuoyCollision('Sphere', 0, 0, 0, nil, nil, nil, 0.5)

        if spec.Activated then
            self:ActivateBuoy()
        end
    end,

    OnKilled = function(self, instigator, damageType, overkill)
        self:DeactivateBuoy()
        self:DestroyActiveFx()
        self:PlayBuoyDestroyedFx()
        self:Destroy()
    end,

    OnDestroy = function(self)
        self:DeactivateBuoy()
        self.Trash:Destroy()
        Entity.OnDestroy(self)
        self.Destroyed = true
    end,

    # ----------------------------------------------------------------------------------------
    # Visuals

    PlayLightsFx = function(self)
        # permanent lights on the buoy
        local army = self:GetArmy()
        for k, v in self.LightsFx do
            local emit = CreateAttachedEmitter( self, -1, army, v )
            self.Trash:Add( emit )
        end
    end,

    PlayActiveFx = function(self)
        # plays 'active' effects
        local army = self:GetArmy()
        for k, v in self.ActiveFx do
            local emit = CreateAttachedEmitter( self, -1, army, v )
            self.ActiveFxBag:Add( emit )
            self.Trash:Add( emit )
        end
    end,

    DestroyActiveFx = function(self)
        # destroys the 'active' effects
        self.ActiveFxBag:Destroy()
    end,

    PlayBuoyDestroyedFx = function(self)
        local army = self:GetArmy()
        for k, v in self.DestroyedFx do
            CreateAttachedEmitter( self, -1, army, v )
        end
    end,

    # ----------------------------------------------------------------------------------------
    # mechanics

    ActivateBuoy = function(self)
        self:PlayActiveFx()
        self:ForkThread( self.ActiveThread )
        if self.spec.Lifetime and self.spec.Lifetime > 0 then
            self:ForkThread( self.LifetimeThread, self.spec.Lifetime )
        end
    end,

    ActiveThread = function(self)
    end,

    DeactivateBuoy = function(self)
        self:DestroyActiveFx()
    end,

    LifetimeThread = function(self, lifetime)
        WaitSeconds( lifetime )
        self:DeactivateBuoy()
        self:Kill()
    end,

    AttachToUnit = function(self, unit)
        local bone = self:FindBestAttachBone(unit)
        self:AttachTo( unit, bone )
    end,

    FindBestAttachBone = function(self, unit)
        local bone = 0
        if unit and IsUnit(unit) then
            local count, pos, dist, d = unit:GetBoneCount(), self:GetPosition(), 0, 99999
            for i = 1, count do
                if unit:IsValidBone(i) then
                    dist = VDist3( pos, unit:GetPosition(i) )
                    if dist < d then
                        bone = i
                        d = dist
                    end
                end
            end
        end
        return bone
    end,

    # ----------------------------------------------------------------------------------------
    # Misc stuff

    GetArmy = function(self)
        return self.spec.RealArmy or self.spec.Army
    end,

    GetBrain = function(self)
        return GetArmyBrain(self:GetArmy())
    end,

    GetPosition = function(self)
        return self.spec.Pos
    end,

    SetCanTakeDamage = function(self, val)
        self.CanTakeDamage = val
    end,
    
    SetCanBeKilled = function(self, val)
        self.CanBeKilled = val
    end,

    CheckCanBeKilled = function(self, other)
        return self.CanBeKilled
    end,

    OnDamage = function(self, instigator, amount, direction, damageType)
        if self.CanTakeDamage and self.CanBeKilled then
            self:DoTakeDamage(instigator, amount, direction, damageType)
        end
    end,

    DoTakeDamage = function(self, instigator, amount, direction, damageType)
        self.Health = self.Health - amount
        if self.Health < 1 then
            self:Kill(instigator, damageType, amount)
        end
    end,

    Kill = function(self, instigator, damageType, overkill)
        Entity.Kill(self, instigator or nil, damageType or '', overkill or 0)
        self:OnKilled(instigator, damageType, overkill)
    end,

    OnCollisionCheck = function(self, other)
        if IsUnit(other) or self.CanTakeDamage == false then
            return false
        else
            return true
        end
    end,

    SetBuoyCollision = function(self, shape, centerx, centery, centerz, sizex, sizey, sizez, radius)
        self.CollisionRadius = radius
        self.CollisionSizeX = sizex
        self.CollisionSizeY = sizey
        self.CollisionSizeZ = sizez
        self.CollisionCenterX = centerx
        self.CollisionCenterY = centery
        self.CollisionCenterZ = centerz
        self.CollisionShape = shape
        if radius and shape == 'Sphere' then
            self:SetCollisionShape(shape, centerx, centery, centerz, radius)
        else
            self:SetCollisionShape(shape, centerx, centery, centerz, sizex, sizey, sizez)
        end
    end,

    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,

    BeenDestroyed = function(self)
        return self.Destroyed
    end,
}