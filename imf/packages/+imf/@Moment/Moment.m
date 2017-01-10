classdef Moment
    %MOMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = 'private')
        name
        value@imf.Vector
        attitudeVector@imf.Vector
        origin@imf.PositionVector
    end
    
    methods
        
        function obj = Moment(name, value, attitudeVector, origin)
            
            if ischar(name) && ~isempty(value)
                obj.name = name;
            end
            
            if isa(value, 'imf.Vector')
                obj.value = value;
            else
                error('The moment must be an imf.Vector');
            end
            
            if isa(attitudeVector, 'imf.Vector')
                obj.attitudeVector = attitudeVector;
            else
                error('The attitudeVector must be an imf.Vector');
            end
            
            if nargin < 4
                obj.origin = imf.PositionVector([0;0;0], obj.value.coordinateSystem);
            else
                obj.origin = origin;
            end
            
        end
        
        function obj = In(obj, coordinateSystem)
            if obj.value.coordinateSystem ~= coordinateSystem || obj.attitudeVector.coordinateSystem ~= coordinateSystem
                obj = imf.Moment(obj.name, obj.value.In(coordinateSystem), obj.attitudeVector.In(coordinateSystem), obj.origin.In(coordinateSystem));
            end
        end
        
    end
    
end

