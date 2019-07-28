local StrategicMissile = import('/lua/nomadsprojectiles.lua').StrategicMissile
local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

NOrbitalMissile1 = Class(StrategicMissile) {

    OnCreate = function(self, inWater)
        StrategicMissile.OnCreate(self)
        self:ForkThread(self.TrailThread)
    end,

    MovementThread = function(self)
        local bp = self:GetBlueprint().Physics

        self:SetLifetime(300)  -- live max 5 minutes. should be long enough even on 81 km maps, right?
        self:TrackTarget(true)
        self:SetStage(0)

        local TargetPos = self:GetCurrentTargetPosition()
        local MissilePos = self:GetPosition()

        -- 1: make missile fly horizontally: set target Z coordinate high in air
        local CurTarPos = table.copy(TargetPos)
        CurTarPos[2] = MissilePos[2]
        self:SetNewTargetGround(CurTarPos)
        self:SetStage(1)

        -- 2: when close enough, retarget to the intended target at the surface
        self:WaitTillDistanceToPosIsLessThan(CurTarPos, bp.Stage2Distance)
        CurTarPos = table.copy(TargetPos)
        self:SetNewTargetGround(CurTarPos)
        self:SetStage(2)

        -- 3: wait to be close enough for 3rd stage
        self:WaitTillDistanceToPosIsLessThan(CurTarPos, bp.Stage3Distance)
        self:SetStage(3)

        -- 4: wait to be close enough for last stage
        self:WaitTillDistanceToPosIsLessThan(CurTarPos, bp.Stage4Distance)
        self:SetStage(4)

        -- 5: just before impact
        self:WaitTillDistanceToPosIsLessThan(CurTarPos, bp.Stage5Distance)
        self:SetStage(5)
    end,

    SetStage = function(self, stage)
        local bp = self:GetBlueprint().Physics

        if stage == 0 then
            self:SetTurnRate( bp.TurnRate )
            self:SetMaxSpeed( bp.MaxSpeed )
            self:SetVelocity( bp.MaxSpeed )
            self:ChangeMaxZigZag( bp.MaxZigZag )
            self:ChangeZigZagFrequency( bp.ZigZagFrequency )

        elseif stage == 1 then
            self:SetTurnRate( bp.TurnRateS1 or bp.TurnRate )
            self:SetMaxSpeed( bp.MaxSpeedS1 or bp.MaxSpeed )
            self:SetVelocity( bp.MaxSpeedS1 or bp.MaxSpeed )
            self:ChangeMaxZigZag( bp.MaxZigZagS1 or bp.MaxZigZag )
            self:ChangeZigZagFrequency( bp.ZigZagFrequencyS1 or bp.ZigZagFrequency )

        elseif stage == 2 then
            self:SetTurnRate( bp.TurnRateS2 or bp.TurnRateS1 or bp.TurnRate )
            self:SetMaxSpeed( bp.MaxSpeedS2 or bp.MaxSpeedS1 or bp.MaxSpeed )
            self:SetVelocity( bp.MaxSpeedS2 or bp.MaxSpeedS1 or bp.MaxSpeed )
            self:ChangeMaxZigZag( bp.MaxZigZagS2 or bp.MaxZigZagS1 or bp.MaxZigZag )
            self:ChangeZigZagFrequency( bp.ZigZagFrequencyS2 or bp.ZigZagFrequencyS1 or bp.ZigZagFrequency )

        elseif stage == 3 then
            self:SetTurnRate( bp.TurnRateS3 or bp.TurnRateS2 or bp.TurnRateS1 or bp.TurnRate )
            self:SetMaxSpeed( bp.MaxSpeedS3 or bp.MaxSpeedS2 or bp.MaxSpeedS1 or bp.MaxSpeed )
            self:SetVelocity( bp.MaxSpeedS3 or bp.MaxSpeedS2 or bp.MaxSpeedS1 or bp.MaxSpeed )
            self:ChangeMaxZigZag( bp.MaxZigZagS3 or bp.MaxZigZagS2 or bp.MaxZigZagS1 or bp.MaxZigZag )
            self:ChangeZigZagFrequency( bp.ZigZagFrequencyS3 or bp.ZigZagFrequencyS2 or bp.ZigZagFrequencyS1 or bp.ZigZagFrequency )

        elseif stage == 4 then
            self:SetTurnRate( bp.TurnRateS4 or bp.TurnRateS3 or bp.TurnRateS2 or bp.TurnRateS1 or bp.TurnRate )
            self:SetMaxSpeed( bp.MaxSpeedS4 or bp.MaxSpeedS3 or bp.MaxSpeedS2 or bp.MaxSpeedS1 or bp.MaxSpeed )
            self:SetVelocity( bp.MaxSpeedS4 or bp.MaxSpeedS3 or bp.MaxSpeedS2 or bp.MaxSpeedS1 or bp.MaxSpeed )
            self:ChangeMaxZigZag( bp.MaxZigZagS4 or bp.MaxZigZagS3 or bp.MaxZigZagS2 or bp.MaxZigZagS1 or bp.MaxZigZag )
            self:ChangeZigZagFrequency( bp.ZigZagFrequencyS4 or bp.ZigZagFrequencyS3 or bp.ZigZagFrequencyS2 or bp.ZigZagFrequencyS1 or bp.ZigZagFrequency )

        elseif stage == 5 then
            self:SetTurnRate( bp.TurnRateS5 or bp.TurnRateS4 or bp.TurnRateS3 or bp.TurnRateS2 or bp.TurnRateS1 or bp.TurnRate )
            self:SetMaxSpeed( bp.MaxSpeedS5 or bp.MaxSpeedS4 or bp.MaxSpeedS3 or bp.MaxSpeedS2 or bp.MaxSpeedS1 or bp.MaxSpeed )
            self:SetVelocity( bp.MaxSpeedS5 or bp.MaxSpeedS4 or bp.MaxSpeedS3 or bp.MaxSpeedS2 or bp.MaxSpeedS1 or bp.MaxSpeed )
            self:ChangeMaxZigZag( bp.MaxZigZagS5 or bp.MaxZigZagS4 or bp.MaxZigZagS3 or bp.MaxZigZagS2 or bp.MaxZigZagS1 or bp.MaxZigZag )
            self:ChangeZigZagFrequency( bp.ZigZagFrequencyS5 or bp.ZigZagFrequencyS4 or bp.ZigZagFrequencyS3 or bp.ZigZagFrequencyS2 or bp.ZigZagFrequencyS1 or bp.ZigZagFrequency )

        else
            WARN('*DEBUG: NOrbitalMissile: unknown stage '..repr(stage))
        end
    end,

    TrailThread = function(self)
        -- add a trail when the projectile enters the atmosphere

        local bp = self:GetBlueprint().Display.Trail
        local pos = self:GetPosition()
        local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
        local height = surface + bp.AtmosphereHeight

        while self and not self:BeenDestroyed() and pos[2] > height do
            WaitTicks(1)
            pos = self:GetPosition()
        end

        if self and not self:BeenDestroyed() then
            for k, v in  NomadsEffectTemplate.OrbitalStrikeMissile_AtmosphereTrail do
                self.Trash:Add( CreateAttachedEmitter( self, -1, self:GetArmy(), v ) )
            end
        end
    end,

    WaitTillDistanceToPosIsLessThan = function(self, pos, var)
        local mpos
        local dist = self:GetDistanceToPos(pos)
        while dist > var do
            WaitSeconds(0.1)
            dist = self:GetDistanceToPos(pos)
        end
    end,

    GetDistanceToPos = function(self, pos)
        local mpos = self:GetPosition()
        local dist = VDist3(mpos, pos)
        return dist
    end,
}

TypeClass = NOrbitalMissile1
