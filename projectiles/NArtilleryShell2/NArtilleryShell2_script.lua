local ArtilleryShell = import('/lua/nomadsprojectiles.lua').ArtilleryShell

NArtilleryShell2 = Class(ArtilleryShell) {
    GetLauncher = function(self)
        --this just swaps the priorities on returning the launcher value before the engine function so we can use this to transfer veterancy.
        --ideally we would use an Instigator variable and set that in OnImpact directly, but that would need destructive hooks.
        return self.Launcher or ArtilleryShell.GetLauncher(self)
    end,
}

TypeClass = NArtilleryShell2