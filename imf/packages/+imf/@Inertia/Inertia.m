classdef Inertia
    %FORCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        value@imf.Matrix
        attitudeVector@imf.Vector
        origin@imf.PositionVector
    end
    
    methods
        function obj = Inertia(name, value, attitudeVector, origin)
            
            if ischar(name) && ~isempty(value)
                obj.name = name;
            end
            
            if isa(value, 'imf.Matrix')
                obj.value = value;
            else
                error('The inertia must be an imf.Matrix');
            end            
            
            if isa(attitudeVector, 'imf.Vector')
                obj.attitudeVector = attitudeVector;
            else
                error('The attitudeVector must be either an numeric vector or an imf.Vector');
            end
            
            if nargin < 4
                obj.origin = imf.PositionVector([0;0;0], obj.value.coordinateSystem);
            else
                obj.origin = origin;
            end
        end
        
        function obj = In(obj, coordinateSystem)
            if obj.value.coordinateSystem ~= coordinateSystem || obj.attitudeVector.coordinateSystem ~= coordinateSystem
                obj = imf.Inertia(obj.name, obj.value.In(coordinateSystem), obj.attitudeVector.In(coordinateSystem), obj.origin.In(coordinateSystem));
            end
        end
    end
    
end

