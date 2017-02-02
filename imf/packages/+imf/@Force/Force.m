classdef Force
    %FORCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = 'private')
        name
        value@imf.Vector
        positionVector@imf.PositionVector
    end
    
    methods
        function obj = Force(name, value, positionVector)
            
            if ischar(name) && ~isempty(value)
                obj.name = name;
            end
            
            if isa(value, 'imf.Vector')
                obj.value = value;
            else
                error('The force must be an imf.Vector');
            end            
            
            if isa(positionVector, 'imf.PositionVector')
                obj.positionVector = positionVector;
            else
                error('The point of application must be an imf.PositionVector');
            end
            
        end
        
        function obj = In(obj, coordinateSystem)
            if obj.value.coordinateSystem ~= coordinateSystem || obj.positionVector.coordinateSystem ~= coordinateSystem
                obj = imf.Force(obj.name, obj.value.In(coordinateSystem), obj.positionVector.In(coordinateSystem));
            end
        end
    end
    
end

