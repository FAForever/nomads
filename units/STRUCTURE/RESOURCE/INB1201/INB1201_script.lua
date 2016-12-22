# T2 pgen

local NomadEffectTemplate = import('/lua/nomadeffecttemplate.lua')
local NEnergyCreationUnit = import('/lua/nomadunits.lua').NEnergyCreationUnit

INB1201 = Class(NEnergyCreationUnit) {

    OnCreate = function(self)
        NEnergyCreationUnit.OnCreate(self)

        # create spinners
        self.Spinners = {
            CreateRotator(self, 'spinner.001', 'y', nil, 0, 10, 0),
            CreateRotator(self, 'spinner.002', 'y', nil, 0, 10, 0),
        }
        self.Trash:Add( self.Spinners[1] )
        self.Trash:Add( self.Spinners[2] )

        # rotators
        self.Rotators = {
            CreateRotator(self, 'random_rotator', 'x', nil, 0, 10, 0),
            CreateRotator(self, 'random_rotator', 'y', nil, 0, 10, 0),
            CreateRotator(self, 'random_rotator', 'z', nil, 0, 10, 0),
        }
        self.Trash:Add( self.Rotators[1] )
        self.Trash:Add( self.Rotators[2] )
        self.Trash:Add( self.Rotators[3] )
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.TarmacBag.CurrentBP['AlbedoKilled'] then
            self.TarmacBag.CurrentBP.Albedo = self.TarmacBag.CurrentBP.AlbedoKilled
        end
        NEnergyCreationUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        # antennae lights
        local army, emit = self:GetArmy()
        for k, v in NomadEffectTemplate.AntennaeLights1 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.001', army, v) )
        end
        for k, v in NomadEffectTemplate.AntennaeLights4 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.002', army, v) )
        end
        for k, v in NomadEffectTemplate.AntennaeLights7 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.003', army, v) )
        end
        for k, v in NomadEffectTemplate.AntennaeLights1 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.004', army, v) )
        end
        for k, v in NomadEffectTemplate.AntennaeLights4 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.005', army, v) )
        end
        for k, v in NomadEffectTemplate.AntennaeLights7 do
            self.Trash:Add( CreateAttachedEmitter(self, 'blinklight.006', army, v) )
        end

        NEnergyCreationUnit.OnStopBeingBuilt( self, builder, layer )
    end,

    PlayActiveEffects = function(self)
        if self.Spinners[1] then self.Spinners[1]:SetTargetSpeed( 500 ) else LOG('INB1201: no spinner 1') end
        if self.Spinners[2] then self.Spinners[2]:SetTargetSpeed( -500 ) else LOG('INB1201: no spinner 2') end
        if self.Rotators[1] then self.Rotators[1]:SetTargetSpeed( 150 + Random(0, 50) ) else LOG('INB1201: no rotator 1') end
        if self.Rotators[2] then self.Rotators[2]:SetTargetSpeed( 150 + Random(0, 50) ) else LOG('INB1201: no rotator 2') end
        if self.Rotators[3] then self.Rotators[3]:SetTargetSpeed( 150 + Random(0, 50) ) else LOG('INB1201: no rotator 3') end

        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.001', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.002', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.003', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.004', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.005', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.006', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.007', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.008', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.009', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.010', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.011', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomDischarges, 'electric.012', Random(0, 30) ) )
        self.ActiveEffectsBag:Add( self:ForkThread( self.RandomBoneToBoneDischarges ) )

        return NEnergyCreationUnit.PlayActiveEffects(self)
    end,

    DestroyActiveEffects = function(self)
        if self.Spinners then
            for k, spinner in self.Spinners do
                if spinner and spinner.SetTargetSpeed then spinner:SetTargetSpeed( 0 ) end
            end
        end
        if  self.Rotators then
            for k, rotator in  self.Rotators do
                if rotator and rotator.SetTargetSpeed then rotator:SetTargetSpeed( 0 ) end
            end
        end
        self.ActiveEffectsBag:Destroy()
    end,

    RandomDischarges = function(self, bone, delay)
        WaitTicks( delay )
        local army, emit = self:GetArmy()
        for k, v in NomadEffectTemplate.T2PGAmbient do
            emit = CreateAttachedEmitter(self, bone, army, v)
            self.ActiveEffectsBag:Add( emit )
            self.Trash:Add( emit )
        end
    end,

    RandomBoneToBoneDischarges = function(self)
        # creates a discharge at a random interval between a set of 2 bones randomly chosen from the list below

        local intervalMean = 10
        local intervalDeviation = 0.25  # percentage of the mean, never make it >= 1
        local boneList = { { 'electric.001', 'electric.008', }, { 'electric.002', 'electric.009', }, { 'electric.003', 'electric.010', },
                           { 'electric.004', 'electric.011', }, { 'electric.005', 'electric.012', }, { 'electric.006', 'electric.007', }, }

        local army, emit, bone1, bone2, i, beam = self:GetArmy()
        local waitMin, waitMax = math.floor( intervalMean * (1 - intervalDeviation)), math.ceil( intervalMean * (1 + intervalDeviation))
        WaitTicks( Random( waitMin, waitMax ) )

        while self do

            # pick a random set of bones
            i = Random( 1, table.getsize( boneList ))
            bone1 = boneList[i][1]
            bone2 = boneList[i][2]

            # maybe reverse bone order
            if Random(1,2) == 1 then
                i = bone1
                bone1 = bone2
                bone2 = i
            end

            # create beam
            beam = CreateBeamEntityToEntity( self, bone1, self, bone2, army, NomadEffectTemplate.T2PGAmbientDischargeBeam )
            self.ActiveEffectsBag:Add( beam )
            self.Trash:Add( beam )

            # wait before creating new beam
            WaitTicks( Random( waitMin, waitMax ) )
        end
    end,
}

TypeClass = INB1201