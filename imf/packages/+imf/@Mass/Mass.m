classdef Mass < handle
    %MASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = 'private')
        name
        value
        positionVector@imf.PositionVector
    end
    
    methods
        
        function obj = Mass(name, value, positionVector)
            
            if ischar(name) && ~isempty(value)
                obj.name = name;
            end
            
            if isnumeric(value) && length(value) == 1
                obj.value = value;
            elseif isa(value, 'imf.Variable')
                obj.value = value;
            else
                error('The mass must be an numeric scalar');
            end
            
            if isa(positionVector, 'imf.PositionVector')
                obj.positionVector = positionVector;
            else
                error('The point must be an imf.PositionVector');
            end
        end
        
        function obj = In(obj, coordinateSystem)
            if obj.positionVector.coordinateSystem ~= coordinateSystem
                obj = imf.Mass(obj.name, obj.value, obj.positionVector.In(coordinateSystem));
            end
        end
        
    end
    
end