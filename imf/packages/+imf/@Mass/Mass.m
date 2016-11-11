classdef Mass < handle
    %MASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mass
        point@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        
        function obj = Mass(mass, point, coordinateSystem)
            if isnumeric(mass) && length(mass) == 1
                obj.mass = mass;
            else
                error('The mass must be an numeric scalar');
            end
            
            if isvector(point)
                obj.point = imf.Vector(point);
            elseif isa(point, 'imf.Vector')
                obj.point = point;
            else
                error('The point must be either an numeric vector or an imf.Vector');
            end
            
            if isa(coordinateSystem, 'imf.CoordinateSystem')
                obj.coordinateSystem = coordinateSystem;
            else
                error('The coordinateSystem must be an imf.CoordinateSystem');
            end
        end
        
    end
    
end

