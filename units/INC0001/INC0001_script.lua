-- The surface support vehicle that's in orbit

local NCivilianStructureUnit = import('/lua/nomadunits.lua').NCivilianStructureUnit

INC0001 = Class(NCivilianStructureUnit) {
    
    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        NCivilianStructureUnit.OnCreate(self)
        
        -- spinner 1
        if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'Primary_Spinner', 'z' )
            self.RotatorManipulator1:SetCurrentAngle( 45 )
            self.Trash:Add( self.RotatorManipulator1 )
        end

        -- spinner 2
        if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'Secondary_Spinner', 'z' )
            self.RotatorManipulator2:SetCurrentAngle( -45 )
            self.Trash:Add( self.RotatorManipulator2 )
        end
    end,
    }

TypeClass = INC0001