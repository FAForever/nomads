local Util = import('/lua/utilities.lua')
local RandomFloat = Util.GetRandomFloat
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell


MeteorRain = Class(NullShell) {

    AvgMeteorsPerMin = 20,
    AvgScale = 0.2,
    MaxDmgPerMeteor = 15000,
    MinDmgPerMeteor = 5000,
    MapRect = {x1=0,z1=0,x2=0,z2=0},

    OnCreate = function(self)
        NullShell.OnCreate(self)

        self:SetCollideSurface(false)
        self:SetCollideEntity(false)
        self:SetCollision(false)
    end,

    SetParams = function(self, MapRectX1, MapRectZ1, MapRectX2, MapRectZ2, AvgMeteorsPerMin, MinDmgPerMeteor, MaxDmgPerMeteor, AvgScale)
        self.MapRect = { x1=MapRectX1, z1=MapRectZ1, x2=MapRectX2, z2=MapRectZ2, }
        self.AvgMeteorsPerMin = AvgMeteorsPerMin
        self.AvgScale = AvgScale
        self.MaxDmgPerMeteor = MaxDmgPerMeteor
        self.MinDmgPerMeteor = MinDmgPerMeteor
    end,

    Start = function(self)
        self:Stop()
        self.RainThreadHandle = self:ForkThread(self.RainThread)
    end,

    Stop = function(self)
        if self:IsActive() then
            KillThread(self.RainThreadHandle)
            self.RainThreadHandle = nil
        end
    end,

    IsActive = function(self)
        if self.RainThreadHandle then
            return true
        end
        return false
    end,

    OnDamage = function(self, instigator, amount, vector, damageType)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
    end,

    RainThread = function(self)
        local IntervalMin = 60 / self.AvgMeteorsPerMin * 0.25
        local IntervalMax = 60 / self.AvgMeteorsPerMin * 1.75
        local ScaleMin = self.AvgScale * 0.5
        local ScaleMax = self.AvgScale * 1.5

        local s,x,y,z, meteor
        while self:IsActive() do
            s = RandomFloat(ScaleMin, ScaleMax)
            x = RandomFloat( self.MapRect['x1'], self.MapRect['x2'] )
            z = RandomFloat( self.MapRect['z1'], self.MapRect['z2'] )
            y = GetSurfaceHeight(x,z)

            meteor = self:CreateProjectile('/effects/entities/Meteor/Meteor_proj.bp', x, y, z)
            meteor.Damage = Random(self.MinDmgPerMeteor, self.MaxDmgPerMeteor)
            meteor.DamageFriendly = true
            meteor.DamageRadius = meteor.DamageRadius * s
            meteor.FxScale = s
            meteor:Start(Vector(x,y,z), 3)

            WaitSeconds( RandomFloat(IntervalMin, IntervalMax) )
        end
    end,
}

TypeClass = MeteorRain
