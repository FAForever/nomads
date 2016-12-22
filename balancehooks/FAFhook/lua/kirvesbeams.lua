do


local oldTargetingCollisionBeam = TargetingCollisionBeam

TargetingCollisionBeam = Class(EmptyCollisionBeam) {
    DoDamage = function(self, instigator, damageData, targetEntity)
    end,

    CreateBeamEffects = function(self)
        local army = self:GetArmy()
        for k, y in self.FxBeamStartPoint do
            local fx = CreateAttachedEmitter(self, 0, army, y ):ScaleEmitter(self.FxBeamStartPointScale)
            table.insert( self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end
        for k, y in self.FxBeamEndPoint do
            local fx = CreateAttachedEmitter(self, 1, army, y ):ScaleEmitter(self.FxBeamEndPointScale)
            table.insert( self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end
        if table.getn(self.FxBeam) != 0 then
            local fxBeam = CreateBeamEmitter(self.FxBeam[Random(1, table.getn(self.FxBeam))], army)
            AttachBeamToEntity(fxBeam, self, 0, army)
            
            # collide on start if it's a continuous beam
            local weaponBlueprint = self.Weapon:GetBlueprint()
            local bCollideOnStart = weaponBlueprint.BeamLifetime <= 0
            self:SetBeamFx(fxBeam, bCollideOnStart)
            
            table.insert( self.BeamEffectsBag, fxBeam )
            self.Trash:Add(fxBeam)
# ignoring this to prevent log spam
#        else
#            LOG('*ERROR: THERE IS NO BEAM EMITTER DEFINED FOR THIS COLLISION BEAM ', repr(self.FxBeam))
        end
    end,
}


end