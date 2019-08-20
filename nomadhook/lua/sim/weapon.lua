do

-- Small modification that allows requesting weapon enabled state

local oldWeapon = Weapon
Weapon = Class(oldWeapon) {

    OnCreate = function(self)
        self.IsEnabled = true
        self._MaxRadius = self:GetBlueprint().MaxRadius or 0
        self.RateOfFire = self:GetBlueprint().RateOfFire
        self.DoAlternateDualAimController = false
        self:DetermineColourIndex()
        oldWeapon.OnCreate(self)
    end,

    DetermineColourIndex = function(self)
        --we determine the index once on create then save it in the entity table to save on sim slowdown
        if not self.unit.ColourIndex then
            WARN('crazy unit is crazy - no colour index despite when its set OnPreCreate! blueprintID: ' .. self.unit:GetUnitId())
        end
        self.ColourIndex = self.unit.ColourIndex or 383.999
    end,

    SetEnabled = function(self, enable)
        oldWeapon.SetEnabled(self, enable)
        self.IsEnabled = enable
    end,

    ChangeMaxRadius = function(self, val)
        self._MaxRadius = val
        return oldWeapon.ChangeMaxRadius(self, val)
    end,

    GetMaxRadius = function(self)
        return self._MaxRadius or 0
    end,

    GetRateOfFire = function(self)
        return self.RateOfFire
    end,

    ChangeRateOfFire = function(self, newROF)
        self.RateOfFire = newROF
        oldWeapon.ChangeRateOfFire(self, newROF)
    end,

    OnLayerChange = function(self, new, old)
        --LOG('*DEBUG: Weapon OnLayerChange new = '..repr(new)..' old = '..repr(old))
    end,

    -- allowing the unit stun script to halt fire of this weapon
    OnHaltFire = function(self)
        self.HaltFireOrdered = true
    end,

    OnUnhaltFire = function(self)
        self.HaltFireOrdered = false
    end,

    OnWeaponFired = function(self)
        oldWeapon.OnWeaponFired(self)
        self:SwitchAimController()
    end,

    CreateProjectileForWeapon = function(self, bone) --all this is to get the proj to be recoloured!
        local proj = self:CreateProjectile(bone)
        proj.colourIndex = self.colourIndex --pass our colour data to the proj
        local damageTable = self:GetDamageTable()

        if proj and not proj:BeenDestroyed() then
            proj:PassDamageData(damageTable)
            local bp = self:GetBlueprint()

            if bp.NukeOuterRingDamage and bp.NukeOuterRingRadius and bp.NukeOuterRingTicks and bp.NukeOuterRingTotalTime and
                bp.NukeInnerRingDamage and bp.NukeInnerRingRadius and bp.NukeInnerRingTicks and bp.NukeInnerRingTotalTime then
                proj.InnerRing = NukeDamage()
                proj.InnerRing:OnCreate(bp.NukeInnerRingDamage, bp.NukeInnerRingRadius, bp.NukeInnerRingTicks, bp.NukeInnerRingTotalTime)
                proj.OuterRing = NukeDamage()
                proj.OuterRing:OnCreate(bp.NukeOuterRingDamage, bp.NukeOuterRingRadius, bp.NukeOuterRingTicks, bp.NukeOuterRingTotalTime)

                -- Need to store these three for later, in case the missile lands after the launcher dies
                proj.Launcher = self.unit
                proj.Army = self.unit:GetArmy()
                proj.Brain = self.unit:GetAIBrain()
            end
        end
        return proj
    end,

    SetOnTransport = function(self, transportstate)
        -- remember previous weapon state when going in transport and revert to that when going out of transport
        if not self.unit:GetBlueprint().Transport.CanFireFromTransport then
            if transportstate then
                self.WeaponDisabledOnTransportWasEnabled = self.IsEnabled
            end
        end

        oldWeapon.SetOnTransport(self, transportstate)

        if not self.unit:GetBlueprint().Transport.CanFireFromTransport then
            if not transportstate then
                local en = not (self.WeaponDisabledOnTransportWasEnabled == false)
                self:SetWeaponEnabled(en)
            end
        end
    end,

    SetupTurret = function(self)
        -- First part rewritten to allow for individual targeting dual weapon turrets

        local bp = self:GetBlueprint()
        local yawBone = bp.TurretBoneYaw
        local pitchBone = bp.TurretBonePitch
        local muzzleBone = bp.TurretBoneMuzzle
        local precedence = bp.AimControlPrecedence or 10

        if not (self.unit:ValidateBone(yawBone) and self.unit:ValidateBone(pitchBone) and self.unit:ValidateBone(muzzleBone)) then
            error('*ERROR: Bone aborting turret setup due to bone issues.', 2)
             return
        end

        if yawBone and pitchBone and muzzleBone then

            if bp.TurretDualManipulators then

                local yawBone2 = bp.TurretBoneDualYaw
                local pitchBone2 = bp.TurretBoneDualPitch
                local muzzleBone2 = bp.TurretBoneDualMuzzle

                if (yawBone2 ~= nil and not self.unit:ValidateBone(yawBone2)) or not self.unit:ValidateBone(pitchBone2) or not self.unit:ValidateBone(muzzleBone2) then
                    error('*ERROR: Bone aborting turret setup due to Dual yaw/pitch/muzzle bone issues.', 2)
                    return
                end

                if bp.TurretBoneDualYaw then ------ dual turret - individual targeting
                    self.AimControl = CreateAimController(self, 'Torso', yawBone)
                    self.AimRight = CreateAimController(self, 'Right', yawBone, pitchBone, muzzleBone)
                    self.AimLeft = CreateAimController(self, 'Left', yawBone2, pitchBone2, muzzleBone2)

                    self.AimControl:SetPrecedence(precedence)
                    self.AimRight:SetPrecedence(precedence)
                    self.AimLeft:SetPrecedence(precedence)
                    if EntityCategoryContains(categories.STRUCTURE, self.unit) then
                        self.AimControl:SetResetPoseTime(9999999)
                    end
                    self:SetFireControl('Right')
                    self.unit.Trash:Add(self.AimControl)
                    self.unit.Trash:Add(self.AimRight)
                    self.unit.Trash:Add(self.AimLeft)

                    -- only allow alternate if different aim bones are used and not all racks are fired together
                    self.DoAlternateDualAimController = bp.RackFireTogether ~= true and (bp.TurretDualManipulatorsAlternate == true or bp.TurretDualManipulatorsAlternate == nil)

                    -- when doing alternate fire verify required BP keys are present and valid
                    if self.DoAlternateDualAimController then
                        -- do BP checks
                        for n, rack in bp.RackBones do
                            if rack.TurretBoneDualManip ~= 'Left' and rack.TurretBoneDualManip ~= 'Right' then
                                WARN('*DEBUG: unit '..self.unit:GetUnitId()..', TurretBoneDualManip should have value Left or Right, not '..repr(switchTo)..' in weapon rack '..repr(self.CurrentRackSalvoNumber)..' of weapon '..bp.DisplayName)
                            end
                        end
                    end

                else  ------ dual turret - always right (original game)

                    self.AimControl = CreateAimController(self, 'Torso', yawBone)
                    self.AimRight = CreateAimController(self, 'Right', pitchBone, pitchBone, muzzleBone)
                    self.AimLeft = CreateAimController(self, 'Left', pitchBone2, pitchBone2, muzzleBone2)

                    self.AimControl:SetPrecedence(precedence)
                    self.AimRight:SetPrecedence(precedence)
                    self.AimLeft:SetPrecedence(precedence)

                    if EntityCategoryContains(categories.STRUCTURE, self.unit) then
                        self.AimControl:SetResetPoseTime(9999999)
                    end

                    self:SetFireControl('Right')
                    self.unit.Trash:Add(self.AimControl)
                    self.unit.Trash:Add(self.AimRight)
                    self.unit.Trash:Add(self.AimLeft)
                end

            else ------ single turret (1 barrel)

                self.AimControl = CreateAimController(self, 'Default', yawBone, pitchBone, muzzleBone)
                if EntityCategoryContains(categories.STRUCTURE, self.unit) then
                    self.AimControl:SetResetPoseTime(9999999)
                end
                self.unit.Trash:Add(self.AimControl)
                self.AimControl:SetPrecedence(precedence)
                if bp.RackSlavedToTurret and table.getn(bp.RackBones) > 0 then
                    for k, v in bp.RackBones do
                        if v.RackBone ~= pitchBone then
                            local slaver = CreateSlaver(self.unit, v.RackBone, pitchBone)
                            slaver:SetPrecedence(precedence-1)
                            self.unit.Trash:Add(slaver)
                        end
                    end
                end
            end

        else
            error('*ERROR: Trying to setup a turreted weapon but there are yaw bones, pitch bones or muzzle bones missing from the blueprint.', 2)

        end

        local numbersexist = true
        local turretyawmin, turretyawmax, turretyawspeed
        local turretpitchmin, turretpitchmax, turretpitchspeed

        --SETUP MANIPULATORS AND SET TURRET YAW, PITCH AND SPEED
        if self:GetBlueprint().TurretYaw and self:GetBlueprint().TurretYawRange then
            turretyawmin, turretyawmax = self:GetTurretYawMinMax()
        else
            numbersexist = false
        end
        if self:GetBlueprint().TurretYawSpeed then
            turretyawspeed = self:GetTurretYawSpeed()
        else
            numbersexist = false
        end
        if self:GetBlueprint().TurretPitch and self:GetBlueprint().TurretPitchRange then
            turretpitchmin, turretpitchmax = self:GetTurretPitchMinMax()
        else
            numbersexist = false
        end
        if self:GetBlueprint().TurretPitchSpeed then
            turretpitchspeed = self:GetTurretPitchSpeed()
        else
            numbersexist = false
        end
        if numbersexist then
            self.AimControl:SetFiringArc(turretyawmin, turretyawmax, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
            if self.AimRight then
                self.AimRight:SetFiringArc(turretyawmin/12, turretyawmax/12, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
            end
            if self.AimLeft then
                self.AimLeft:SetFiringArc(turretyawmin/12, turretyawmax/12, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
            end
        else
            local strg = '*ERROR: TRYING TO SETUP A TURRET WITHOUT ALL TURRET NUMBERS IN BLUEPRINT, ABORTING TURRET SETUP. WEAPON: ' .. self:GetBlueprint().Label .. ' UNIT: '.. self.unit:GetUnitId()
            error(strg, 2)
        end

        self:SwitchAimController()
    end,

    GetNextRackSalvoNumber = function(self)
        local bp = self:GetBlueprint()
        local next = (self.CurrentRackSalvoNumber or (table.getn(bp.RackBones) + 1)) - 1  -- minus one to correct for RackSalvoFiringState.Main, it leaves the variable one too
        if next > table.getn(bp.RackBones) then                                           -- high. Also, the last rackbone seems to fire first so use that as default.
            next = 1
        end
        return next
    end,

    SwitchAimController = function(self)
        -- Alternate between aim controller after each shot so each barrel fires at the unit and no shots are wasted.
        if self.DoAlternateDualAimController then
            if self.AlternateDualAimCtrlThread then
                KillThread(self.AlternateDualAimCtrlThread)
                self.AlternateDualAimCtrlThread = nil
            end

            local bp = self:GetBlueprint()
            local rack = bp.RackBones[ self:GetNextRackSalvoNumber() ]
            local switchTo = rack.TurretBoneDualManip
            local delay = rack.TurretBoneDualManipSwitchDelay or (0.2 * (1 / self:GetRateOfFire())) -- switch when half way to next salvo, calculate in real time to include buffs and alike
            self.AlternateDualAimCtrlThread = self:ForkThread( self.SwitchAimControllerThread, switchTo, delay )
        end
    end,

    SwitchAimControllerThread = function(self, switchTo, delay)
        local bp = self:GetBlueprint()
        local precedence = bp.AimControlPrecedence or 10
        if delay >= 0.1 then  -- if delay is less than 0 don't wait at all
            WaitSeconds(delay)
            if self and self.unit and self.unit.Dead then
                return
            end
        end

        if switchTo == 'Left' then
            self.AimRight:SetPrecedence(precedence)
            self.AimLeft:SetPrecedence(precedence + 1)
            self:SetFireControl('Left')
        else
            self.AimLeft:SetPrecedence(precedence)
            self.AimRight:SetPrecedence(precedence + 1)
            self:SetFireControl('Right')
        end
    end
}


end