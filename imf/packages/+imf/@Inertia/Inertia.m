classdef Inertia
    %FORCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        value@imf.Vector
        positionVector@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        function obj = Inertia(value, positionVector, coordinateSystem)
            if ismatrix(value)
                obj.value = imf.Vector(value);
            elseif isa(inertia, 'imf.Vector')
                obj.value = value;
            else
                error('The inertia must be either an numeric or symbolic matrix or an imf.Vector');
            end
            
            
            if isvector(positionVector)
                obj.positionVector = imf.Vector(positionVector);
            elseif isa(positionVector, 'imf.Vector')
                obj.positionVector = positionVector;
            else
                error('The pointOfApplication must be either an numeric vector or an imf.Vector');
            end
            
            if isa(coordinateSystem, 'imf.CoordinateSystem')
                obj.coordinateSystem = coordinateSystem;
            else
                error('The coordinateSystem must be an imf.CoordinateSystem');
            end
        end
    end
    
end

