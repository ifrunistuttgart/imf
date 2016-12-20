classdef Moment
    %MOMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        value@imf.Vector
        attitudeVector@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        
        function obj = Moment(value, attitudeVector, coordinateSystem)
            if isvector(value)
                obj.value = imf.Vector(value);
            elseif isa(force, 'imf.Vector')
                obj.value = value;
            else
                error('The moment must be either an numeric or symbolic vector or an imf.Vector');
            end
            
            if isvector(attitudeVector)
                if ~isa(attitudeVector, 'imf.Expression')
                    obj.attitudeVector = imf.Vector(imf.Expression(attitudeVector));
                else
                    obj.attitudeVector = imf.Vector(attitudeVector);
                end
            elseif isa(force, 'imf.Vector')
                obj.attitudeVector = attitudeVector;
            else
                error('The attitudeVector must be either an numeric vector or an imf.Vector');
            end
                        
            if isa(coordinateSystem, 'imf.CoordinateSystem')
                obj.coordinateSystem = coordinateSystem;
            else
                error('The coordinateSystem must be an imf.CoordinateSystem');
            end
        end
        
    end
    
end

