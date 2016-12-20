classdef Inertia
    %FORCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        value@imf.Matrix
        attitudeVector@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        function obj = Inertia(value, attitudeVector, coordinateSystem)
            if ismatrix(value)
                obj.value = imf.Matrix(value);
            elseif isa(inertia, 'imf.Matrix')
                obj.value = value;
            else
                error('The inertia must be either an numeric or symbolic matrix or an imf.Vector');
            end
            
            
            if isvector(attitudeVector)
                if ~isa(attitudeVector, 'imf.Expression')
                    obj.attitudeVector = imf.Vector(imf.Expression(attitudeVector));
                else
                    obj.attitudeVector = imf.Vector(attitudeVector);
                end
            elseif isa(attitudeVector, 'imf.Vector')
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

