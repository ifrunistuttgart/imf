classdef Mass < handle
    %MASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        value
        positionVector@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        
        function obj = Mass(value, positionVector, coordinateSystem)
            if isnumeric(value) && length(value) == 1
                obj.value = value;
            elseif isa(value, 'imf.Variable')
                obj.value = value;
            else
                error('The mass must be an numeric scalar');
            end
            
            if isvector(positionVector)
                if ~isa(positionVector, 'imf.Expression')
                    obj.positionVector = imf.Vector(imf.Expression(positionVector));
                else
                    obj.positionVector = imf.Vector(positionVector);
                end
            elseif isa(point, 'imf.Vector')
                obj.positionVector = positionVector;
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