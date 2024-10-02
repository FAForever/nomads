local NStructureUnit = import('/lua/nomadsunits.lua').NStructureUnit
local ParticleBlaster1 = import('/lua/nomadsweapons.lua').ParticleBlaster1

--- Tech 2 Anti-Air Gun
---@class XNB2202 : NStructureUnit
XNB2202 = Class(NStructureUnit) {

    Weapons = {
        AAGun = Class(ParticleBlaster1) {

            OnWeaponFired = function(self)
                ParticleBlaster1.OnWeaponFired(self)

                -- set timer and start the watch thread if it is not running yet
                local yep = (not self.Timer or self.Timer <= 0)
                self.Timer = 5
                if yep or not self.WaitThreadHandle then
                    self.WaitThreadHandle = self:ForkThread( self.WatchThread )
                end

                self.unit:GoSpinners(true)
            end,

            WatchThread = function(self)
                -- keeps decreasing the counter until it reaches 0, then stops the spinners.
                while not self:BeenDestroyed() and self.Timer > 0 do
                    self.Timer = self.Timer - 1
                    WaitSeconds(1)
                end

                if not self:BeenDestroyed() then
                    self.unit:GoSpinners(false)
                end

                self.WaitThreadHandle = nil
            end,
        },
    },

    ---@param self XNB2202
    OnCreate = function(self)
        NStructureUnit.OnCreate(self)

        self.Spinning = false
        self.Spinners = {
            CreateRotator(self, 'spinner.001', 'z', nil, 0, 500, 360):SetTargetSpeed(0),
            CreateRotator(self, 'spinner.002', 'z', nil, 0, 500, 360):SetTargetSpeed(0),
            CreateRotator(self, 'spinner.003', 'z', nil, 0, 500, 360):SetTargetSpeed(0),
            CreateRotator(self, 'spinner.004', 'z', nil, 0, 500, 360):SetTargetSpeed(0),
        }
        for k, _ in self.Spinners do
            self.Trash:Add( self.Spinners[k] )
        end
    end,

    ---@param self XNB2202
    ---@param go boolean
    GoSpinners = function(self, go)
        -- makes the spinners rotate or stop
        go = (go == true)
        if go and not self.Spinning then
            for k, v in self.Spinners do
                v:SetTargetSpeed(700)
            end
        elseif not go and self.Spinning then
            for k, v in self.Spinners do
                v:SetTargetSpeed(0)
            end
        end
        self.Spinning = go
    end,
}
TypeClass = XNB2202