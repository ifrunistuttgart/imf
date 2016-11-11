classdef Inertia
    %FORCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        inertia@imf.Vector
        pointOfApplication@imf.Vector
        coordinateSystem@imf.CoordinateSystem
    end
    
    methods
        function obj = Inertia(inertia, pointOfApplication, coordinateSystem)
            if isvector(inertia)
                obj.inertia = imf.Vector(inertia);
            elseif isa(force, 'imf.Vector')
                obj.inertia = inertia;
            else
                error('The inertia must be either an numeric or symbolic matrix or an imf.Vector');
            end
            
            
            if isvector(pointOfApplication)
                obj.pointOfApplication = imf.Vector(pointOfApplication);
            elseif isa(pointOfApplication, 'imf.Vector')
                obj.pointOfApplication = pointOfApplication;
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

