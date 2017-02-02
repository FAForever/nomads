-- The surface support vehicle that's in orbit

local NCivilianStructureUnit = import('/lua/nomadsunits.lua').NCivilianStructureUnit

INC0001 = Class(NCivilianStructureUnit) {
    
    OnCreate = function(self)
        self.BuildEffectsBag = TrashBag()
        NCivilianStructureUnit.OnCreate(self)
        
        if self:GetBlueprint().Physics.Elevation then
            self:Hover()
        end
        if self:GetBlueprint().Rotators.Stationary then
            self:StationaryAngle()
        else
            self:RotatingAngle()
        end
    end,
    
    Hover = function(self)
        local pos = self:GetPosition()
        local surface = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
        local elevation = self:GetBlueprint().Physics.Elevation
        pos[2] = surface + elevation
        self:SetPosition( pos, true)
    end,
    
    RotatingAngle = function(self)
        -- spinner 1
        if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'Primary_Spinner', 'z' )
            self.RotatorManipulator1:SetAccel( self:GetBlueprint().Rotators.PrimaryAccel ) 
            self.RotatorManipulator1:SetTargetSpeed( self:GetBlueprint().Rotators.PrimarySpeed ) 
            self.Trash:Add( self.RotatorManipulator1 )
        end

        -- spinner 2
        if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'Secondary_Spinner', 'z' )
            self.RotatorManipulator2:SetAccel( self:GetBlueprint().Rotators.SecondaryAccel ) 
            self.RotatorManipulator2:SetTargetSpeed( self:GetBlueprint().Rotators.SecondarySpeed ) 
            self.Trash:Add( self.RotatorManipulator2 )
        end
        
    end,
    
    StationaryAngle = function(self)
        -- spinner 1
        if not self.RotatorManipulator1 then
            self.RotatorManipulator1 = CreateRotator( self, 'Primary_Spinner', 'z' )
            self.RotatorManipulator1:SetCurrentAngle( self:GetBlueprint().Rotators.PrimaryAngle )
            self.Trash:Add( self.RotatorManipulator1 )
        end

        -- spinner 2
        if not self.RotatorManipulator2 then
            self.RotatorManipulator2 = CreateRotator( self, 'Secondary_Spinner', 'z' )
            self.RotatorManipulator2:SetCurrentAngle( self:GetBlueprint().Rotators.SecondaryAngle )
            self.Trash:Add( self.RotatorManipulator2 )
        end
    end,
}

TypeClass = INC0001