-- T2 field enginer

local NomadsEffectTemplate = import('/lua/nomadseffecttemplate.lua')
local AddAnchorAbilty = import('/lua/nomadsutils.lua').AddAnchorAbilty
local AddIntelOvercharge = import('/lua/nomadsutils.lua').AddIntelOvercharge
local NConstructionUnit = import('/lua/nomadsunits.lua').NConstructionUnit
local MissileWeapon1 = import('/lua/nomadsweapons.lua').MissileWeapon1

NConstructionUnit = AddAnchorAbilty( AddIntelOvercharge( NConstructionUnit ))

INU3008 = Class(NConstructionUnit) {
    Weapons = {
        MainGun = Class(MissileWeapon1) {

            IdleState = State(MissileWeapon1.IdleState) {
                Main = function(self)
                    MissileWeapon1.IdleState.Main(self)
                    self.unit:OnTargetLost()
                end,
            },

            RackSalvoReloadState = State(MissileWeapon1.RackSalvoReloadState) {
                Main = function(self)
                    MissileWeapon1.RackSalvoReloadState.Main(self)
                    self.unit:OnTargetLost()
                end,
            },

            RackSalvoFireReadyState = State(MissileWeapon1.RackSalvoFireReadyState ) {
                Main = function(self)
                    MissileWeapon1.RackSalvoFireReadyState.Main(self)
                    self.unit:OnTargetAcquired()
                end,
            },

            RackSalvoFiringState = State(MissileWeapon1.RackSalvoFiringState ) {
                Main = function(self)
                    MissileWeapon1.RackSalvoFiringState.Main(self)
                    self.unit:OnTargetAcquired()
                end,
            },
        },
    },


    TMDEffectBones = { 'TMD_Fx1', 'TMD_Fx2', },

    OnCreate = function(self)
        NConstructionUnit.OnCreate(self)
        self.TAEffectsBag = TrashBag()
        self.PlayingTAEffects = false
    end,

    OnDestroy = function(self)
        self:DestroyTAEffects()
        NConstructionUnit.OnDestroy(self)
    end,

    OnTargetAcquired = function(self)
        --LOG('OnTargetAcquired')
        self:PlayTAEffects()
    end,

    OnTargetLost = function(self)
        --LOG('OnTargetLost')
        self:DestroyTAEffects()
    end,

    PlayTAEffects = function(self)
        if not self.PlayingTAEffects then
            local army, emit = self:GetArmy()
            for _, bone in self.TMDEffectBones do
                for k, v in NomadsEffectTemplate.T2MobileTacticalMissileDefenseTargetAcquired do
                    emit = CreateAttachedEmitter(self, bone, army, v)
                    self.TAEffectsBag:Add(emit)
                    self.Trash:Add(emit)
                end
            end
            local thread = function(self)
                WaitSeconds(1)
                self:DestroyTAEffects()
            end
            self.PlayingTAEffectsThread = self:ForkThread( thread )
            self.PlayingTAEffects = true
        end
    end,

    DestroyTAEffects = function(self)
        self.TAEffectsBag:Destroy()
        self.PlayingTAEffects = false
    end,

    EnableSpecialToggle = function(self)
        self:EnableAnchor(self)
    end,

    DisableSpecialToggle = function(self)
        self:DisableAnchor(self)
    end,

}

TypeClass = INU3008