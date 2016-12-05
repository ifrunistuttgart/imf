classdef Gravity
    %GRAVITY Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        value@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        function obj = Gravity(value, coordinateSystem)
            if isvector(value)
                obj.value = imf.Vector(value);
            elseif isa(value, 'imf.Vector')
                obj.value = value;
            else
                error('The force must be either an numeric or symbolic vector or an imf.Vector');
            end
            
            if isa(coordinateSystem, 'imf.CoordinateSystem')
                obj.coordinateSystem = coordinateSystem;
            else
                error('The coordinateSystem must be an imf.CoordinateSystem');
            end
        end
    end
end

